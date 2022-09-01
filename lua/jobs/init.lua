local nvim = require 'neovim'

local get_icon = require('utils.functions').get_icon
local executable = require('utils.files').executable

local jobs = STORAGE.jobs

local plugins = require('neovim').plugins

-- TODO: Add support to indicate backgroud jobs in the statusline
require 'jobs.mappings'

local Job = {}
Job.__index = Job

local function general_input_parser(job, data)
    vim.validate {
        data = {
            data,
            function(d)
                return type(d) == type '' or type(d) == type {}
            end,
            'job stdout data string or table',
        },
    }

    local input = ''
    local requested_input = false

    if type(data) == 'string' then
        data = vim.split(data, '[\r]?\n')
    end

    for _, val in ipairs(data) do
        val = nvim.replace_termcodes(val, true, false, false)

        if val:match '^[uU]sername for .*' or val:match '.* [uU]sername:%s*$' then
            input = vim.fn.input(val)
            requested_input = true
            break
        elseif val:match '^[pP]assword for .*' or val:match '.* [pP]assword:%s*$' then
            input = vim.fn.inputsecret(val)
            requested_input = true
            break
        elseif val:match '%(yes/no%)%??%s*$' then
            input = vim.fn.input(val)
            requested_input = true
            break
        end
    end

    if requested_input then
        if input and input ~= '' then
            if input:sub(#input, #input) ~= '\n' then
                input = input .. '\n'
            end
            job:send(input)
        else
            job:stop()
        end
    end
end

local function general_error_parser(job, data)
    vim.validate {
        data = {
            data,
            function(d)
                return type(d) == type '' or type(d) == type {}
            end,
            'job stdout data string or table',
        },
    }

    local error_detected = false
    -- TODO: Need to do more testing on these patterns
    local error_patterns = {
        '<(fail(ed)|err(or)?)>:',
        '<(fail(ed)|error)>:?',
        [=[\[(error|fail(ed)?]:?]=],
    }
    local error_regex = vim.regex([[\v\c(]] .. table.concat(error_patterns, '|') .. ')')

    if type(data) == 'string' then
        data = vim.split(data, '[\r]?\n')
    end

    for _, val in ipairs(data) do
        val = nvim.replace_termcodes(val, true, false, false)
        if error_regex:match(val) then
            error_detected = true
            break
        end
    end

    if error_detected then
        job.failed = true
    end

end

local function get_buffer(job)
    local buf = vim.api.nvim_create_buf(false, true)

    vim.bo[buf].bufhidden = 'wipe'
    if plugins['nvim-terminal.lua'] then
        vim.bo[buf].filetype = 'terminal'
    end

    nvim.buf.set_lines(buf, 0, -1, true, job:output())
    nvim.buf.call(buf, function()
        nvim.ex['normal!'] 'G'
    end)

    job._buffer = buf

    return buf
end

function Job:new(job)
    vim.validate {
        job = {
            job,
            function(j)
                return (type(j) == type {} and next(j) ~= nil) or (type(j) == type '' and j ~= '')
            end,
            'table with args or a cmd string',
        },
    }

    local exe, args, cmd, verify_exec
    verify_exec = true

    if type(job) == type '' then
        assert(job ~= '', debug.traceback 'Missing command')
        cmd = job
        local space = cmd:find ' '
        if space then
            exe = cmd:sub(1, space - 1)
            args = vim.split(cmd:sub(space + 1, #cmd), ' ')
        else
            exe = cmd
        end
    elseif type(job) == type {} and vim.tbl_islist(job) then
        assert(#job > 0, debug.traceback 'Missing command')
        cmd = job
        exe = cmd[1]
        if #cmd > 1 then
            args = vim.list_slice(cmd, 2, #cmd)
        end
    else
        assert(
            type(job) == type {} and not vim.tbl_islist(job),
            debug.traceback 'New must receive a table not an array'
        )

        if job.cmd and job.exe then
            error(debug.traceback 'Cannot have bot job.cmd and job.exe')
        end

        exe = job.cmd or job.exe
        args = job.args

        assert(not job.verify_exec or type(job.verify_exec) == type(true), debug.traceback 'Invalid verify_exec arg')
        if job.verify_exec ~= nil then
            verify_exec = job.verify_exec
        end

        assert(
            (type(exe) == type '' or (type(exe) == type {} and vim.tbl_islist(exe))) and #exe > 0,
            debug.traceback('Invalid cmd value ' .. vim.inspect(exe) .. ' it must be a str or an array')
        )

        if args then
            -- NOTE: allow exe = '' and (args = {} or args = '')
            assert(
                type(exe) == type '' and (type(args) == type '' or (type(args) == type {} and vim.tbl_islist(args))),
                debug.traceback 'Invalid args, args must be either a string or an array and cmd must be a string'
            )

            if type(args) == type {} then
                cmd = { exe }
                vim.list_extend(cmd, args)
            else
                cmd = ('%s %s'):format(exe, args)
            end
        else
            cmd = exe
            if type(cmd) == type {} then
                exe = cmd[1]
                args = #cmd > 1 and vim.list_slice(cmd, 2, #cmd) or {}
            elseif type(cmd) == type '' then
                local space = cmd:find ' '
                exe = space and cmd:sub(1, space - 1) or cmd
                local tmp = vim.split(cmd, ' ')
                args = #tmp > 1 and vim.list_slice(tmp, 2, #tmp) or {}
            end
        end
    end

    if not executable(exe) and verify_exec then
        error(debug.traceback('Command ' .. exe .. ' is not executable or is not located inside the PATH'))
    end

    local obj = {}
    obj.exe = exe
    obj.args = args
    obj._cmd = cmd

    if type(job) == type {} and not vim.tbl_islist(job) then
        if job.interactive ~= nil then
            assert(type(job.interactive) == type(true), debug.traceback 'interactive must be a bool')
            obj.interactive = job.interactive
        end

        if job.opts then
            assert(type(job.opts) == type {}, debug.traceback 'job options must be a table')
            obj._opts = job.opts
        end

        assert(job.qf == nil or type(job.qf) == type {}, debug.traceback 'Invalid qf args')
        obj._qf = job.qf

        if obj._qf then
            obj._qf.tab = nvim.get_current_tabpage()
        end

        assert(
            job.save_data == nil or type(job.save_data) == type(true),
            debug.traceback 'save_data arg must be a bool'
        )
        obj.save_data = job.save_data == nil and true or job.save_data

        assert(job.clear == nil or type(job.clear) == type(true), debug.traceback 'Clear arg must be a bool')
        obj._clear = job.clear == nil and true or job.clear

        assert(job.timeout == nil or type(job.timeout) == type(1), debug.traceback 'Timeout arg must be an integer')
        obj._timeout = job.timeout

        assert(
            job.silent == nil or type(job.silent) == type(true),
            debug.traceback('Invalid silent arg ' .. vim.inspect(job.silent))
        )
        obj.silent = false
        if job.silent ~= nil then
            obj.silent = job.silent
        end

        assert(
            job.progress == nil or type(job.progress) == type(true),
            debug.traceback('Invalid progress arg ' .. vim.inspect(job.progress))
        )
        obj._show_progress = false
        if job.progress ~= nil then
            obj._show_progress = job.progress
        end

        assert(
            job.parse_errors == nil or type(job.parse_errors) == type(true),
            debug.traceback('Invalid parse_errors arg ' .. vim.inspect(job.parse_errors))
        )
        obj._parse_errors = false
        if job.parse_errors ~= nil then
            obj._parse_errors = job.parse_errors
        end

        assert(
            job.parse_input == nil or type(job.parse_input) == type(true),
            debug.traceback('Invalid parse_input arg ' .. vim.inspect(job.parse_input))
        )
        obj._parse_input = ( obj._opts and obj._opts.pty ) and obj._opts.pty or false
        if job.parse_input ~= nil then
            obj._parse_input = job.parse_input
        end
    end

    obj._isalive = false
    obj._fired = false
    obj._id = -1
    obj._pid = -1
    obj._callbacks = {}
    obj._tab = nvim.get_current_tabpage()

    if obj._show_progress == nil then
        obj._show_progress = false
    end

    -- TODO: Add option to set custom parsing functions
    if obj._parse_errors == nil then
        obj._parse_errors = false
    end

    -- TODO: Add option to set custom parsing functions
    if obj._parse_input == nil then
        obj._parse_input = false
    end

    obj._output = {}
    obj._stdout = {}
    obj._stderr = {}

    return setmetatable(obj, self)
end

function Job:output()
    return self._output
end

function Job:is_empty()
    local is_empty = true
    for _, v in pairs(self._output) do
        if #v > 0 then
            is_empty = false
            break
        end
    end
    return is_empty
end

function Job:stdout()
    return self._stdout
end

function Job:stderr()
    return self._stderr
end

function Job:restart()
    local silent = self.silent
    self.silent = true

    if self._isalive then
        self:stop()
    end

    self.silent = silent

    self._stderr = {}
    self._stdout = {}
    self._output = {}
    self._isalive = false
    self._fired = false
    self._id = -1
    self._pid = -1
    -- self._tab = nvim.get_current_tabpage()
    self:start()
end

function Job:start()
    assert(not self._fired, debug.traceback(('Job %s was already started'):format(self._id)))

    local function general_on_exit(_, rc)
        if rc == 0 and not self.failed then
            vim.notify(('Job %s succeed!! %s'):format(self.exe, get_icon 'success'), 'INFO', { title = self.exe })
        else
            vim.notify(
                ('Job %s failed :c exit with code: %d!! %s'):format(self.exe, rc, get_icon 'error'),
                'ERROR',
                { title = self.exe }
            )
        end
    end

    local function general_on_data(data, name)
        vim.list_extend(self['_' .. (name or 'stdout')], data)
        vim.list_extend(self._output, data)

        if self._show_progress and vim.t.progress_win then
            if not self._buffer or not nvim.buf.is_valid(self._buffer) then
                self._buffer = get_buffer(self)
            else
                nvim.buf.set_lines(self._buffer, -2, -1, false, data)
                nvim.buf.call(self._buffer, function()
                    nvim.ex['normal!'] 'G'
                end)
            end

            if nvim.win_get_buf(vim.t.progress_win) ~= self._buffer then
                nvim.win.set_buf(vim.t.progress_win, self._buffer)
            end
        end
    end

    self._opts = self._opts or {}

    -- local _user_on_start = self._opts.on_start
    local _user_on_stdout = self._opts.on_stdout
    local _user_on_stderr = self._opts.on_stderr
    local _user_on_exit = self._opts.on_exit
    local utils_io = RELOAD('utils.files')
    local _cwd = self._opts.cwd or utils_io.getcwd()

    self._opts.cwd = utils_io.realpath(_cwd)

    local function on_exit_wrapper(_, rc, event)
        self._isalive = false
        self.rc = rc
        self._show_progress = false
        jobs[tostring(self._id)] = nil

        if vim.t.active_job == tostring(self._id)then
            vim.t.active_job = nil
        end

        if _user_on_exit then
            _user_on_exit(self, rc)
        elseif not self.silent then
            general_on_exit(_, rc)
        end

        if self._qf then
            local qf_opts = self._qf

            qf_opts.lines = self:output()
            local failed = rc ~= 0 or self.failed
            if qf_opts.on_fail and failed then
                if qf_opts.on_fail.open then
                    qf_opts.open = failed
                end
                if qf_opts.on_fail.jump then
                    qf_opts.jump = failed
                end
                if qf_opts.on_fail.dump then
                    qf_opts.dump = failed
                end
            end

            qf_opts.dump = qf_opts.dump == nil and true or qf_opts.dump
            qf_opts.clear = qf_opts.clear == nil and true or qf_opts.clear

            if qf_opts.dump then
                if vim.t.progress_win and self._tab == nvim.get_current_tabpage() then
                    nvim.win.close(vim.t.progress_win, false)
                end
                RELOAD('utils.functions').dump_to_qf(qf_opts)
            elseif qf_opts.clear and qf_opts.on_fail then
                local context = vim.fn.getqflist({ context = 1 }).context
                if context == (qf_opts.context or '') then
                    RELOAD('utils.functions').clear_qf()
                end
            end
        end

        if self._callbacks then
            for _, cb in pairs(self._callbacks) do
                cb(self, rc)
            end
        end
    end

    local function sanitize(data)
        if type(data) == type '' then
            data = vim.split(data, '[\r]?\n')
        end

        data = vim.tbl_map(function(k)
            k = vim.api.nvim_replace_termcodes(k, true, false, false)
            k = k:gsub('?%[[:;0-9]*m', '')
            return k
        end, data)

        return data
    end

    local function on_stdout_wrapper(_, data, name)
        data = sanitize(data)
        general_on_data(data, name)
        if _user_on_stdout then
            _user_on_stdout(self, data)
        end
        if self._parse_input then
            general_input_parser(self, data)
        end
        if self._parse_errors then
            general_error_parser(self, data)
        end
    end

    local function on_stderr_wrapper(_, data, name)
        data = sanitize(data)
        general_on_data(data, name)
        if _user_on_stderr then
            _user_on_stderr(self, data)
        end
        if self._parse_input then
            general_input_parser(self, data)
        end
        if self._parse_errors then
            general_error_parser(self, data)
        end
    end

    self._opts.on_stdout = on_stdout_wrapper
    self._opts.on_stderr = on_stderr_wrapper
    self._opts.on_exit = on_exit_wrapper

    self._id = vim.fn.jobstart(self._cmd, self._opts)

    if self._id == -1 then
        error(debug.traceback(('%s is not executable'):format(self._exe)))
    end

    self._fired = true
    self._isalive = true
    self._pid = vim.fn.jobpid(self._id)
    -- TODO: Should all jobs be pluggable ?

    if self._timeout and self._timeout > 0 then
        vim.defer_fn(function()
            vim.notify(('Timeout ! stoping job %s'):format(self._id), 'WARN', { title = 'Job Timeout' })
            self:stop()
        end, self._timeout)
    end

    jobs[tostring(self._id)] = self
    vim.t.active_job = tostring(self._id)
end

function Job:stop()
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    -- vim.fn.chanclose(self._id)
    vim.fn.jobstop(self._id)
end

function Job:pid()
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    return self._pid
end

function Job:send(data)
    vim.validate {
        data = {
            data,
            function(d)
                return type(d) == type '' or (type(d) == type {} and vim.tbl_islist(d))
            end,
            'string or string convertible data',
        },
    }
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    vim.fn.chansend(self._id, data)
end

function Job:progress()
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))

    if self._tab ~= nvim.get_current_tabpage() then
        vim.notify('Cannot show progress from a different tab !' .. get_icon 'warn', 'WARN', { title = 'Job Progress' })
        return false
    end

    self._show_progress = true

    if not self._buffer or not nvim.buf.is_valid(self.buffer) then
        self._buffer = get_buffer(self)
    end

    RELOAD('utils.windows').progress(self._buffer)

end

function Job:wait(timeout)
    vim.validate { timeout = { timeout, 'number', true } }
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    if timeout then
        return vim.fn.jobwait({ self._id }, timeout)[1]
    end
    return vim.fn.jobwait({ self._id })[1]
end

function Job:add_callback(cb)
    vim.validate { callback = { cb, 'function' } }
    table.insert(self._callbacks, cb)
end

function Job:callback_on_failure(cb)
    vim.validate { callback = { cb, 'function' } }
    self:add_callback(function(job, rc)
        if rc ~= 0 or job.failed then
            cb(job, rc)
        end
    end)
end

function Job:callback_on_success(cb)
    vim.validate { callback = { cb, 'function' } }
    self:add_callback(function(job, rc)
        if rc == 0 and not job.failed then
            cb(job)
        end
    end)
end

return Job

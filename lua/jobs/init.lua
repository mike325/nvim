local nvim = require 'nvim'

local get_icon = require('utils.functions').get_icon
local executable = require('utils.files').executable

local jobs = STORAGE.jobs

local plugins = require('nvim').plugins

local Job = {}
Job.__index = Job

local function general_input_parser(job, data)
    vim.validate('data', data, { 'string', 'table' })

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
    vim.validate('data', data, { 'string', 'table' })

    local error_detected = false
    -- TODO: Need to do more testing on these patterns
    local error_patterns = {
        '<(fail(ed)?|err(or)?)>:?',
        [=[\[(error|fail(ed)?)]:?]=],
    }
    local error_regex = vim.regex([[\v\c(]] .. table.concat(error_patterns, '|') .. ')')

    if type(data) == 'string' then
        data = vim.split(data, '[\r]?\n')
    end

    for _, val in ipairs(data) do
        val = nvim.replace_termcodes(val, true, false, false)
        if error_regex:match_str(val) then
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

    return buf
end

-- TODO: Add diagnostics integration support
-- TODO: split function into smaller units
function Job:new(job)
    vim.validate('job', job, function(j)
        return (type(j) == type {} and next(j) ~= nil) or (type(j) == type '' and j ~= '')
    end, false, 'table with args or a cmd string')

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
    elseif type(job) == type {} and vim.islist(job) then
        assert(#job > 0, debug.traceback 'Missing command')
        cmd = job
        exe = cmd[1]
        if #cmd > 1 then
            args = vim.list_slice(cmd, 2, #cmd)
        end
    else
        assert(type(job) == type {} and not vim.islist(job), debug.traceback 'New must receive a table not an array')

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
            (type(exe) == type '' or (type(exe) == type {} and vim.islist(exe))) and #exe > 0,
            debug.traceback('Invalid cmd value ' .. vim.inspect(exe) .. ' it must be a str or an array')
        )

        if args then
            -- NOTE: allow exe = '' and (args = {} or args = '')
            assert(
                type(exe) == type '' and (type(args) == type '' or (type(args) == type {} and vim.islist(args))),
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

    if type(job) == type {} and not vim.islist(job) then
        vim.validate('interactive', job.interactive, 'boolean', true)
        obj.interactive = job.interactive

        vim.validate('opts', job.opts, 'table', true)
        obj._opts = job.opts

        vim.validate('qf', job.qf, 'table', true)
        obj._qf = job.qf

        vim.validate('save_data', job.save_data, 'boolean', true)
        obj.save_data = job.save_data == nil and true or job.save_data

        vim.validate('clear', job.clear, 'boolean', true)
        obj._clear = job.clear == nil and true or job.clear

        vim.validate('timeout', job.timeout, 'number', true)
        obj._timeout = job.timeout

        vim.validate('silent', job.silent, 'boolean', true)
        obj.silent = false
        if job.silent ~= nil then
            obj.silent = job.silent
        end

        vim.validate('progress', job.progress, 'boolean', true)
        obj._show_progress = false
        if job.progress ~= nil then
            obj._show_progress = job.progress
        end

        vim.validate('parse_errors', job.parse_errors, 'boolean', true)
        obj._parse_errors = false
        if job.parse_errors ~= nil then
            obj._parse_errors = job.parse_errors
        end

        vim.validate('parse_input', job.parse_input, 'boolean', true)
        obj._parse_input = (obj._opts and obj._opts.pty) and obj._opts.pty or false
        if job.parse_input ~= nil then
            obj._parse_input = job.parse_input
        end

        obj._callbacks = {}
        local function cb_validator(callbacks)
            for _, cb in pairs(callbacks) do
                if type(cb) ~= 'function' then
                    return false
                end
            end
            return true
        end

        vim.validate('callbacks', job.callbacks, { 'table', 'function' }, true)
        if job.callbacks then
            obj._callbacks = type(job.callbacks) == 'function' and { job.callbacks } or job.callbacks
            vim.validate('callbacks', obj._callbacks, cb_validator, false, 'expected a function in all callbacks')
        end

        vim.validate('callbacks_on_success', job.callbacks_on_success, { 'table', 'function' }, true)
        if job.callbacks_on_success then
            local cb_on_success = type(job.callbacks_on_success) == 'function' and { job.callbacks_on_success }
                or job.callbacks_on_success
            vim.validate(
                'callbacks_on_success',
                cb_on_success,
                cb_validator,
                false,
                'expected a function in all callbacks_on_success'
            )
            vim.list_extend(
                obj._callbacks,
                vim.tbl_map(function(cb)
                    return function(j, rc)
                        if rc == 0 and not job.failed then
                            cb(j, rc)
                        end
                    end
                end, cb_on_success)
            )
        end

        vim.validate('callbacks_on_failure', job.callbacks_on_failure, { 'table', 'function' }, true)
        if job.callbacks_on_failure then
            local cb_on_failure = type(job.callbacks_on_failure) == 'function' and { job.callbacks_on_failure }
                or job.callbacks_on_failure
            vim.validate(
                'callbacks_on_failure',
                cb_on_failure,
                cb_validator,
                false,
                'expected a function in all callbacks_on_failure'
            )
            vim.list_extend(
                obj._callbacks,
                vim.tbl_map(function(cb)
                    return function(j, rc)
                        if rc ~= 0 or j.failed then
                            cb(j, rc)
                        end
                    end
                end, cb_on_failure)
            )
        end
    end

    obj._isalive = false
    obj._fired = false
    obj._id = -1
    obj._pid = -1

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
    obj._restarted = false

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

    self._restarted = true
    if self._isalive then
        self:stop()
    end

    self.silent = silent
    self._restarted = false

    self._stderr = {}
    self._stdout = {}
    self._output = {}
    self._isalive = false
    self._fired = false
    self._id = -1
    self._pid = -1
    self:start()
end

function Job:start()
    assert(not self._fired, debug.traceback(('Job %s was already started'):format(self._id)))

    local function general_on_exit(_, rc)
        if rc == 0 and not self.failed then
            vim.notify(
                ('Job %s succeed!! %s'):format(self.exe, get_icon 'success'),
                vim.log.levels.INFO,
                { title = self.exe }
            )
        else
            vim.notify(
                ('Job %s failed :c exit with code: %d!! %s'):format(self.exe, rc, get_icon 'error'),
                vim.log.levels.ERROR,
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
                    vim.cmd.normal { args = { 'G' }, bang = true }
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
    local utils_io = RELOAD 'utils.files'
    local _cwd = self._opts.cwd or utils_io.getcwd()

    self._opts.cwd = utils_io.realpath(_cwd)

    local function on_exit_wrapper(_, rc, _)
        jobs[tostring(self._id)] = nil
        -- NOTE: restart in progress, will come back after the new exit
        if self._restarted then
            return
        end

        self._isalive = false
        self.rc = rc
        self._show_progress = false

        if vim.g.active_job == tostring(self._id) then
            local clear = true
            for id, job in pairs(jobs) do
                if job._show_progress then
                    vim.g.active_job = id
                    clear = false
                    break
                end
            end
            if clear then
                vim.g.active_job = nil
            end
        end

        if vim.t.progress_win and not vim.g.active_job then
            nvim.win.close(vim.t.progress_win, true)
        end

        if _user_on_exit then
            _user_on_exit(self, rc)
        elseif not self.silent then
            general_on_exit(_, rc)
        end

        if self._qf then
            local qf_opts = self._qf

            qf_opts.items = self:output()
            local win = qf_opts.win
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

            local qfutils = RELOAD 'utils.qf'
            if qf_opts.dump then
                if vim.t.progress_win then
                    nvim.win.close(vim.t.progress_win, false)
                end
                qfutils.set_list(qf_opts, win)
            elseif qf_opts.clear and qf_opts.on_fail then
                -- TODO: check context
                local title = qfutils.get_list({ title = 1 }, win).title
                if title == (qf_opts.title or '') then
                    qfutils.clear()
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
            return (k:gsub('?%[[:;0-9]*m', ''))
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
        error(debug.traceback(('%s is not executable'):format(self.exe)))
    end

    self._fired = true
    self._isalive = true
    self._pid = vim.fn.jobpid(self._id)
    -- TODO: Should all jobs be pluggable ?

    if self._show_progress then
        self:progress()
    end

    if self._timeout and self._timeout > 0 then
        vim.defer_fn(function()
            vim.notify(('Timeout ! stopping job %s'):format(self._id), vim.log.levels.WARN, { title = 'Job Timeout' })
            self:stop()
        end, self._timeout)
    end

    jobs[tostring(self._id)] = self
    if self._show_progress then
        vim.g.active_job = tostring(self._id)
    end
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

function Job:id()
    return self._id
end

function Job:isalive()
    return self._isalive
end

function Job:send(data)
    vim.validate('data', data, function(d)
        return type(d) == type '' or (type(d) == type {} and vim.islist(d))
    end, false, 'string or string convertible data')
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    vim.fn.chansend(self._id, data)
end

function Job:progress()
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))

    self._show_progress = true
    vim.g.active_job = tostring(self:id())
    if not self._buffer or not nvim.buf.is_valid(self._buffer) then
        self._buffer = get_buffer(self)
    end

    RELOAD('utils.windows').progress(self._buffer)
end

function Job:wait(timeout)
    vim.validate('timeout', timeout, 'number', true)
    assert(self._isalive, debug.traceback(('Job %s is not running'):format(self._id)))
    if timeout then
        return vim.fn.jobwait({ self._id }, timeout)[1]
    end
    return vim.fn.jobwait({ self._id })[1]
end

function Job:add_callbacks(cbs)
    vim.validate('callback', cbs, { 'function', 'table' })
    cbs = type(cbs) == 'function' and { cbs } or cbs
    vim.list_extend(self._callbacks, cbs)
end

function Job:callbacks_on_failure(cbs)
    vim.validate('callback', cbs, { 'function', 'table' })
    cbs = type(cbs) == 'function' and { cbs } or cbs
    cbs = vim.tbl_map(function(cb)
        return function(job, rc)
            if rc ~= 0 or job.failed then
                cb(job, rc)
            end
        end
    end, cbs)
    self:add_callbacks(cbs)
end

function Job:callbacks_on_success(cbs)
    vim.validate('callback', cbs, { 'function', 'table' })
    cbs = type(cbs) == 'function' and { cbs } or cbs
    cbs = vim.tbl_map(function(cb)
        return function(job, rc)
            if rc == 0 and not job.failed then
                cb(job)
            end
        end
    end, cbs)
    self:add_callbacks(cbs)
end

return Job

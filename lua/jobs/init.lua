local nvim = require'neovim'

if not nvim.has('nvim-0.5') then
    return false
end

local echowarn   = require'utils'.messages.echowarn
local get_icon   = require'utils'.helpers.get_icon
local executable = require'utils'.files.executable

local jobs = STORAGE.jobs

local plugins = require'neovim'.plugins

local set_autocmd = require'neovim.autocmds'.set_autocmd
require'jobs.mappings'

local Job = {}
Job.__index = Job

local function general_output_parser(job, data)
    assert(type(data) == 'string' or type(data) == 'table', 'Not valid data: '..type(data))
    local input = ''
    local requested_input = false

    if type(data) == 'string' then
        data = vim.split(data, '[\r]?\n')
    end

    for _,val in pairs(data) do
        val = nvim.replace_termcodes(val, true, false, false)

        if val:match('^[uU]sername for .*') or val:match('.* [uU]sername:%s*$') then
            input = vim.fn.input(val)
            requested_input = true
            break
        elseif val:match('^[pP]assword for .*') or val:match('.* [pP]assword:%s*$') then
            input = vim.fn.inputsecret(val)
            requested_input = true
            break
        elseif val:match('%(yes/no%)%??%s*$') then
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

local function get_buffer(job)
    local buf = vim.api.nvim_create_buf(false, true)

    nvim.buf.set_option(buf, 'bufhidden', 'wipe')
    if plugins['nvim-terminal.lua'] then
        nvim.buf.set_option(buf, 'filetype', 'terminal')
    end

    nvim.buf.set_lines(buf, 0, -1, true, job:output())
    nvim.buf.call(buf, function() nvim.ex['normal!']('G') end)

    job._buffer = buf

    return buf
end

function Job:new(job)
    assert(
        (type(job) == type({}) and next(job) ~= nil) or (type(job) == type('') and #job > 0),
        debug.traceback('Missing job data '..vim.inspect(job))
    )

    local exe,args,cmd,verify_exec
    verify_exec = true

    if type(job) == type('') then
        assert(#job > 0, debug.traceback('Missing command'))
        cmd = job
        local space = cmd:find(' ')
        if space then
            exe = cmd:sub(1, space - 1)
            args = vim.split(cmd:sub(space + 1, #cmd), ' ')
        else
            exe = cmd
        end
    elseif type(job) == type({}) and vim.tbl_islist(job) then
        assert(#job > 0, debug.traceback('Missing command'))
        cmd = job
        exe = cmd[1]
        if #cmd > 1 then
            args = vim.list_slice(cmd, 2, #cmd)
        end
    else
        assert(
            type(job) == type({}) and not vim.tbl_islist(job),
            debug.traceback('New must receive a table not an array')
        )

        if job.cmd and job.exe then
            error(debug.traceback('Cannot have bot job.cmd and job.exe'))
        end

        exe = job.cmd or job.exe
        args = job.args

        assert(
            not job.verify_exec or type(job.verify_exec) == type(true),
            debug.traceback('Invalid verify_exec arg')
        )
        if job.verify_exec ~= nil then
            verify_exec = job.verify_exec
        end

        assert(
            (type(exe) == type('') or (type(exe) == type({}) and vim.tbl_islist(exe))) and #exe > 0,
            debug.traceback('Invalid cmd value '..vim.inspect(exe)..' it must be a str or an array')
        )

        if args then
            -- NOTE: allow exe = '' and (args = {} or args = '')
            assert(
                type(exe) == type('') and (type(args) == type('') or (type(args) == type({}) and vim.tbl_islist(args))),
                debug.traceback('Invalid args, args must be either a string or an array and cmd must be a string')
            )

            if type(args) == type({}) then
                cmd = {exe}
                vim.list_extend(cmd, args)
            else
                cmd = ('%s %s'):format(exe, args)
            end
        else
            cmd = exe
            if type(cmd) == type({}) then
                exe = cmd[1]
                args = #cmd > 1 and vim.list_slice(cmd, 2, #cmd) or {}
            elseif type(cmd) == type('') then
                local space = cmd:find(' ')
                exe = space and cmd:sub(1, space - 1) or cmd
                local tmp = vim.split(cmd, ' ')
                args = #tmp > 1 and vim.list_slice(tmp, 2, #tmp) or {}
            end
        end
    end

    if not executable(exe) and verify_exec then
        error(debug.traceback('Command '..exe..' is not executable or is not located inside the PATH'))
    end

    local obj = {}
    obj.exe = exe
    obj.args = args
    obj._cmd = cmd

    if type(job) == type({}) and not vim.tbl_islist(job) then
        if job.interactive ~= nil then
            assert(type(job.interactive) == type(true), debug.traceback('interactive must be a bool'))
            obj.interactive = job.interactive
        end

        if job.opts then
            assert(type(job.opts) == type({}), debug.traceback('job options must be a table'))
            obj._opts = job.opts
        end

        assert(job.qf == nil or type(job.qf) == type({}), debug.traceback('Invalid qf args'))
        obj._qf = job.qf

        if obj._qf then
            obj._qf.tab = nvim.get_current_tabpage()
        end

        assert(
            job.save_data == nil or type(job.save_data) == type(true),
            debug.traceback('save_data arg must be a bool')
        )
        obj.save_data = job.save_data == nil and true or job.save_data

        assert(
            job.clear == nil or type(job.clear) == type(true),
            debug.traceback('Clear arg must be a bool')
        )
        obj._clear = job.clear == nil and true or job.clear

        assert(
            job.timeout == nil or type(job.timeout) == type(1),
            debug.traceback('Timeout arg must be an integer')
        )
        obj._timeout = job.timeout

        assert(
            job.silent == nil or type(job.silent) == type(true),
            debug.traceback('Invalid silent arg '..vim.inspect(job.silent))
       )
        obj.silent = false
        if job.silent ~= nil then
            obj.silent = job.silent
        end

        assert(
            job.progress == nil or type(job.progress) == type(true),
            debug.traceback('Invalid progress arg '..vim.inspect(job._show_progress))
       )
        obj._show_progress = false
        if job.progress ~= nil then
            obj._show_progress = job.progress
        end
    end

    obj._isalive = false
    obj._fired = false
    obj._id = -1
    obj._pid = -1
    obj._callbacks = {}
    obj._show_progress = obj._show_progress or false
    obj._tab = nvim.get_current_tabpage()

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
    assert(not self._fired, debug.traceback( ('Job %s was already started'):format(self._id) ))

    local function general_on_exit(_, rc)
        if rc == 0 then
            require'utils'.messages.echomsg(
                ('Job %s succeed!! %s'):format(self.exe, get_icon('success')),
                self.exe
            )
        else
            require'utils'.messages.echoerr(
                ('Job %s failed :c exit with code: %d!! %s'):format(
                    self.exe,
                    rc,
                    get_icon('error')
                ),
                self.exe
            )
        end
    end

    local function general_on_data(data, name)

        if type(data) == type('') then
            data = vim.split(data, '\n')
        end

        vim.list_extend(self['_'..(name or 'stdout')], data)
        vim.list_extend(self._output, data)

        if self._show_progress and vim.t.progress_win then
            if not self._buffer or not nvim.buf.is_valid(self._buffer) then
                self._buffer = get_buffer(self)
            else
                nvim.buf.set_lines(self._buffer, -2, -1, false, data)
                nvim.buf.call(self._buffer, function() nvim.ex['normal!']('G') end)
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
    local _cwd = self._opts.cwd or require'utils'.files.getcwd()

    self._opts.cwd = require'utils'.files.realpath(_cwd)

    local function on_exit_wrapper(_, rc, event)
        self._isalive = false
        self.rc = rc
        self._show_progress = false
        jobs[tostring(self._id)] = nil

        if _user_on_exit then
            _user_on_exit(self, rc)
        elseif not self.silent then
            general_on_exit(_, rc)
        end

        if self._qf then
            local qf_opts = self._qf

            qf_opts.lines = self:output()
            if qf_opts.on_fail then
                if qf_opts.on_fail.open then
                    qf_opts.open = rc ~= 0
                end
                if qf_opts.on_fail.jump then
                    qf_opts.jump = rc ~= 0
                end
                if qf_opts.on_fail.dump then
                    qf_opts.dump = rc ~= 0
                end
            end

            qf_opts.dump = qf_opts.dump == nil and true or qf_opts.dump
            qf_opts.clear = qf_opts.clear == nil and true or qf_opts.clear

            if qf_opts.dump then
                if vim.t.progress_win and self._tab == nvim.get_current_tabpage() then
                    nvim.win.close(vim.t.progress_win, false)
                end
                require'utils'.helpers.dump_to_qf(qf_opts)
            elseif qf_opts.clear and qf_opts.on_fail then
                local context = vim.fn.getqflist({context = 1}).context
                if context == (qf_opts.context or '') then
                    require'utils'.helpers.clear_qf()
                end
            end
        end

        if self._callbacks and #self._callbacks > 0 then
            for _, cb in pairs(self._callbacks) do
                cb(self, rc)
            end
        end

    end

    local function on_stdout_wrapper(_, data, name)
        general_on_data(data, name)
        if _user_on_stdout then
            _user_on_stdout(self, data)
        end
        general_output_parser(self, data)
    end

    local function on_stderr_wrapper(_, data, name)
        general_on_data(data, name)
        if _user_on_stderr then
            _user_on_stderr(self, data)
        end
        general_output_parser(self, data)
    end

    self._opts.on_stdout = on_stdout_wrapper
    self._opts.on_stderr = on_stderr_wrapper
    self._opts.on_exit = on_exit_wrapper

    self._id = vim.fn.jobstart(
        self._cmd,
        self._opts
    )

    if self._id == -1 then
        error(debug.traceback( ('%s is not executable'):format(self._exe) ))
    end

    self._fired = true
    self._isalive = true
    self._pid = vim.fn.jobpid(self._id)

    if self._timeout and self._timeout > 0 then
        vim.defer_fn(function()
            echowarn(('Timeout ! stoping job %s'):format(self._id), 'Job Timeout')
            self:stop()
        end, self._timeout)
    end

    jobs[tostring(self._id)] = self

end

function Job:stop()
    assert(self._isalive, debug.traceback( ('Job %s is not running'):format(self._id) ))
    -- vim.fn.chanclose(self._id)
    vim.fn.jobstop(self._id)
end

function Job:pid()
    assert(self._isalive, debug.traceback( ('Job %s is not running'):format(self._id) ))
    return self._pid
end

function Job:send(data)
    assert(self._isalive, debug.traceback( ('Job %s is not running'):format(self._id) ))
    vim.fn.chansend(self._id, data)
end

function Job:progress()
    assert(self._isalive, debug.traceback( ('Job %s is not running'):format(self._id) ))

    if self._tab ~= nvim.get_current_tabpage() then
        echowarn('Cannot show progress from a different tab !'..get_icon('warn'), 'Job Progress')
        return false
    end

    self._show_progress = true

    if not self._buffer or not nvim.buf.is_valid(self.buffer) then
        self._buffer = get_buffer(self)
    end

    require'utils'.windows.progress(self._buffer)
end

function Job:wait(timeout)
    assert(self._isalive, debug.traceback( ('Job %s is not running'):format(self._id) ))
    assert(
        type(timeout) == type(1) or timeout == nil,
        debug.traceback('Timeout must be either nil or a number in ms')
    )
    return vim.fn.jobwait(self._id, timeout)
end

function Job:add_callback(cb)
    assert(vim.is_callable(cb), debug.traceback('Callback must be a function'))
    table.insert(self._callbacks, cb)
end

function Job:callback_on_failure(cb)
    assert(vim.is_callable(cb), debug.traceback('Callback must be a function'))
    self:add_callback(function(job, rc)
        if rc ~= 0 then cb(job, rc) end
    end)
end

function Job:callback_on_success(cb)
    assert(vim.is_callable(cb), debug.traceback('Callback must be a function'))
    self:add_callback(function(job, rc)
        if rc == 0 then cb(job) end
    end)
end

return Job

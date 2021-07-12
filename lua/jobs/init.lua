local nvim       = require'neovim'
local echoerr    = require'utils.messages'.echoerr
local echowarn   = require'utils.messages'.echowarn
local clear_lst  = require'utils.tables'.clear_lst
local dump_to_qf = require'utils.helpers'.dump_to_qf
local executable = require'utils.files'.executable
local getcwd     = require'utils.files'.getcwd
local realpath   = require'utils.files'.realpath

local jobs = STORAGE.jobs

if not nvim.has('nvim-0.5') then
    return false
end

local set_command = require'neovim.commands'.set_command

local Job = {}
Job.__index = Job

local function general_output_parser(jobid, data)
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
        end
    end

    if requested_input then
        if input and input ~= '' then
            if input:sub(#input, #input) ~= '\n' then
                input = input .. '\n'
            end
            vim.fn.chansend(jobid, input)
        else
            -- M.kill_job(jobid)
        end
    end
end

function Job:new(job)
    assert(
        (type(job) == type({}) and next(job) ~= nil) or (type(job) == type('') and #job > 0),
        debug.traceback('Missing job data '..vim.inspect(job))
    )

    local exe,args,cmd

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
            if type(cmd) == type({}) and #cmd > 1 then
                exe = cmd[1]
                args = vim.list_slice(cmd, 2, #cmd)
            elseif type(cmd) == type('') and cmd:find('%s') then
                local space = cmd:find(' ')
                exe = space and cmd:sub(1, space - 1) or cmd
                local tmp = vim.split(cmd, ' ')
                args = vim.list_slide(tmp, 2, #tmp)
            end
        end
    end

    if not executable(exe) then
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

        obj._qf = job.qf

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
    end

    obj._isalive = false
    obj._fired = false
    obj._id = -1
    obj._pid = -1
    obj._callbacks = {}

    obj._output = {}
    obj._stdout = {}
    obj._stderr = {}

    return setmetatable(obj, self)
end

function Job:output()
  return self._output
end

function Job:stdout()
  return self._stdout
end

function Job:stderr()
  return self._stderr
end

function Job:start()
    assert(not self._fired, debug.traceback( ('Job %s was already started'):format(self._id) ))

    local function dump_data(_, rc, event)
    end

    local function general_on_exit(_, rc, event)
        if rc == 0 then
            print( ('Job %s succeed!'):format(self.exe) )
        else
            echoerr( ('Job %s failed :c exit with code: %d!'):format(self.exe, rc) )
        end
    end

    local function general_on_data(data, name)

        if type(data) == type('') then
            data = vim.split(data, '\n')
        end

        vim.list_extend(self['_'..name], data)
        vim.list_extend(self._output, data)
    end

    self._opts = self._opts or {}

    -- local _user_on_start = self._opts.on_start
    local _user_on_stdout = self._opts.on_stdout
    local _user_on_stderr = self._opts.on_stderr
    local _user_on_exit = self._opts.on_exit
    local _cwd = self._opts.cwd or getcwd()

    self._opts.cwd = realpath(_cwd)

    local function on_exit_wrapper(_, rc, event)
        self._isalive = false
        self.rc = rc
        jobs[tostring(self._id)] = nil

        if _user_on_exit then
            _user_on_exit(self, rc)
        elseif not self.silent then
            general_on_exit(_, rc, event)
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
            end
            require'utils'.helpers.dump_to_qf(qf_opts)
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
    end

    local function on_stderr_wrapper(_, data, name)
        general_on_data(data, name)
        if _user_on_stderr then
            _user_on_stderr(self, data)
        end
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
            echowarn( ('Timeout ! stoping job %s'):format(self._id) )
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

local function kill_job(jobid)
    if not jobid then
        local ids = {}
        local cmds = {}
        local jobidx = 1
        for idx,job in pairs(jobs) do
            ids[#ids + 1] = idx
            local cmd = type(job._cmd) == type('') and job._cmd or table.concat(job._cmd , ' ')
            cmds[#cmds + 1] = ('%s: %s'):format(jobidx, cmd)
            jobidx = jobidx + 1
        end
        if #cmds > 0 then
            local idx = vim.fn.inputlist(cmds)
            jobid = ids[idx]
        else
            echowarn('No jobs to kill')
        end
    end

    if type(jobid) == type('') and jobid:match('^%d+$') then
        jobid = tonumber(jobid)
    end

    if type(jobid) == type(1) and jobid > 0 then
        pcall(vim.fn.jobstop, jobid)
    end
end

set_command{
    lhs = 'KillJob',
    rhs = function(jobid, bang)
        if jobid == '' then
            jobid = nil
        end
        kill_job(jobid)
    end,
    args = {nargs = '?', bang = true, force = true},
}

return Job

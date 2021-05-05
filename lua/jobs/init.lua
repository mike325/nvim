local nvim       = require'nvim'
local echoerr    = require'tools'.messages.echoerr
local echowarn   = require'tools'.messages.echowarn
local clear_lst  = require'tools'.tables.clear_lst
local dump_to_qf = require'tools'.helpers.dump_to_qf
local split      = require'tools'.strings.split

if not nvim.has('nvim-0.5') then
    return false
end

local set_command = nvim.commands.set_command

local M ={
    jobs = {},
}

local function is_alive(id)
    local ok, _ = pcall(nvim.fn.jobpid, id)
    return ok
end

local function cleanup(jobid, rc)
    M.jobs[jobid].is_alive = false
    if rc == 0 and M.jobs[jobid].clean then
        M.jobs[jobid] = nil
    end
end

function M.general_output_parser(jobid, data)
    assert(type(data) == 'string' or type(data) == 'table', 'Not valid data: '..type(data))
    local input = ''
    local requested_input = false

    if type(data) == 'string' then
        data = split(data, '\n')
    end

    for _,val in pairs(data) do
        val = nvim.replace_termcodes(val, true, false, false)

        if val:match('^[uU]sername for .*') or val:match('.* [uU]sername:%s*$') then
            input = nvim.fn.input(val)
            requested_input = true
            break
        elseif val:match('^[pP]assword for .*') or val:match('.* [pP]assword:%s*$') then
            input = nvim.fn.inputsecret(val)
            requested_input = true
            break
        end
    end

    if requested_input then
        if input and input ~= '' then
            if input:sub(#input, #input) ~= '\n' then
                input = input .. '\n'
            end
            nvim.fn.chansend(jobid, input)
        else
            vim.defer_fn(function()
                    M.kill_job(jobid)
                end,
                1
            )
        end
    end
end

local function general_on_exit(jobid, rc, _)

    local stream
    local cmd = type(M.jobs[jobid].cmd) == 'string' and M.jobs[jobid].cmd or table.concat(M.jobs[jobid].cmd, ' ')

    if rc == 0 then
        if M.jobs[jobid].qf == nil or (M.jobs[jobid].qf.open ~= true and M.jobs[jobid].qf.jump ~= true) then
            print(('Job "%s" finished'):format(cmd))
        end
        if M.jobs[jobid].qf and M.jobs[jobid].streams and M.jobs[jobid].streams.stdout then
            stream = M.jobs[jobid].streams.stdout
        end
    else
        if M.jobs[jobid].qf == nil or (M.jobs[jobid].qf.open ~= true and M.jobs[jobid].qf.jump ~= true) then
            echoerr(('Job "%s" failed, exited with %s'):format(cmd, rc))
        end
        if M.jobs[jobid].streams then
            if M.jobs[jobid].streams.stderr then
                stream = M.jobs[jobid].streams.stderr
            elseif M.jobs[jobid].opts.pty and M.jobs[jobid].streams.stdout then
                stream = M.jobs[jobid].streams.stdout
            end
        end
    end

    if stream and #stream > 0 then

        local qf_opts = M.jobs[jobid].qf or {}

        qf_opts.context = qf_opts.context or cmd
        qf_opts.title = qf_opts.title or cmd..' output'
        qf_opts.lines = stream

        if qf_opts.on_fail then
            if qf_opts.on_fail.open then
                qf_opts.open = rc ~= 0
            end
            if qf_opts.on_fail.jump then
                qf_opts.jump = rc ~= 0
            end
        end

        dump_to_qf(qf_opts)
    end

    cleanup(jobid, rc)

end

local function save_data(jobid, data, event)
    if not M.jobs[jobid].streams then
        M.jobs[jobid].streams = {}
        M.jobs[jobid].streams[event] = {}
    elseif not M.jobs[jobid].streams[event] then
        M.jobs[jobid].streams[event] = {}
    end

    if type(data) == 'string' then
        data = data:gsub('\t','  ')
        data = split(data, '\n')
    end

    data = clear_lst(data)

    if #data > 0 then
        vim.list_extend(M.jobs[jobid].streams[event], data)
    end
end

local function general_on_data(jobid, data, event)
    save_data(jobid, data, event)
    if M.jobs[jobid].opts.pty then
        M.general_output_parser(jobid, data)
    end
end

function M.kill_job(jobid)
    if not jobid then
        local ids = {}
        local cmds = {}
        local jobidx = 1
        for id,opts in pairs(M.jobs) do
            local running = is_alive(id)
            if running then
                ids[#ids + 1] = id
                local cmd = type(opts.cmd) == 'string' and opts.cmd or table.concat(opts.cmd, ' ')
                cmds[#cmds + 1] = ('%s: %s'):format(jobidx, cmd)
                jobidx = jobidx + 1
            end
            M.jobs[id].is_alive = running
        end
        if #cmds > 0 then
            local idx = nvim.fn.inputlist(cmds)
            jobid = ids[idx]
        else
            echowarn('No jobs to kill')
        end
    end

    if type(jobid) == 'number' and jobid > 0 then
        pcall(nvim.fn.jobstop, jobid)
    end
end

function M.send_job(job)
    local cmd = job.cmd

    if not cmd or (type(cmd) == 'table' and next(cmd) == nil) or (type(cmd) == 'string' and cmd == '') then
        echoerr('Missing command')
        return
    elseif type(cmd) == 'table' and job.args ~= nil then
        echoerr('Either use a cmd table or a cmd string with a table of args')
        return
    elseif job.args ~= nil and type(cmd) ~= type(job.args) then
        echoerr('cmd and args must be the same type')
        return
    end

    assert(job.async == nil or type(job.async) == 'boolean', 'Invalid async option: '..type(job.async))
    assert(job.timeout == nil or type(job.timeout) == 'number', 'Invalid async option: '..type(job.timeout))

    if job.async == false then
        local win = require("floating").window()
        local bufnr = require'nvim'.win.get_buf(win)
        nvim.win.set_option(win, 'number', false)
        nvim.win.set_option(win, 'relativenumber', false)
        nvim.buf.set_option(bufnr, 'bufhidden', 'wipe')
        if type(cmd) == 'table' then
            if job.args ~= nil then
                cmd = vim.list_extend(cmd, job.args)
            end
            cmd = table.concat(cmd, ' ')
        elseif type(cmd) == 'string' and job.args ~= nil then
            cmd = cmd .. ' ' .. job.args
        end
        nvim.command('terminal '..cmd)
        nvim.ex.startinsert()
    else
        assert(not job.clean or type(job.clean) == type(true), 'Invalid Clean arg: '..type(job.clean))
        assert(not job.server or type(job.server) == type(true), 'Invalid Server arg: '..type(job.server))
        assert(not job.timeout or type(job.timeout) == type(1), 'Invalid Timeout arg: '..type(job.timeout))

        local opts = job.opts or {}
        local clean = type(job.clean) ~= 'boolean' and true or job.clean

        job.server = job.server or false
        if job.server then
            job.timeout = 0
            clean = false
        end

        if not opts.on_exit then
            opts.on_exit = general_on_exit
        else
            local opts_on_exit = opts.on_exit
            opts.on_exit = function(jobid, rc, event)
                M.jobs[jobid].is_alive = false
                opts_on_exit(jobid, rc, event)
                if clean then
                    cleanup(jobid, rc)
                end
            end
        end

        if not opts.on_data or job.save_data then
            if not opts.on_stdout then
                opts.on_stdout = general_on_data
            elseif job.save_data then
                local original_func = opts.on_stdout
                opts.on_stdout = function(jobid, data, event)
                    save_data(jobid, data, event)
                    original_func(jobid, data, event)
                end
            end

            if not opts.on_stderr then
                opts.on_stderr = general_on_data
            elseif job.save_data then
                local original_func = opts.on_stderr
                opts.on_stderr = function(jobid, data, event)
                    save_data(jobid, data, event)
                    original_func(jobid, data, event)
                end
            end

            if not opts.on_stdin then
                opts.on_stdin = general_on_data
            elseif job.save_data then
                local original_func = opts.on_stdin
                opts.on_stdin = function(jobid, data, event)
                    save_data(jobid, data, event)
                    original_func(jobid, data, event)
                end
            end

            if not opts.on_data then
                opts.on_data = general_on_data
            elseif job.save_data then
                local original_func = opts.on_data
                opts.on_data = function(jobid, data, event)
                    save_data(jobid, data, event)
                    original_func(jobid, data, event)
                end
            end
        end

        if job.args then
            if type(cmd) == 'table' then
                cmd = vim.list_extend(cmd, job.args)
            elseif type(cmd) == 'string' then
                cmd = cmd .. ' ' .. job.args
            end
        end

        if job.qf and job.qf.open == nil then
            job.qf.open = false
        end

        if job.qf and job.qf.jump == nil then
            job.qf.jump = false
        end

        local id = nvim.fn.jobstart(
            cmd,
            opts
        )

        if id > 0 then
            M.jobs[id] = {
                cmd = cmd,
                opts = opts,
                save_data = job.save_data or false,
                qf = job.qf,
                clean = clean,
                is_alive = true,
                timeout = job.timeout or 0,
            }

            if job.timeout and job.timeout > 0 then
                vim.defer_fn(function()
                        if M.jobs[id].is_alive then
                            M.kill_job(id)
                        end
                    end,
                    job.timeout
                )
            end
        end
    end
end

set_command {
    lhs = 'KillJob',
    rhs = function(jobid)
        if jobid == '' then
            jobid = nil
        end
        M.kill_job(jobid)
    end,
    args = {nargs = '?', force = true}
}

return M

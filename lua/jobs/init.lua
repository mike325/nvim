local nvim       = require'nvim'
local echoerr    = require'tools'.messages.echoerr
local clear_lst  = require'tools'.tables.clear_lst
local dump_to_qf = require'tools'.helpers.dump_to_qf
-- local split      = require'tools'.strings.split

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
    if rc == 0 and M.jobs[jobid].clean then
        M.jobs[jobid] = nil
    else
        M.jobs[jobid].is_alive = false
    end
end

local function general_on_exit(jobid, rc, _)

    local stream
    if rc == 0 then
        if M.jobs[jobid].qf == nil or (M.jobs[jobid].qf.open ~= true and M.jobs[jobid].qf.jump ~= true) then
            print(('Job "%s" finished'):format(M.jobs[jobid].cmd))
        end
        if M.jobs[jobid].qf and M.jobs[jobid].streams and M.jobs[jobid].streams.stdout then
            stream = M.jobs[jobid].streams.stdout
        end
    else
        if M.jobs[jobid].qf == nil or (M.jobs[jobid].qf.open ~= true and M.jobs[jobid].qf.jump ~= true) then
            echoerr(('Job "%s" failed, exited with %s'):format(M.jobs[jobid].cmd, rc))
        end
        if M.jobs[jobid].streams and M.jobs[jobid].streams.stderr then
            stream = M.jobs[jobid].streams.stderr
        end
    end

    if stream and #stream > 0 then

        local cmdname
        if type(M.jobs[jobid].cmd) == 'table' then
            cmdname = M.jobs[jobid].cmd[0]
        elseif type(M.jobs[jobid].cmd) == 'string' then
            cmdname = vim.split(M.jobs[jobid].cmd, ' ')[1]
        end

        local qf_opts = M.jobs[jobid].qf or {}

        qf_opts.context = qf_opts.context or cmdname
        qf_opts.efm = qf_opts.efm or nvim.bo.efm or nvim.o.efm
        qf_opts.title = qf_opts.title or cmdname..' output'
        qf_opts.lines = stream

        dump_to_qf(qf_opts)
    end

    cleanup(jobid, rc)

end

local function general_on_data(jobid, data, event)

    if not M.jobs[jobid].streams then
        M.jobs[jobid].streams = {}
        M.jobs[jobid].streams[event] = {}
    elseif not M.jobs[jobid].streams[event] then
        M.jobs[jobid].streams[event] = {}
    end

    if type(data) == 'string' then
        data = data:gsub('\t','  ')
        data = vim.split(data, '\n')
    end

    vim.list_extend(M.jobs[jobid].streams[event], clear_lst(data))
end

function M.kill_job(jobid)
    if not jobid then
        local ids = {}
        local cmds = {}
        local jobidx = 1
        for id,opts in pairs(M.jobs) do
            local running = is_alive()
            if running then
                ids[#ids + 1] = id
                cmds[#cmds + 1] = ('%s: %s'):format(jobidx, opts.cmd)
                jobidx = jobidx + 1
            else
                M.jobs[id].is_alive = running
            end
        end
        local idx = nvim.fn.inputlist(cmds)
        jobid = ids[idx]
    end

    if type(jobid) == 'number' and jobid > 0 then
        nvim.fn.jobstop(jobid)
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
            cmd = vim.fn.join(cmd, ' ')
        elseif type(cmd) == 'string' and job.args ~= nil then
            cmd = cmd .. ' ' .. job.args
        end
        nvim.command('terminal '..cmd)
        nvim.ex.startinsert()
    else
        local opts = job.opts or {}
        local clean = type(job.clean) ~= 'boolean' and true or job.clean

        if not opts.on_exit then
            opts.on_exit = general_on_exit
        elseif clean then
            local opts_on_exit = opts.on_exit
            opts.on_exit = function(jobid, rc, event)
                opts_on_exit(jobid, rc, event)
                cleanup(jobid, rc)
            end
        end

        if not opts.on_stdout and not opts.on_stderr and not opts.on_stdin and not opts.on_data then
            opts.on_stdout = general_on_data
            opts.on_stderr = general_on_data
            opts.on_stdin = general_on_data
            opts.on_data = general_on_data
        end

        if type(cmd) == 'table' and job.args ~= nil then
            cmd = vim.list_extend(cmd, job.args)
        elseif type(cmd) == 'string' and job.args ~= nil then
            cmd = cmd .. ' ' .. job.args
        end

        local id = nvim.fn.jobstart(
            cmd,
            opts
        )

        if job.qf and job.qf.open == nil then
            job.qf.open = false
        end

        if job.qf and job.qf.jump == nil then
            job.qf.jump = false
        end

        if id > 0 then
            M.jobs[id] = {
                cmd = cmd,
                opts = opts,
                qf = job.qf,
                clean = clean,
                is_alive = true,
            }
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

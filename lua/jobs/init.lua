local nvim = require'nvim'
local echoerr = require'tools'.messages.echoerr
local clear_lst = require'tools'.tables.clear_lst
local dump_to_qf = require'tools'.helpers.dump_to_qf

if not nvim.has('nvim-0.5') then
    return false
end

local M ={
    jobs = {},
}

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

    if #stream > 0 then

        local cmdname
        if type(M.jobs[jobid].cmd) == 'table' then
            cmdname = M.jobs[jobid].cmd[0]
        elseif type(M.jobs[jobid].cmd) == 'string' then
            cmdname = vim.split(M.jobs[jobid].cmd, ' ')[1]
        end

        local qf_opts = M.jobs[jobid].qf

        qf_opts.context = qf_opts.context or cmdname
        qf_opts.efm = qf_opts.efm or nvim.bo.efm or nvim.o.efm
        qf_opts.title = qf_opts.title or cmdname..' output'
        qf_opts.lines = stream

        dump_to_qf(qf_opts)
    end

    if rc == 0 and M.jobs[jobid].clean then
        M.jobs[jobid] = nil
    end

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
        for id,opts in pairs(M.jobs) do
            ids[#ids + 1] = id
            cmds[#cmds + 1] = opts.cmd
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

    if not cmd or #cmd == 0 then
        echoerr('Missing command')
        return
    end

    if job.async == false then
        local win = require("floating").window()
        local bufnr = require'nvim'.win.get_buf(win)
        nvim.win.set_option(win, 'number', false)
        nvim.win.set_option(win, 'relativenumber', false)
        nvim.buf.set_option(bufnr, 'bufhidden', 'wipe')
        if type(cmd) == 'table' then
            cmd = vim.fn.join(cmd, ' ')
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
                local jobs = require'jobs'
                if rc == 0 and jobs.jobs[jobid] ~= nil then
                    jobs.jobs[jobid] = nil
                end
            end
        end

        if not opts.on_stdout and not opts.on_stderr and not opts.on_stdin and not opts.on_data then
            opts.on_stdout = general_on_data
            opts.on_stderr = general_on_data
            opts.on_stdin = general_on_data
            opts.on_data = general_on_data
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
            }
        end
    end
end

return M

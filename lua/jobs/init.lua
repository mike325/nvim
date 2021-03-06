local nvim = require'nvim'
local echoerr = require'tools'.messages.echoerr
local clear_lst = require'tools'.tables.clear_lst

if not nvim.has('nvim-0.5') then
    return false
end

local M ={
    jobs = {},
}

local function general_on_exit(jobid, rc, _)
    local stream
    if rc == 0 then
        print(('Job "%s" finished'):format(M.jobs[jobid].cmd))
        if M.jobs[jobid].qf and M.jobs[jobid].streams and M.jobs[jobid].streams.stdout then
            stream = M.jobs[jobid].streams.stdout
        end
    else
        echoerr(('Job "%s" failed, exited with %s'):format(M.jobs[jobid].cmd, rc))
        if M.jobs[jobid].streams and M.jobs[jobid].streams.stderr then
            stream = M.jobs[jobid].streams.stderr
        end
    end

    if stream then
        local cmdname
        if type(M.jobs[jobid].cmd) == 'table' then
            cmdname = M.jobs[jobid].cmd[0]
        elseif type(M.jobs[jobid].cmd) == 'string' then
            cmdname = vim.split(M.jobs[jobid].cmd, ' ')[1]
        end

        nvim.fn.setqflist(
            {},
            'r',
            {
                contex = M.jobs[jobid].context or cmdname,
                efm = M.jobs[jobid].efm or nvim.o.efm,
                lines = stream,
                title = M.jobs[jobid].title or (rc ~= 0 and cmdname..' exited with '..rc or cmdname..' output'),
            }
        )

        if M.jobs[jobid].qf_open and #stream > 0 then
            local qf = (nvim.o.splitbelow and 'botright' or 'topleft') .. ' copen'
            nvim.command(qf)
        end

        if M.jobs[jobid].qf_jump and #stream > 0 then
            nvim.command('cfirst')
        end

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

        if not opts.on_exit then
            opts.on_exit = general_on_exit
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

        local qf_open
        if job.qf == true and job.qf_open ~= nil then
            qf_open = job.qf_open
        else
            qf_open = false
        end

        local qf_jump
        if job.qf == true and job.qf_jump ~= nil then
            qf_jump = job.qf_jump
        else
            qf_jump = false
        end

        if id > 0 then
            M.jobs[id] = {
                cmd = cmd,
                opts = opts,
                efm = job.efm,
                qf = job.qf,
                qf_open = qf_open,
                qf_jump = qf_jump,
                clean = type(job.clean) ~= 'boolean' and true or job.clean,
            }
        end
    end
end

return M

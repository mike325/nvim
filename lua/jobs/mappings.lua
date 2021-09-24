local nvim = require'neovim'

if not nvim.has('nvim-0.5') then
    return false
end

local set_command = require'neovim.commands'.set_command
local set_mapping = require'neovim.mappings'.set_mapping
-- local set_autocmd = require'neovim.autocmds'.set_autocmd

local jobs = STORAGE.jobs

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
            vim.notify('No jobs to kill', 'WARN', {title='Job Killer'})
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
    rhs = function(_, jobid)
        if jobid == '' then
            jobid = nil
        end
        kill_job(jobid)
    end,
    args = {nargs = '?', bang = true, force = true},
}

set_mapping{
    mode = 'n',
    lhs = '=p',
    rhs = function()
        if not vim.t.progress_win or not vim.api.nvim_win_is_valid(vim.t.progress_win) then
            require'utils'.windows.progress()
        else
            vim.api.nvim_win_close(vim.t.progress_win, true)
        end
    end,
    args = {noremap = true, silent = true}
}

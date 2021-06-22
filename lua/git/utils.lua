-- local nvim = require'nvim'
local executable = require'utils.files'.executable
-- local echowarn = require'utils'.messages.echowarn
-- local is_file = require'utils'.files.is_file
-- local is_dir = require'utils'.files.is_dir
-- local exists = require'utils'.files.exists
-- local writefile = require'utils'.files.writefile
local split = require'utils.strings'.split

if not executable('git') then
    return false
end

-- local set_command = nvim.commands.set_command
-- local set_mapping = nvim.mappings.set_mapping
-- local get_mapping = nvim.mappings.get_mapping

local jobs = require'jobs'

local M = {}

function M.rm_colors(cmd)
    vim.list_extend(cmd, {
        '-c', 'color.ui=off',
        '-c', 'color.branch=off',
        '-c', 'color.interactive=off',
        '-c', 'color.grep=off',
        '-c', 'color.log=off',
        '-c', 'color.diff=off',
        '-c', 'color.status=off',
    })
end

function M.get_git_dir(cmd)
    if vim.b.project_root and vim.b.project_root.is_git then
        vim.list_extend(cmd, {'--git-dir', vim.b.project_root.git_dir})
    end
end

function M.rm_paginate(cmd)
    vim.list_extend(cmd, {'--no-pager'})
end

local function exec_async_gitcmd(cmd, gitcmd, jobopts)
    local opts = jobopts or {pty = true}
    -- if require'sys'.name == 'windows' then
    --     cmd = table.concat(cmd, ' ')
    -- end
    jobs.send_job{
        cmd = cmd,
        save_data = true,
        opts = opts,
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            open = false,
            jump = false,
            context = 'Git '..gitcmd,
            title = 'Git '..gitcmd,
        },
    }
end

local function exec_sync_gitcmd(cmd, gitcmd)
    local ok, output = pcall(vim.fn.system, cmd)
    return ok and output or error('Failed to execute: '..gitcmd..', '..output)
end

function M.get_git_cmd(gitcmd, args)
    local cmd = {'git'}
    M.rm_colors(cmd)
    M.get_git_dir(cmd)
    M.rm_paginate(cmd)
    cmd[#cmd + 1] = gitcmd
    if type(args) == 'table' then
        if vim.tbl_islist(args) then
            vim.list_extend(cmd, args)
        end
    end
    return cmd
end

function M.launch_gitcmd_job(opts)
    assert(type(opts) == 'table', 'Options must be a table')
    assert(type(opts.gitcmd) == 'string' and opts.gitcmd ~= '', 'Invalid gitcmd')
    assert(not opts.args or vim.tbl_islist(opts.args), 'Invalid commad args, must be an array')
    assert(not opts.jobopts or type(opts.jobopts) == 'table', 'Invalid commad job options, must be a table')

    local gitcmd = opts.gitcmd
    local args = opts.args
    local jobopts = opts.jobopts

    local cmd = M.get_git_cmd(gitcmd, args)
    exec_async_gitcmd(cmd, gitcmd, jobopts)
end

local function parse_status(status)
    assert(type(status) == 'string' or vim.tbl_islist(status), 'Invalid status type: '..type(status))
    if type(status) == 'string' then
        status = split(status, '\n')
    end
    local parsed = {}
    for _,gitfile in pairs(status) do
        if not parsed.branch and gitfile:match('^#%s+branch%.head') then
            parsed.branch = split(gitfile, ' ')[3]
        elseif not parsed.upstream and gitfile:match('^#%s+branch%.upstream') then
            parsed.upstream = split(gitfile, ' ')[3]
        elseif gitfile:sub(1, 1) ~= '#' then
            -- parsed.files = parsed.files or {}
            -- local line = split(gitfile, ' ')
            if gitfile:sub(1, 1) == '1' or gitfile:sub(1, 1) == '2' then
                local stage_status = gitfile:sub(3, 3)
                local wt_status = gitfile:sub(4, 4)
                if stage_status == 'A' or stage_status == 'M' or stage_status == 'D' then
                    parsed.stage = parsed.stage or {}
                    local filename = gitfile:sub(114, #gitfile)
                    if stage_status == 'M' then
                        stage_status = 'modified'
                    else
                        stage_status = stage_status == 'A' and 'added' or 'deleted'
                    end
                    parsed.stage[filename] = {status = stage_status}
                    -- parsed.files[filename] = 'staged'
                elseif stage_status == 'R' then
                    parsed.stage = parsed.stage or {}
                    local files = split(gitfile:sub(119, #gitfile), '\t')
                    local filename = files[1]
                    parsed.stage[filename] = {
                        status = 'moved',
                        original = files[2],
                    }
                    -- parsed.files[filename] = 'staged'
                end
                if wt_status == 'M' then
                    parsed.workspace = parsed.workspace or {}
                    local filename = gitfile:sub(114, #gitfile)
                    parsed.workspace[filename] = {
                        status = 'modified',
                    }
                    -- parsed.files[filename] = 'workspace'
                end
            elseif gitfile:sub(1, 1) == '?' then
                parsed.untracked = parsed.untracked or {}
                local filename = gitfile:sub(3, #gitfile)
                parsed.untracked[#parsed.untracked + 1] = filename
                -- parsed.files[filename] = 'untracked'
            -- elseif gitfile:sub(1, 1) == 'u' then  -- TODO
            --     parsed.unmerge = parsed.unmerge or {}
            end
        end
    end
    return parsed
end

function M.status(callback)
    assert(not callback or type(callback) == 'function', 'Invalid callback')

    local gitcmd = 'status'
    local cmd = M.get_git_cmd(gitcmd, {
        '--branch',
        '--porcelain=2'
    })
    if not callback then
        return parse_status(exec_sync_gitcmd(cmd, gitcmd))
    end
    exec_async_gitcmd(cmd, gitcmd, {
        on_exit = function(jobid, rc, _)
            local job = STORAGE.jobs[jobid]
            if rc ~= 0 then
                error(('Failed to get git status, %s'):format(
                    table.concat(job.streams.stderr, '\n')
                ))
            end
            local status = job.streams.stdout
            vim.defer_fn(function() callback(parse_status(status)) end, 0)
        end
    })
end

return M

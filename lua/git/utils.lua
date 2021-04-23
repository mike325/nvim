local nvim = require'nvim'
local executable = require'tools'.files.executable
-- local echowarn = require'tools'.messages.echowarn
-- local is_file = require'tools'.files.is_file
-- local is_dir = require'tools'.files.is_dir
local exists = require'tools'.files.exists
local writefile = require'tools'.files.writefile

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
    if nvim.b.project_root and nvim.b.project_root.is_git then
        vim.list_extend(cmd, {'--git-dir', nvim.b.project_root.git_dir})
    end
end

function M.rm_paginate(cmd)
    vim.list_extend(cmd, {'--no-pager'})
end

local function start_git_cmd(cmd, gitcmd, jobopts)
    local opts = jobopts or {pty = true}
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

function M.exec_git_cmd(gitcmd, args)
    local cmd = {'git'}
    local jobopts
    M.rm_colors(cmd)
    M.get_git_dir(cmd)
    M.rm_paginate(cmd)
    cmd[#cmd + 1] = gitcmd
    if type(args) == 'table' then
        if vim.tbl_islist(args) then
            vim.list_extend(cmd, args)
        else
            if args.gitargs then
                assert(vim.tbl_islist(args.gitargs), 'Invalid args')
                vim.list_extend(cmd, args.gitargs)
            end
            if args.jobopts then
                assert(type(args.jobopts) == 'table', 'Invalid Job args')
                jobopts = args.jobopts
            end
        end
    end
    start_git_cmd(cmd, gitcmd, jobopts)
end

function M.push(args)
    M.exec_git_cmd('push', args)
end

function M.pull(args)
    M.exec_git_cmd('pull', args)
end

function M.add(filename, args)
    filename = filename or nvim.buf.get_name(nvim.get_current_buf())
    if not exists(filename) then
        writefile(filename, nvim.buf.get_lines(nvim.get_current_buf(), 0, -1, true))
    end
    args = args or {}
    vim.list_extend(args, {filename})
    M.exec_git_cmd('add', args)
end

function M.switch(args)
    M.exec_git_cmd('switch', args)
end

function M.reset(args)
    M.exec_git_cmd('reset', args)
end

function M.stash(args)
    M.exec_git_cmd('stash', args)
end

return M

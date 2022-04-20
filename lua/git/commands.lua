local nvim = require 'neovim'
local sys = require 'sys'

local executable = require('utils.files').executable

if not executable 'git' then
    return false
end

local M = {}

function M.rm_commands()
    local commands = {
        'GPush',
        'GPull',
        'GReview',
        'GRead',
        'GFetch',
        'GWrite',
        'GRestore',
        'GRm',
    }

    for _, cmd in ipairs(commands) do
        pcall(nvim.command.del, cmd)
        -- pcall(nvim.command.del, cmd, true)
    end
end

function M.set_commands()
    nvim.command.set('GPull', function(opts)
        local args = opts.fargs
        local utils = require 'git.utils'
        utils.launch_gitcmd_job {
            gitcmd = 'pull',
            args = args,
            progress = true,
            jobopts = {
                pty = true,
                on_exit = function(_, rc)
                    if rc ~= 0 then
                        vim.notify('Failed to pull changes!!', 'ERROR', { title = 'GPull' })
                    else
                        vim.notify('Repo updated!', 'INFO', { title = 'GPull' })
                        nvim.ex.checktime()
                    end
                end,
            },
        }
    end, { nargs = '*' })

    nvim.command.set('GPush', function(opts)
        local args = opts.fargs
        local utils = require 'git.utils'
        utils.launch_gitcmd_job {
            gitcmd = 'push',
            args = args,
            progress = true,
        }
    end, { nargs = '*' })

    nvim.command.set('GFetch', function(opts)
        local args = opts.fargs
        local utils = require 'git.utils'
        utils.launch_gitcmd_job {
            gitcmd = 'fetch',
            args = args,
            progress = true,
        }
    end, { nargs = '*' })

    nvim.command.set('GWrite', function(opts)
        local args = opts.fargs
        local bufname = vim.fn.bufname(nvim.get_current_buf())
        if sys.name == 'windows' then
            bufname = bufname:gsub('\\', '/')
        end
        require('git.utils').status(function(status)
            local utils = require 'git.utils'
            if #args == 0 and (#args > 1 or args[1] ~= '') then
                local workspace = status.workspace or {}
                local untracked = status.untracked or {}

                if workspace[bufname] or vim.tbl_contains(untracked, bufname) then
                    nvim.ex.update() { bufname }
                    utils.launch_gitcmd_job {
                        gitcmd = 'add',
                        args = args,
                        jobopts = {
                            on_exit = function(_, rc)
                                if rc ~= 0 then
                                    vim.notify(
                                        'Failed to Add file: ' .. bufname,
                                        'ERROR',
                                        { title = 'GWrite' }
                                    )
                                end
                            end,
                        },
                    }
                else
                    -- TODO: Improve this, and check for merge conflics
                    vim.notify('Nothing to do', 'INFO', { title = 'GWrite' })
                end
            else
                for i = 1, #args do
                    if args[i] == '%' then
                        require('utils.files').normalize_path(args[i])
                    end
                end
                utils.launch_gitcmd_job {
                    gitcmd = 'add',
                    args = args,
                }
            end
        end)
    end, {
        nargs = '*',
        complete = _completions.gitfiles_workspace,
    })

    nvim.command.set('GRead', function(opts)
        local args = opts.fargs
        require('git.utils').status(function(status)
            local utils = require 'git.utils'
            if #args == 0 and (#args > 1 or args[1] ~= '') then
                local bufname = vim.fn.bufname(nvim.get_current_buf())
                if sys.name == 'windows' then
                    bufname = bufname:gsub('\\', '/')
                end
                if status.stage and status.stage[bufname] then
                    nvim.ex.update()
                    utils.launch_gitcmd_job {
                        gitcmd = 'reset',
                        args = { 'HEAD', bufname },
                        jobopts = {
                            on_exit = function(_, rc)
                                if rc == 0 then
                                    utils.launch_gitcmd_job {
                                        gitcmd = 'checkout',
                                        args = { '--', bufname },
                                        jobopts = {
                                            on_exit = function(_, ec)
                                                if ec ~= 0 then
                                                    vim.notify(
                                                        ('Failed to reset file: %s'):format(bufname),
                                                        'ERROR',
                                                        { title = 'GRead' }
                                                    )
                                                end
                                                nvim.ex.checktime()
                                            end,
                                        },
                                    }
                                else
                                    vim.notify(
                                        ('Failed to unstage file: %s'):format(bufname),
                                        'ERROR',
                                        { title = 'GRead' }
                                    )
                                end
                            end,
                        },
                    }
                elseif status.workspace and status.workspace[bufname] then
                    nvim.ex.update() { '--', bufname }
                    utils.launch_gitcmd_job {
                        gitcmd = 'checkout',
                        args = args,
                    }
                else
                    vim.notify('Nothing to do', 'INFO', { title = 'GRead' })
                end
            else
                vim.notify('This is still WIP', 'WARN', { title = 'GRead' })
                utils.launch_gitcmd_job { gitcmd = 'add', args = args }
            end
        end)
    end, { nargs = '*' })

    nvim.command.set('GRestore', function(opts)
        local args = opts.fargs
        require('git.utils').status(function(status)
            local utils = require 'git.utils'
            if #args == 0 and (#args > 1 or args[1] ~= '') then
                local bufname = vim.fn.bufname(nvim.get_current_buf())
                if sys.name == 'windows' then
                    bufname = bufname:gsub('\\', '/')
                end
                if status.stage and status.stage[bufname] then
                    utils.launch_gitcmd_job {
                        gitcmd = 'reset',
                        args = { 'HEAD', bufname },
                        jobopts = {
                            on_exit = function(_, rc)
                                if rc ~= 0 then
                                    vim.notify(
                                        ('Failed to restore file: %s'):format(bufname),
                                        'ERROR',
                                        { title = 'GRestore' }
                                    )
                                end
                                nvim.ex.checktime()
                            end,
                        },
                    }
                else
                    vim.notify('Nothing to do', 'INFO', { title = 'GRestore' })
                end
            else
                for i = 1, #args do
                    if args[i] == '%' then
                        require('utils.files').normalize_path(args[i])
                    end
                end
                if sys.name == 'windows' then
                    args:gsub('\\', '/')
                end
                utils.launch_gitcmd_job {
                    gitcmd = 'reset',
                    args = vim.list_extend({ 'HEAD' }, args),
                    jobopts = {
                        on_exit = function(_, rc)
                            if rc ~= 0 then
                                error(('Failed to restore file: %s'):format(args))
                            end
                            nvim.ex.checktime()
                        end,
                    },
                }
            end
        end)
    end, { nargs = '?', complete = _completions.gitfiles_stage })

    if packer_plugins and packer_plugins['vim-fugitive'] then
        return
    end

    nvim.command.set('G', function(opts)
        local args = opts.fargs
        vim.validate {
            {
                args,
                function(a)
                    return vim.tbl_islist(a) and #a > 0
                end,
                'array of git arguments',
            },
        }
        local utils = require 'git.utils'
        utils.launch_gitcmd_job {
            gitcmd = args[1],
            args = vim.list_slice(args, 2, #args),
        }
    end, { nargs = '+' })
end

return M

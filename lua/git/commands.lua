local nvim = require'neovim'
local sys  = require'sys'

local executable = require'utils.files'.executable
local echowarn   = require'utils.messages'.echowarn
local echoerr    = require'utils.messages'.echoerr
local echomsg    = require'utils.messages'.echomsg

if not executable('git') then
    return false
end

local plugins = require'neovim'.plugins
local set_command = require'neovim.commands'.set_command
local rm_command = require'neovim.commands'.rm_command

local M = {}

function M.rm_commands()
    rm_command{
        'GPush',
        'GPull',
        'GReview',
        'GRead',
        'GFetch',
        'GWrite',
        'GRestore',
        'GRm',
    }
end

function M.set_commands()

    set_command {
        lhs = 'GPull',
        rhs = function(...)
            local args = {...}
            local utils = RELOAD'git.utils'
            utils.launch_gitcmd_job{
                gitcmd = 'pull',
                args = args,
                progress = true,
                jobopts = {
                    pty = true,
                    on_exit = function(_, rc)
                        if rc ~= 0 then
                            echoerr('Failed to pull changes!!', 'GPull')
                        else
                            echomsg('Repo updated!', 'GPull')
                            nvim.ex.checktime()
                        end
                    end
                }
            }
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GPush',
        rhs = function(...)
            local args = {...}
            local utils = RELOAD'git.utils'
            utils.launch_gitcmd_job{
                gitcmd = 'push',
                args = args,
                progress = true,
            }
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GFetch',
        rhs = function(...)
            local args = {...}
            local utils = RELOAD'git.utils'
            utils.launch_gitcmd_job{
                gitcmd = 'fetch',
                args = args,
                progress = true,
            }
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GWrite',
        rhs = function(...)
            local args = {...}
            local bufname = vim.fn.bufname(nvim.get_current_buf())
            if sys.name == 'windows' then
                bufname = bufname:gsub('\\', '/')
            end
            RELOAD('git.utils').status(function(status)
                local utils = RELOAD'git.utils'
                if #args == 0 then
                    local workspace = status.workspace or {}
                    local untracked = status.untracked or {}
                    local has_attrs  = require'utils.tables'.has_attrs

                    if workspace[bufname] or has_attrs(untracked, bufname) then
                        nvim.ex.update()
                        args = { bufname }
                        utils.launch_gitcmd_job{
                            gitcmd = 'add',
                            args = args,
                            jobopts = {
                                on_exit = function(_, rc)
                                    if rc ~= 0 then
                                        echoerr('Failed to Add file: '..bufname, 'GWrite')
                                    end
                                end
                            }
                        }
                    else
                        -- TODO: Improve this, and check for merge conflics
                        echomsg('Nothing to do', 'GWrite')
                    end
                else
                    for i=1,#args do
                        if args[i] == '%' then
                            args = require'utils.files'.normalize_path(args[i])
                        end
                    end
                    utils.launch_gitcmd_job{
                        gitcmd = 'add',
                        args = args,
                    }
                end
            end)
        end,
        args = {nargs = '*', force = true, buffer = true, complete = [[customlist,neovim#gitfiles_workspace]]}
    }

    set_command {
        lhs = 'GRead',
        rhs = function(...)
            local args = {...}
            RELOAD('git.utils').status(function(status)
                local utils = RELOAD'git.utils'
                if #args == 0 then
                    local bufname = vim.fn.bufname(nvim.get_current_buf())
                    if sys.name == 'windows' then
                        bufname = bufname:gsub('\\', '/')
                    end
                    if status.stage and status.stage[bufname] then
                        nvim.ex.update()
                        utils.launch_gitcmd_job{
                            gitcmd = 'reset',
                            args = {'HEAD', bufname },
                            jobopts = {
                                on_exit = function(_, rc)
                                    if rc == 0 then
                                        utils.launch_gitcmd_job{
                                            gitcmd = 'checkout',
                                            args = {'--', bufname},
                                            jobopts = {
                                                on_exit = function(_, ec)
                                                    if ec ~= 0 then
                                                        echoerr(
                                                            ('Failed to reset file: %s'):format(
                                                                bufname
                                                            ),
                                                            'GRead'
                                                        )
                                                    end
                                                    nvim.ex.checktime()
                                                end
                                            }
                                        }
                                    else
                                        echoerr(
                                            ('Failed to unstage file: %s'):format(
                                                bufname
                                            ),
                                            'GRead'
                                        )
                                    end
                                end
                            }
                        }
                    elseif status.workspace and status.workspace[bufname] then
                        nvim.ex.update()
                        args = {'--', bufname }
                        utils.launch_gitcmd_job{
                            gitcmd = 'checkout',
                            args = args,
                        }
                    else
                        echomsg('Nothing to do', 'GRead')
                    end
                else
                    echowarn('This is still WIP', 'GRead')
                    utils.launch_gitcmd_job{gitcmd = 'add', args = args}
                end
            end)
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GRestore',
        rhs = function(...)
            local args = {...}
            RELOAD('git.utils').status(function(status)
                local utils = RELOAD'git.utils'
                if #args == 0 then
                    local bufname = vim.fn.bufname(nvim.get_current_buf())
                    if sys.name == 'windows' then
                        bufname = bufname:gsub('\\', '/')
                    end
                    if status.stage and status.stage[bufname] then
                        utils.launch_gitcmd_job{
                            gitcmd = 'reset',
                            args = { 'HEAD', bufname },
                            jobopts = {
                                on_exit = function(_, rc)
                                    if rc ~= 0 then
                                        echoerr(
                                            ('Failed to restore file: %s'):format(
                                                bufname
                                            ),
                                            'GRestore'
                                        )
                                    end
                                    nvim.ex.checktime()
                                end
                            }
                        }
                    else
                        echomsg('Nothing to do', 'GRestore')
                    end
                else
                    for i=1,#args do
                        if args[i] == '%' then
                            args = require'utils.files'.normalize_path(args[i])
                        end
                    end
                    if sys.name == 'windows' then
                        args = args:gsub('\\', '/')
                    end
                    utils.launch_gitcmd_job{
                        gitcmd = 'reset',
                        args = vim.list_extend({'HEAD'}, args),
                        jobopts = {
                            on_exit = function(_, rc)
                                if rc ~= 0 then
                                    error(('Failed to restore file: %s'):format(
                                        args
                                    ))
                                end
                                nvim.ex.checktime()
                            end
                        }
                    }
                end
            end)
        end,
        args = {nargs = '?', force = true, complete = [[customlist,neovim#gitfiles_stage]]}
    }

    if plugins['vim-fugitive'] then
        return
    end

    set_command{
        lhs = 'G',
        rhs = function(...)
            local args = {...}
            assert(
                vim.tbl_islist(args) and #args > 0,
                debug.traceback('Invalid args '..vim.inspect(args))
            )
            local utils = RELOAD'git.utils'
            utils.launch_gitcmd_job{
                gitcmd = args[1],
                args = vim.list_slice(args, 2, #args),
            }
        end,
        args = {nargs = '+', force = true}
    }

end

return M

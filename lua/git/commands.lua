local nvim       = require'nvim'

local executable = require'tools'.files.executable
local echowarn   = require'tools'.messages.echowarn
local split      = require'tools'.strings.split
local is_file    = require'tools'.files.is_file
local delete     = require'tools'.files.delete

if not executable('git') then
    return false
end

local set_command = nvim.commands.set_command
-- local set_mapping = nvim.mappings.set_mapping
-- local get_mapping = nvim.mappings.get_mapping

local M = {}

function M.rm_commands()
    local git_cmds = {
        'GPush',
        'GPull',
        'GReview',
        'GRead',
        'GWrite',
        'GRestore',
        'GRm',
    }
    for _,cmd in pairs(git_cmds) do
        if nvim.has.cmd(cmd) then
            set_command { lhs = cmd }
        end
    end
end

function M.set_commands()
    set_command {
        lhs = 'GPull',
        rhs = function(args)
            if args then args = split(args, ' ') end
            local utils = require'git.utils'
            utils.launch_gitcmd_job{gitcmd = 'pull', args = args}
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GPush',
        rhs = function(args)
            if args then args = split(args, ' ') end
            local utils = require'git.utils'
            utils.launch_gitcmd_job{gitcmd = 'push', args = args}
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GWrite',
        rhs = function(args)
            require'git.utils'.status(function(status)
                local utils = require'git.utils'
                if #args == 0 then
                    local bufname = nvim.fn.bufname(nvim.get_current_buf())
                    if status.workspace and status.workspace[bufname] then
                        nvim.ex.update()
                        args = { bufname }
                        utils.launch_gitcmd_job{
                            gitcmd = 'add',
                            args = args,
                            jobopts = {
                                on_exit = function(jobid, rc, _)
                                    if rc ~= 0 then
                                        error('Failed to Add file: '..bufname)
                                    end
                                    nvim.ex.edit()
                                end
                            }
                        }
                    else
                        echowarn('Nothing to do')
                    end
                else
                    if args then args = split(args, ' ') end
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
        rhs = function(args)
            require'git.utils'.status(function(status)
                local utils = require'git.utils'
                if #args == 0 then
                    local bufname = nvim.fn.bufname(nvim.get_current_buf())
                    if status.stage and status.stage[bufname] then
                        nvim.ex.update()
                        utils.launch_gitcmd_job{
                            gitcmd = 'reset',
                            args = {'HEAD', bufname },
                            jobopts = {
                                on_exit = function(jobid, rc, _)
                                    if rc == 0 then
                                        utils.launch_gitcmd_job{
                                            gitcmd = 'checkout',
                                            args = {'--', bufname},
                                            jobopts = {
                                                on_exit = function(id, crc, _)
                                                    if crc ~= 0 then
                                                        error(('Failed to reset file: %s, due to %s'):format(
                                                            bufname,
                                                            table.concat(require'jobs'.jobs[id].streams.stderr, '\n')
                                                        ))
                                                    end
                                                    nvim.ex.checktime()
                                                end
                                            }
                                        }
                                    else
                                        error(('Failed to unstage file: %s, due to %s'):format(
                                            bufname,
                                            table.concat(require'jobs'.jobs[jobid].streams.stderr, '\n')
                                        ))
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
                        echowarn('Nothing to do')
                    end
                -- else
                --     if args then args = split(args, ' ') end
                --     utils.launch_gitcmd_job{gitcmd = 'add', args = args}
                end
            end)
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GRestore',
        rhs = function(args)
            require'git.utils'.status(function(status)
                local utils = require'git.utils'
                if #args == 0 then
                    local bufname = nvim.fn.bufname(nvim.get_current_buf())
                    if status.stage and status.stage[bufname] then
                        utils.launch_gitcmd_job{
                            gitcmd = 'reset',
                            args = { 'HEAD', bufname },
                        }
                    else
                        echowarn('Nothing to do')
                    end
                else
                    utils.launch_gitcmd_job{
                        gitcmd = 'reset',
                        args = {'HEAD', args},
                    }
                end
            end)
        end,
        args = {nargs = '?', force = true, complete = [[customlist,neovim#gitfiles_stage]]}
    }

end

return M

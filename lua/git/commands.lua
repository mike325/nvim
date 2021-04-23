local nvim = require'nvim'
local executable = require'tools'.files.executable
-- local echowarn = require'tools'.messages.echowarn
local split = require'tools'.strings.split
-- local is_file = require'tools'.files.is_file

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
            if args then
                args = split(args, ' ')
            end
            require'git.utils'.exec_git_cmd('pull', args)
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    set_command {
        lhs = 'GPush',
        rhs = function(args)
            if args then
                args = split(args, ' ')
            end
            require'git.utils'.exec_git_cmd('push', args)
        end,
        args = {nargs = '*', force = true, buffer = true}
    }

    -- set_command {
    --     lhs = 'GStageToggle',
    --     rhs = function(args)
    --         require'git.utils'.git_cmd('add', args)
    --     end,
    --     args = {nargs = '*', force = true, buffer = true}
    -- }

end

return M

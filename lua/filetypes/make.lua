local set_command = require'neovim.commands'.set_command

local M = {}

function M.setup()
    set_command{
        lhs = 'Make',
        rhs = function(args)
            args = args or ''
            local Job = require'jobs'
            local make = Job:new{
                cmd = 'make',
                args = vim.split(args, ' '),
                qf = {
                    on_fail = {
                        open = true,
                        jump = false,
                    },
                    context = 'Make',
                    title = 'Make',
                },
            }
            make:start()
            make:progress()
        end,
        args = {nargs = '*', force = true, buffer = true}
    }
end

return M

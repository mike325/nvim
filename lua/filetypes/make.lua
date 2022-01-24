local M = {}

function M.setup()
    local set_command = require('neovim.commands').set_command

    set_command {
        lhs = 'Make',
        rhs = function(...)
            local args = { ... }
            local Job = require 'jobs'
            local make = Job:new {
                cmd = 'make',
                args = args,
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
        args = { nargs = '*', force = true, buffer = true },
    }
end

return M

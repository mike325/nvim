local M = {}
local nvim = require 'nvim'

function M.setup()
    nvim.command.set('MMake', function(opts)
        local args = opts.fargs
        for idx, arg in ipairs(args) do
            args[idx] = vim.fn.expand(arg)
        end
        local Job = require 'jobs'
        local make = Job:new {
            cmd = 'make',
            args = args,
            qf = {
                on_fail = {
                    open = true,
                    jump = false,
                },
                title = 'Make',
            },
        }
        make:start()
        make:progress()
    end, { nargs = '*', buffer = true })
end

return M

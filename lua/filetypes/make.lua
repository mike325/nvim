local M = {}

function M.setup()
    nvim.command.set('Make', function(opts)
        local args = opts.fargs
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
    end, { nargs = '*', buffer = true })
end

return M

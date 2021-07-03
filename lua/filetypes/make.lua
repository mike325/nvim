local set_command = require'neovim.commands'.set_command

local M = {}

function M.setup()
    set_command{
        lhs = 'Makefile',
        rhs = function(args)
            args = args or ''
            local jobs = require'jobs'
            local cmd = {'make'}
            vim.list_extend(cmd, vim.split(args, ' '))
            jobs.send_job{
                cmd = cmd,
                qf = {
                    on_fail = {
                        open = true,
                        jump = false,
                    },
                    open = false,
                    jump = false,
                    context = 'Makefile',
                    title = 'Makefile',
                },
            }
        end,
        args = {nargs = '*', force = true, buffer = true}
    }
end

return M

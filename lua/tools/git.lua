local nvim = require'nvim'
local executable = require'tools.files'.executable

if not executable('git') then
    return false
end

local set_command = nvim.commands.set_command
-- local set_mapping = nvim.mappings.set_mapping
-- local get_mapping = nvim.mappings.get_mapping

local jobs = require'jobs'

local M = {}

local function parse_git_output(jobid, data)
    assert(type(data) == 'string', 'Not valid data: '..type(data))
    local input = ''
    local requested_input = false
    if data:match('^[uU]sername.*') then
        input = nvim.fn.inputsecret('Git username: ')
        requested_input = true
    elseif data:match('^[pP]assword.*') then
        input = nvim.fn.inputsecret('Git password: ')
        requested_input = true
    end

    if input and input ~= '' then
        if input:sub(#input, #input) ~= '\n' then
            input = input .. '\n'
        end
        nvim.fn.chansend(jobid, input)
    elseif requested_input then
        vim.defer_fn(function()
                jobs.kill_job(jobid)
            end,
            1
        )
    end
end

function M.set_commands()
    set_command {
        lhs = 'GPull',
        rhs = function(args)
            local cmd = {'git'}
            if nvim.b.project_root and nvim.b.project_root.is_git then
                vim.list_extend(cmd, {'--git-dir', nvim.b.project_root.git_dir})
            end
            cmd[#cmd + 1] = 'pull'
            if args and args ~= '' then
                cmd[#cmd + 1] = args
            end
            jobs.send_job{
                cmd = cmd,
                save_data = true,
                opts = {
                    pty = true,
                    on_stdout = function(jobid, data, _)
                        -- print('Git data: ', vim.inspect(data))
                        if type(data) == 'table' then
                            for _,val in pairs(data) do
                                parse_git_output(jobid, val)
                            end
                        elseif type(data) == 'string' then
                            parse_git_output(jobid, data)
                        end
                    end
                },
            }

        end,
        args = {nargs = '*', force = true, buffer = true}
    }
end

return M

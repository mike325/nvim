local nvim = require'neovim'
local sys = require'sys'

local executable = require'utils'.files.executable

local plugins = require'neovim'.plugins

local set_command = require'neovim.commands'.set_command
local rm_command = require'neovim.commands'.rm_command

local M = {}

-- local function on_data(jobid, data, event)
--     local job = STORAGE.jobs[jobid]
--     if not job.streams then
--         job.streams = {}
--         job.streams[event] = {}
--     elseif not job.streams[event] then
--         job.streams[event] = {}
--     end

--     if type(data) == 'string' then
--         data = vim.split(data, '[\r]?\n')
--     end

--     vim.list_extend(job.streams[event], data)
-- end

local function parse_diff(output)
    local chunks = {}
    local current_chunk = 0
    for i=3,#output do
        local first,last = output[i]:match('^@@%s+[+-](%d+),(%d+)%s+[+-]%d+,%d+%s+@@$')
        -- print('Matching:', output[i])
        if first then
            current_chunk = current_chunk + 1
            chunks[current_chunk] = {}
            chunks[current_chunk].first = tonumber(first)
            chunks[current_chunk].last = tonumber(first) + tonumber(last)
            print('New chunk:',current_chunk, 'First:',first, 'Last:', chunks[current_chunk].last)
            chunks[current_chunk].lines = {}
        else
            if output[i]:sub(1,1) ~= '-' then
                -- print('New line:', output[i])
                local size = #chunks[current_chunk].lines
                chunks[current_chunk].lines[size + 1] = output[i]:sub(2, #output[i])
            end
        end
    end
    -- print('Chuncks:',vim.inspect(chunks))
    return chunks
end

local function external_formatprg(opts)
    local cmd = opts.cmd
    local buf = nvim.get_current_buf()

    local Job = RELOAD'job'
    local formatprg = Job:new{
        cmd = cmd,
        qf = {
            on_fail = {
                open = true,
                jump = false,
            },
            context = 'PyFormat',
            title = 'PyFormat',
        },
        opts = {
            on_exit = function(job, rc)
                if rc == 0 or rc == 1 then
                    local stdout = job:stdout()
                    if #stdout > 0 then
                        local chunks = parse_diff(stdout)
                        for _,chunk in pairs(chunks) do
                            local first = chunk.first
                            local last = chunk.last
                            local lines = chunk.lines
                            nvim.buf.set_lines(buf, first, last, false, lines)
                        end
                    else
                        require'utils'.messages.echowarn(
                            'We should not be here, no format was detected',
                            'FormatPrg'
                        )
                    end
                else
                    require'utils'.messages.echoerr(
                        ('Failed to format code chunk, %s exited with code %s'):format(
                            job.exe,
                            rc
                        ),
                        'FormatPrg'
                    )
                end
            end,
        },
    }
    formatprg:start()
end

function M.format()
    local first = vim.v.lnum
    local last = first + vim.v.count
    local bufname = nvim.buf.get_name(0)
    -- local mode = nvim.get_mode()

    -- print('First:',first, 'Last:',last)

    if executable('yapf') then
        external_formatprg({
            cmd = {
                'yapf',
                '-d',
                '-l',
                first..'-'..last,
                '--style',
                'pep8',
                bufname,
            },
            first = first,
            last = last,
        })
    elseif executable('autopep8') then
        -- local cmd =
        external_formatprg({
            cmd = {
                'autopep8',
                '--diff',
                '--experimental',
                '--aggressive',
                '--max-line-length',
                '120',
                '--range',
                first,
                last,
                bufname,
            },
        })
    else
        -- Fallback to internal formater
        return 1
    end

    return 0
end

function M.setup()
    vim.opt_local.formatexpr = [[luaeval('require\"filetypes.python\".format()')]]

    if executable('flake8') then
        local cmd = {'flake8'}
        local global_settings = vim.fn.expand( sys.name == 'windows' and '~/.flake8' or '~/.config/flake8' )

        local is_file = require'utils'.files.is_file

        if not is_file(global_settings) and
           not is_file('./tox.ini') and
           not is_file('./.flake8') and
           not is_file('./setup.cfg') then
            vim.list_extend(cmd, {'--max-line-length=120', '--ignore=E203,E226,E231,E261,E262,E265,E302,W391'})
        end
        table.insert(cmd, '%')

        vim.opt_local.makeprg = table.concat(cmd, ' ')
        vim.opt_local.errorformat = '%f:%l:%c: %t%n %m'

    elseif executable('pycodestyle') then
        vim.opt_local.makeprg = 'pycodestyle --max-line-length=120 --ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203,E27 %'
        vim.opt_local.errorformat = '%f:%l:%c: %t%n %m'
    else
        vim.opt_local.makeprg = [[python3 -c "import py_compile,sys; sys.stderr=sys.stdout; py_compile.compile(r'%')"]]
        vim.opt_local.errorformat = '%C %.%#,%A  File "%f", line %l%.%#,%Z%[%^ ]%@=%m'
    end

    if not plugins['vim-apathy'] then
        local buf = nvim.get_current_buf()
        local merge_uniq_list = require'utils'.tables.merge_uniq_list

        if not vim.b.python_path then
            -- local pypath = {}
            local Job = RELOAD'jobs'
            local pyprog = vim.g.python3_host_prog or vim.g.python_host_prog or (executable('python3') and 'python3')

            local get_path = Job:new{
                cmd = pyprog,
                args = {'-c', 'import sys; print(",".join(sys.path), flush=True)'},
                silent = true,
            }
            get_path:callback_on_success(function(job)
                -- NOTE: output is an array of stdout lines, we must join the array in a str
                --       split it into a single array
                local output = vim.split(table.concat(job:output(), ','), ',')
                -- BUG: No idea why this fails
                -- local path = vim.split(vim.api.nvim_buf_get_option(buf, 'path'), ',')
                local path = vim.opt_local.path:get()
                if type(path) == type('') then
                    path = vim.split(path, ',')
                end
                path = merge_uniq_list(path, output)
                vim.api.nvim_buf_set_option(buf, 'path', table.concat(path, ','))
            end)
            get_path:start()
        else
            assert(
                type(vim.b.python_path) == type('') or type(vim.b.python_path) == type({}),
                debug.traceback('b:python_path must be either a string or list')
            )
            if type(vim.b.python_path) == type('')  then
                vim.b.python_path = vim.split(vim.b.python_path, ',')
            end
            local path = vim.split(vim.api.nvim_buf_get_option(buf, 'path'), ',')
            path = merge_uniq_list(path, vim.b.python_path)
            vim.api.nvim_buf_set_option(buf, 'path', table.concat(path, ','))
        end
    end
end

function M.pynvim_setup()
    -- NOTE: This should speed up startup times
    -- lets just asume that if we have this two, any user could install pynvim
    if executable('python3') and executable('pip3') then
        vim.g.python3_host_prog = vim.fn.exepath('python3')
        vim.g.loaded_python_provider = 0
    end
end

return M

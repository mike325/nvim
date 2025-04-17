local nvim = require 'nvim'
local sys = require 'sys'

local is_file = require('utils.files').is_file
local executable = require('utils.files').executable
local iswin = sys.name == 'windows'

local plugins = require('nvim').plugins

local line_length = '120'
local M = {
    formatprg = {
        black = {
            '-l',
            line_length,
            efm = {
                '%trror: cannot format %f: Cannot parse %l:c: %m',
                '%trror: cannot format %f: %m',
            },
        },
        ruff = {
            'format',
            '--line-length=' .. line_length,
        },
        autopep8 = {
            '-i',
            '--experimental',
            '--aggressive',
            '--max-line-length',
            line_length,
        },
        yapf = {
            '-i',
            '--style',
            'pep8',
        },
        isort = {
            '--line-length',
            line_length,
            '--profile=black',
            -- '--trailing-comma'
        },
    },
    makeprg = {
        mypy = {
            efm = {
                '%f:%l: %trror: %m',
                '%f:%l: %tarning: %m',
                '%f:%l: %tote: %m',
                '%f: %trror: %m',
                '%f: %tarning: %m',
                '%f: %tote: %m',
                '%f:%l:%c: %t%n %m',
                '%f:%l:%c:%t: %m',
                '%f:%l:%c: %m',
            },
        },
        ruff = {
            'check',
            '--respect-gitignore',
            '--line-length=' .. line_length,
        },
        flake8 = {
            '--max-line-length=' .. line_length,
            '--ignore=' .. table.concat({
                'E203', -- Whitespace before :
                'E226', -- Whitespace around operators
                'E231', -- Missing whitespace after ','
                'E261', -- 2 spaces before inline comment
                'E262', -- Comments should start with '#'
                'E265', -- Block comment should start with '#'
                'E302', -- Expected 2 lines between funcs/classes
                'W391', -- Blank line and the EOF
            }, ','),
        },
        pycodestyle = {}, -- NOTE: Same values as flake8
        pylint = {
            '--disable=C0413,R0205,E0401,C0103',
            efm = {
                '%f:%l:%c: %t%n: %m',
                '%f:%l:%c: %t%n %m',
                '%f:%l:%c:%t: %m',
                '%f:%l:%c: %m',
            },
        },
    },
}

vim.list_extend(M.makeprg.pycodestyle, M.makeprg.flake8)

function M.get_formatter(stdin)
    local cmd

    if executable 'ruff' then
        cmd = { 'ruff', 'format' }
        local config_file = RELOAD('utils.buffers').find_config {
            configs = {
                'ruff.toml',
                '.ruff.toml',
                'pyproject.toml',
            },
        }

        if config_file then
            vim.list_extend(cmd, { '--config', config_file })
        else
            vim.list_extend(cmd, M.makeprg[cmd[1]])
        end
    else
        local config_file = RELOAD('utils.buffers').find_config { configs = 'pyproject.toml' }
        if executable 'black' then
            cmd = { 'black' }
            if not config_file then
                vim.list_extend(cmd, M.formatprg[cmd[1]])
            else
                vim.list_extend(cmd, { '--config', config_file })
            end
        elseif executable 'yapf' or executable 'autopep8' then
            cmd = { executable 'yapf' and 'yapf' or 'autopep8' }
            if not config_file then
                vim.list_extend(cmd, M.formatprg[cmd[1]])
            else
                table.insert(cmd, '-i')
            end
        end
    end

    return cmd
end

-- TODO: Python benefits from multiple linter, get_linter may be change to support return
--       either an iterator or a dictionary of linters
function M.get_linter()
    local cmd
    if executable 'ruff' then
        cmd = { 'ruff', 'check' }
        local config_file = RELOAD('utils.buffers').find_config {
            configs = {
                'ruff.toml',
                '.ruff.toml',
                'pyproject.toml',
            },
        }

        if not config_file then
            vim.list_extend(cmd, M.makeprg[cmd[1]])
        else
            vim.list_extend(cmd, { '--config', config_file })
        end
    elseif executable 'flake8' then
        cmd = { 'flake8' }
        local global_config = vim.fs.normalize(iswin and '~/.flake8' or '~/.config/flake8')
        local config_file = RELOAD('utils.buffers').find_config {
            configs = {
                'tox.ini',
                '.flake8',
                'setup.cfg',
            },
        }

        if not is_file(global_config) and not config_file then
            vim.list_extend(cmd, M.makeprg[cmd[1]])
        end
    elseif executable 'pycodestyle' then
        cmd = { 'pycodestyle' }
        vim.list_extend(cmd, M.makeprg[cmd[1]])
        -- else
        --     cmd = {'python3', '-c', [["import py_compile,sys; sys.stderr=sys.stdout; py_compile.compile(r'%')"]]}
    end

    return cmd
end

function M.setup()
    if not executable 'python3' and not executable 'python' then
        return
    end

    vim.validate {
        python_path = { vim.b.python_path, { 'string', 'table' }, true },
    }

    if not plugins['vim-apathy'] then
        local buf = nvim.get_current_buf()
        local merge_uniq_list = require('utils.tables').merge_uniq_list

        local function update_buffer_path(paths)
            if vim.b.python_path then
                if type(vim.b.python_path) == type '' then
                    vim.b.python_path = vim.split(vim.b.python_path, ',')
                end
                paths = merge_uniq_list(paths, vim.b.python_path)
            end

            vim.bo[buf].path = table.concat(paths, ',')
        end

        local pyprog
        local shebang = vim.api.nvim_buf_get_lines(buf, 0, 1, true)[1]
        if shebang and shebang:match '^#!' then
            pyprog = vim.split((shebang:gsub('^#!', '')), ' ', { trimempty = true })
        end

        if not pyprog or not is_file(pyprog[1]) then
            for _, exec in ipairs { 'python3', 'python2', 'python' } do
                if executable(exec) then
                    pyprog = { exec }
                    break
                end
            end
        end

        if pyprog then
            local cmd = vim.list_extend(pyprog, { '-c', 'import sys; print(",".join(sys.path))' })
            local get_path = RELOAD('jobs'):new {
                cmd = cmd,
                silent = true,
                callbacks_on_success = function(job)
                    -- NOTE: output is an array of stdout lines, we must join the array in a str
                    --       split it into a single array
                    local output = vim.split(table.concat(job:output(), ','), ',')
                    local path = vim.opt_local.path:get()
                    if type(path) == type '' then
                        path = vim.split(path, ',')
                    end
                    update_buffer_path(merge_uniq_list(path, output))
                end,
            }
            get_path:start()
        elseif vim.env.PYTHONPATH then
            local paths = vim.split(vim.env.PYTHONPATH, iswin and ';' or ':')
            update_buffer_path(paths)
        end
    end
end

function M.pynvim_setup()
    -- NOTE: This should speed up startup times
    -- lets just assume that if we have this two, any user could install pynvim
    if executable 'python3' and executable 'pip3' then
        vim.g.python3_host_prog = vim.fn.exepath 'python3'
        vim.g.loaded_python_provider = 0
    elseif executable 'python2' and executable 'pip2' then
        vim.g.python_host_prog = vim.fn.exepath 'python2'
        vim.g.loaded_python3_provider = 0
    else
        vim.g.loaded_python_provider = 0
        vim.g.loaded_python3_provider = 0
    end
end

return M

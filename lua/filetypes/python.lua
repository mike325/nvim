local nvim = require 'neovim'
local sys = require 'sys'

local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath
local executable = require('utils.files').executable

local plugins = require('neovim').plugins

local M = {
    pyignores = {
        -- 'E121', --
        -- 'E123', --
        -- 'E126', --
        'E203', -- Whitespace before :
        -- 'E221', --
        'E226', -- Whitespace around operators
        -- 'E228', --
        'E231', -- Missing whitespace after ','
        -- 'E24',  --
        -- 'E251', --
        'E261', -- 2 spaces before inline comment
        'E262', -- Comments should start with '#'
        'E265', -- Block comment should start with '#'
        -- 'E27',  --
        'E302', -- Expected 2 lines between funcs/classes
        -- 'E501', --
        -- 'E701', --
        -- 'E704', --
        -- 'H233', --
        'W391', -- Blank line and the EOF
        -- 'W503', --
        -- 'W504', --
    },
    formatprg = {
        black = {
            '-l',
            '120',
            efm = '%trror: cannot format %f: Cannot parse %l:c: %m,%trror: cannot format %f: %m',
        },
        autopep8 = {
            '-i',
            '--experimental',
            '--aggressive',
            '--max-line-length',
            '120',
        },
        yapf = {
            '-i',
            '--style',
            'pep8',
        },
    },
    makeprg = {},
}

M.makeprg.flake8 = { '--max-line-length=120', '--ignore=' .. table.concat(M.pyignores, ',') }
M.makeprg.pycodestyle = M.makeprg.flake8

function M.get_formatter()
    local project = vim.fn.findfile('pyproject.toml', '.;')
    project = project ~= '' and realpath(project) or nil

    local cmd
    if executable 'black' then
        cmd = { 'black' }
        if not project then
            vim.list_extend(cmd, M.formatprg[cmd[1]])
        else
            vim.list_extend(cmd, { '--config', project })
        end
    elseif executable 'yapf' or executable 'autopep8' then
        cmd = { executable 'yapf' and 'yapf' or 'autopep8' }
        if not project then
            vim.list_extend(cmd, M.formatprg[cmd[1]])
        else
            table.insert(cmd, '-i')
        end
    end

    return cmd
end

function M.get_linter()
    local cmd
    if executable 'flake8' then
        cmd = { 'flake8' }
        local global_settings = vim.fn.expand(sys.name == 'windows' and '~/.flake8' or '~/.config/flake8')

        if
            not is_file(global_settings)
            and not is_file './tox.ini'
            and not is_file './.flake8'
            and not is_file './setup.cfg'
            -- and not is_file './setup.py'
            -- and not is_file './pyproject.toml'
        then
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
    if not plugins['vim-apathy'] then
        local buf = nvim.get_current_buf()
        local merge_uniq_list = require('utils.tables').merge_uniq_list

        if not vim.b.python_path then
            -- local pypath = {}
            local pyprog = vim.g.python3_host_prog
                or vim.g.python_host_prog
                or (executable 'python3' and 'python3')

            local get_path = RELOAD('jobs'):new {
                cmd = pyprog,
                args = { '-c', 'import sys; print(",".join(sys.path), flush=True)' },
                silent = true,
            }
            get_path:callback_on_success(function(job)
                -- NOTE: output is an array of stdout lines, we must join the array in a str
                --       split it into a single array
                local output = vim.split(table.concat(job:output(), ','), ',')
                -- BUG: No idea why this fails
                -- local path = vim.split(vim.api.nvim_buf_get_option(buf, 'path'), ',')
                local path = vim.opt_local.path:get()
                if type(path) == type '' then
                    path = vim.split(path, ',')
                end
                merge_uniq_list(path, output)
                vim.api.nvim_buf_set_option(buf, 'path', table.concat(path, ','))
            end)
            get_path:start()
        else
            assert(
                type(vim.b.python_path) == type '' or type(vim.b.python_path) == type {},
                debug.traceback 'b:python_path must be either a string or list'
            )
            if type(vim.b.python_path) == type '' then
                vim.b.python_path = vim.split(vim.b.python_path, ',')
            end
            local path = vim.split(vim.api.nvim_buf_get_option(buf, 'path'), ',')
            merge_uniq_list(path, vim.b.python_path)
            vim.api.nvim_buf_set_option(buf, 'path', table.concat(path, ','))
        end
    end

    nvim.command.set('Execute', function(cmd_opts)
        local exepath = vim.fn.exepath

        local buffer = nvim.buf.get_name(nvim.get_current_buf())
        local filename = is_file(buffer) and buffer or vim.fn.tempname()

        if not is_file(buffer) then
            require('utils.files').writefile(filename, nvim.buf.get_lines(0, 0, -1, true))
        end

        local opts = {
            cmd = executable 'python3' and exepath 'python3' or exepath 'python',
            {
                '-u',
                filename,
            },
        }
        vim.list_extend(opts.args, cmd_opts.fargs)
        require('utils.functions').async_execute(opts)
    end, { nargs = '*', buffer = true })
end

function M.pynvim_setup()
    -- NOTE: This should speed up startup times
    -- lets just asume that if we have this two, any user could install pynvim
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

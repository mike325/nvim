local nvim = require 'neovim'

local executable = require('utils.files').executable
local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath

local compile_flags = STORAGE.compile_flags
local databases = STORAGE.databases
local has_cjson = STORAGE.has_cjson

local set_command = require('neovim.commands').set_command

local M = {
    makeprg = {
        ['clang-tidy'] = {
            efm = '%E%f:%l:%c: fatal error: %m,%E%f:%l:%c: error: %m,%W%f:%l:%c: warning: %m',
        },
        ['clang++'] = {
            '-std=c++17',
            '-O3',
            '-Wall',
            '-Wextra',
            '-Wshadow',
            '-Wnon-virtual-dtor',
            '-Wold-style-cast',
            '-Wcast-align',
            '-Wunused',
            '-Woverloaded-virtual',
            '-Wpedantic',
            '-Wconversion',
            '-Wsign-conversion',
            '-Wnull-dereference',
            '-Wdouble-promotion',
            '-Wformat=2',
        },
        ['g++'] = {
            '-std=c++17',
            '-O3',
            '-Wall',
            '-Wextra',
            '-Wno-c++98-compat',
            '-Wshadow',
            '-Wnon-virtual-dtor',
            '-Wold-style-cast',
            '-Wcast-align',
            '-Wunused',
            '-Woverloaded-virtual',
            '-Wpedantic',
            '-Wconversion',
            '-Wsign-conversion',
            '-Wnull-dereference',
            '-Wdouble-promotion',
            '-Wmisleading-indentation',
            '-Wduplicated-cond',
            '-Wduplicated-branches',
            '-Wlogical-op',
            '-Wuseless-cast',
            '-Wformat=2',
        },
        clang = {
            '-std=c11',
            '-O3',
            '-Wall',
            '-Wextra',
            '-Wshadow',
            '-Wnon-virtual-dtor',
            '-Wold-style-cast',
            '-Wcast-align',
            '-Wunused',
            '-Woverloaded-virtual',
            '-Wpedantic',
            '-Wno-missing-prototypes',
            '-Wconversion',
            '-Wsign-conversion',
            '-Wnull-dereference',
            '-Wdouble-promotion',
            '-Wformat=2',
        },
        gcc = {
            '-std=c11',
            '-O3',
            '-Wall',
            '-Wextra',
            '-Wshadow',
            '-Wnon-virtual-dtor',
            '-Wold-style-cast',
            '-Wcast-align',
            '-Wunused',
            '-Woverloaded-virtual',
            '-Wpedantic',
            '-Wno-missing-prototypes',
            '-Wconversion',
            '-Wsign-conversion',
            '-Wnull-dereference',
            '-Wdouble-promotion',
            '-Wmisleading-indentation',
            '-Wduplicated-cond',
            '-Wduplicated-branches',
            '-Wlogical-op',
            '-Wuseless-cast',
            '-Wformat=2',
        },
    },
    formatprg = {
        ['clang-format'] = {
            '--style=file',
            '--fallback-style=WebKit',
        },
    },
}

local compilers = {
    c = {
        'clang',
        'gcc',
    },
    cpp = {
        'clang++',
        'g++',
    },
}

local env = {
    c = 'CC',
    cpp = 'CXX',
}

local function get_compiler()
    local ft = vim.bo.filetype

    -- safe check
    if not compilers[ft] then
        return
    end

    if vim.env[env[ft]] and executable(vim.env[env[ft]]) then
        return vim.env[env[ft]]
    end

    local compiler
    for _, exe in pairs(compilers[ft]) do
        if executable(exe) then
            compiler = exe
            break
        end
    end
    return compiler
end

local function get_args(compiler, bufnum, compiler_flags_file)
    local bufname = realpath(nvim.buf.get_name(bufnum))
    local args

    if is_file(bufname) then
        if databases[bufname] then
            args = databases[bufname].args
        elseif
            compiler_flags_file
            and compile_flags[compiler_flags_file]
            and compile_flags[compiler_flags_file].args
        then
            args = compile_flags[compiler_flags_file].args
        end
    end

    return args or M.makeprg[compiler] or {}
end

local function set_opts(filename, has_tidy, compiler, bufnum)
    local bufname = nvim.buf.get_name(bufnum)
    local merge_uniq_list = require('utils.tables').merge_uniq_list

    if is_file(bufname) and databases[realpath(bufname)] then
        bufname = realpath(bufname)
        vim.api.nvim_buf_set_option(
            bufnum,
            'makeprg',
            ('%s %s %%'):format(databases[bufname].compiler, table.concat(databases[bufname].args, ' '))
        )
        local has_local, path = pcall(vim.api.nvim_buf_get_option, bufnum, 'path')
        if not has_local then
            path = vim.api.nvim_get_option 'path'
        end
        path = vim.split(path, ',')
        table.insert(path, '.')
        path = merge_uniq_list(databases[bufname].includes, path)
        vim.api.nvim_buf_set_option(bufnum, 'path', table.concat(path, ',') .. ',')
        return
    end
    if filename and compile_flags[filename] then
        if #compile_flags[filename].includes > 0 then
            -- BUG: Seems to fail and abort if we call this too early in nvim startup
            local has_local, path = pcall(vim.api.nvim_buf_get_option, bufnum, 'path')
            if not has_local then
                path = vim.api.nvim_get_option 'path'
            end
            path = vim.split(path, ',')
            table.insert(path, '.')
            path = merge_uniq_list(compile_flags[filename].includes, path)
            vim.api.nvim_buf_set_option(bufnum, 'path', table.concat(path, ',') .. ',')
        end

        if #compile_flags[filename].flags > 0 and not has_tidy then
            local config_flags = table.concat(compile_flags[filename].flags, ' ')
            vim.api.nvim_buf_set_option(
                bufnum,
                'makeprg',
                ('%s %s -o %s %%'):format(compiler, config_flags, vim.fn.tempname())
            )
        end
    elseif not has_tidy then
        local config_flags = table.concat(M.makeprg[compiler] or {}, ' ')
        vim.api.nvim_buf_set_option(
            bufnum,
            'makeprg',
            ('%s %s -o %s %%'):format(compiler, config_flags, vim.fn.tempname())
        )
    end
end

local function parse_includes(args)
    local includes = {}
    local include = false
    for _, arg in pairs(args) do
        if arg == '-isystem' or arg == '-I' or arg == '/I' then
            include = true
        elseif include then
            table.insert(includes, arg)
            include = false
        elseif #arg > 2 and (arg:sub(1, 2) == '-I' or arg:sub(1, 2) == '/I') then
            local path = arg:sub(3, #arg):gsub('^%s+', '')
            table.insert(includes, path)
        end
    end
    return includes
end

local function parse_compiledb(data)
    vim.validate { data = { data, 'string' } }
    local json = require('utils.files').decode_json(data)
    for _, source in pairs(json) do
        local source_name
        if not source.file:match '/' then
            source_name = source.directory .. '/' .. source.file
        else
            source_name = source.file
        end
        if not databases[source_name] then
            local args
            if source.arguments then
                args = source.arguments
            elseif source.command then
                args = vim.split(source.command, ' ')
            end
            databases[source_name] = {}
            databases[source_name].filename = source_name
            databases[source_name].compiler = args[1]
            databases[source_name].args = vim.list_slice(args, 2, #args)
            databases[source_name].includes = parse_includes(databases[source_name].args)
        end
    end
end

function M.get_formatter()
    local cmd
    if executable 'clang-format' then
        cmd = { 'clang-format' }
        local config = vim.fn.findfile('.clang-format', '.;')
        if config ~= '' then
            vim.list_extend(cmd, M.formatprg[cmd[1]])
            -- cmd = require('utils.buffers').replace_indent(cmd)
        end
        table.insert(cmd, '-i')
    end
    return cmd
end

function M.setup()
    local compiler = get_compiler()
    if not compiler then
        return
    end

    local bufnum = nvim.get_current_buf()
    local bufname = nvim.buf.get_name(bufnum)
    local normalize_path = require('utils.files').normalize_path

    local cwd
    if bufname and bufname ~= '' and is_file(bufname) then
        cwd = require('utils.files').basedir(bufname)
    else
        cwd = require('utils.files').getcwd()
    end

    local flags_file = vim.fn.findfile('compile_flags.txt', cwd .. ';')
    local db_file = vim.fn.findfile('compile_commands.json', cwd .. ';')
    local clang_tidy = vim.fn.findfile('.clang-tidy', cwd .. ';')

    -- local makefile = vim.fn.findfile('Makefile', cwd..';')
    local cmake = vim.fn.findfile('CMakeLists.txt', cwd .. ';')

    if executable 'make' then
        RELOAD('filetypes.make').setup()
    end

    if cmake ~= '' and executable 'cmake' then
        RELOAD('filetypes.cmake').setup()
    end

    local has_tidy = false
    if executable 'clang-tidy' and (flags_file ~= '' or db_file ~= '' or clang_tidy ~= '') then
        has_tidy = true
        local tidy = M.makeprg['clang-tidy']
        vim.bo.makeprg = table.concat(tidy, ' ') .. ' %'
        vim.bo.errorformat = tidy.efm
    end

    local filename
    if db_file ~= '' then
        filename = realpath(normalize_path(db_file))
        if is_file(bufname) and not databases[realpath(bufname)] then
            -- bufname = realpath(bufname)
            readfile(db_file, false, function(data)
                if has_cjson == true then
                    parse_compiledb(data)
                    vim.schedule(function()
                        set_opts(filename, has_tidy, compiler, bufnum)
                    end)
                else
                    vim.schedule(function()
                        parse_compiledb(data)
                        set_opts(filename, has_tidy, compiler, bufnum)
                    end)
                end
            end)
        else
            set_opts(filename, has_tidy, compiler, bufnum)
        end
    elseif flags_file ~= '' then
        filename = realpath(normalize_path(flags_file))
        if not compile_flags[filename] then
            readfile(filename, true, function(data)
                if data and #data > 0 then
                    compile_flags[filename] = {
                        flags = {},
                        includes = {},
                    }
                    for _, line in pairs(data) do
                        if line:sub(1, 1) == '-' or line:sub(1, 1) == '/' then
                            table.insert(compile_flags[filename].flags, line)
                        end
                        if line:sub(1, 2) == '-I' or line:sub(1, 2) == '/I' then
                            local path = line:sub(3, #line):gsub('^%s+', '')
                            table.insert(compile_flags[filename].includes, path)
                        end
                    end
                    vim.schedule(function()
                        set_opts(filename, has_tidy, compiler, bufnum)
                    end)
                end
            end)
        else
            set_opts(filename, has_tidy, compiler, bufnum)
        end
    elseif not has_tidy then
        -- NOTE: We need to call this multiple times since readfile can be async
        set_opts(nil, has_tidy, compiler, bufnum)
    end

    -- BUG: This only build once, giving linking errors in further calls, needs debug
    set_command {
        lhs = 'BuildProject',
        rhs = function(...)
            local buffer = nvim.buf.get_name(nvim.get_current_buf())
            local base_cwd = require('utils.files').getcwd()
            local ft = vim.bo.filetype

            if not is_file(buffer) then
                vim.notify('Current buffer is not a file', 'ERROR', { title = 'Execute' })
                return false
            end

            local compile_output = base_cwd .. '/build/main'
            local args, compiler_flags_file

            if flags_file ~= '' then
                compiler_flags_file = realpath(normalize_path(flags_file))
            end

            args = get_args(compiler, nvim.get_current_buf(), compiler_flags_file)
            vim.list_extend(args, { '-o', compile_output })

            require('utils.files').find_files(base_cwd, '*.' .. ft, function(job)
                vim.list_extend(args, job:output())

                if not require('utils.files').is_dir 'build' then
                    require('utils.files').mkdir 'build'
                end

                P(('%s %s'):format(compiler, table.concat(args, ' ')))

                local build = RELOAD('jobs'):new {
                    cmd = compiler,
                    args = args,
                    progress = true,
                    opts = {
                        cwd = require('utils.files').getcwd(),
                        -- pty = true,
                    },
                    qf = {
                        dump = false,
                        on_fail = {
                            jump = true,
                            open = true,
                            dump = true,
                        },
                        context = 'BuildProject',
                        title = 'BuildProject',
                    },
                }

                build:callback_on_success(function(_)
                    local execute = RELOAD('jobs'):new {
                        cmd = compile_output,
                        progress = true,
                        verify_exec = false,
                        opts = {
                            cwd = require('utils.files').getcwd(),
                            -- pty = true,
                        },
                        qf = {
                            dump = false,
                            on_fail = {
                                jump = true,
                                open = true,
                                dump = true,
                            },
                            context = 'ExecuteProject',
                            title = 'ExecuteProject',
                        },
                    }
                    execute:start()
                    execute:progress()
                end)

                build:start()
                build:progress()
            end)
        end,
        args = { nargs = '*', force = true, buffer = true },
    }
end

return M

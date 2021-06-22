local nvim = require'nvim'

local getcwd         = require'utils.files'.getcwd
local executable     = require'utils.files'.executable
local readfile       = require'utils.files'.readfile
local is_file        = require'utils.files'.is_file
local basedir        = require'utils.files'.basedir
local realpath       = require'utils.files'.realpath
local decode_json    = require'utils.files'.decode_json
local normalize_path = require'utils.files'.normalize_path

local compile_flags = STORAGE.compile_flags
local databases = STORAGE.databases

local has_cjson = STORAGE.has_cjson

local M = {}

local compilers = {
    c = {
        'clang',
        'gcc',
    },
    cpp = {
        'clang++',
        'g++',
    }
}

local default_flags = {
    ['clang++'] = {
        '-S',
        '-std=c++17',
        '-Wall',
        '-Wextra',
        '-Weverything',
        '-Wno-c++98-compat',
        '-Wpedantic',
        '-Wno-missing-prototypes',
    },
    ['g++'] = {
        '-S',
        '-std=c++17',
        '-Wall',
        '-Wextra',
        '-Wpedantic',
    },
    clang = {
        '-S',
        '-Wall',
        '-Wextra',
        '-Weverything',
        '-Wno-missing-prototypes',
        '-Wpedantic',
    },
    gcc = {
        '-S',
        '-Wall',
        '-Wextra',
        '-Wpedantic',
    },
}

local function get_compiler()
    local ft = vim.bo.filetype
    local compiler
    for _,exe in pairs(compilers[ft]) do
        if executable(exe) then
            compiler = exe
            break
        end
    end
    return compiler
end

local function set_opts(filename, has_tidy, compiler, bufnum)
    local bufname = nvim.buf.get_name(bufnum)
    if is_file(bufname) and databases[realpath(bufname)] then
        bufname = realpath(bufname)
        vim.api.nvim_buf_set_option(
            bufnum,
            'path',
            '.,,'..table.concat(databases[bufname].includes, ',')
        )
        vim.api.nvim_buf_set_option(
            bufnum,
            'makeprg',
            ('%s %s %%'):format(
                databases[bufname].compiler,
                table.concat(databases[bufname].args, ' ')
            )
        )
        return
    end
    if filename and compile_flags[filename] then
        if #compile_flags[filename].includes > 0 then
            vim.api.nvim_buf_set_option(
                bufnum,
                'path',
                '.,,'..table.concat(compile_flags[filename].includes, ',')
            )
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
        local config_flags = table.concat(default_flags[compiler], ' ')
        vim.api.nvim_buf_set_option(
            bufnum,
            'makeprg',
            ('%s %s -o %s %%'):format(compiler, config_flags, vim.fn.tempname())
        )
    end
end

local function parse_includes(args)
    local includes = {}
    for _, arg in pairs(args) do
        if arg:sub(1, 2) == '-I' or arg:sub(1, 2) == '/I' then
            local path = arg:sub(3, #arg):gsub('^%s+', '')
            table.insert(includes, path)
        end
    end
    return includes
end

local function parse_compiledb(data)
    assert(type(data) == type(''), 'Invalid data: '..vim.inspect(data))
    local json = decode_json(data)
    for _, source in pairs(json) do
        local source_name = source.directory..'/'..source.file
        if not databases[source_name] then
            databases[source_name] = {}
            databases[source_name].filename = source_name
            databases[source_name].compiler = source.arguments[1]
            databases[source_name].args = vim.list_slice(source.arguments, 2, #source.arguments)
            databases[source_name].includes = parse_includes(databases[source_name].args)
        end
    end
end

function M.setup()
    local compiler = get_compiler()
    local bufnum = nvim.get_current_buf()
    local bufname = nvim.buf.get_name(bufnum)
    local cwd = is_file(bufname) and basedir(bufname) or getcwd()
    if compiler then
        local flags_file = vim.fn.findfile('compile_flags.txt', cwd..';')
        local db_file = vim.fn.findfile('compile_commands.json', cwd..';')
        local has_tidy = false
        if executable('clang-tidy') and (flags_file ~= '' or db_file ~= '') then
            has_tidy = true
            vim.bo.makeprg = 'clang-tidy %'
            vim.bo.errorformat = '%E%f:%l:%c: fatal error: %m,%E%f:%l:%c: error: %m,%W%f:%l:%c: warning: %m'
        end
        local filename
        if db_file ~= '' then
            filename = realpath(db_file)
            if is_file(bufname) and not databases[realpath(bufname)] then
                bufname = realpath(bufname)
                readfile(filename, function(data)
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
                end, false)
            else
                set_opts(filename, has_tidy, compiler, bufnum)
            end
        elseif flags_file ~= '' then
            filename = realpath(normalize_path(flags_file))
            if not compile_flags[filename] then
                readfile(filename, function(data)
                    if data and #data > 0 then
                        compile_flags[filename] = {
                            flags = {},
                            includes = {},
                        }
                        for _,line in pairs(data) do
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
            -- NOTE: We need to call this multiple times since readfile is async
            set_opts(filename, has_tidy, compiler, bufnum)
        end
    end
end

return M

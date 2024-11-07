local nvim = require 'nvim'

local executable = require('utils.files').executable
-- local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath

local compile_flags = STORAGE.compile_flags
local compile_commands_dbs = STORAGE.compile_commands_dbs

local M = {
    makeprg = {
        ['clang-tidy'] = {
            efm = {
                '%E%f:%l:%c: fatal error: %m',
                '%E%f:%l:%c: error: %m',
                '%W%f:%l:%c: warning: %m',
            },
        },
        ['clang++'] = {
            '-std=c++20',
            '-O2',
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
            '-std=c++20',
            '-O2',
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
            '-O2',
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
            '-O2',
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
            '--fallback-style=WebKit',
            '--sort-includes',
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

-- TODO: current compiler should be cached into an internal buf/tab/global var
function M.get_compiler(ft)
    vim.validate {
        ft = { ft, 'string', true },
    }
    ft = ft or vim.bo.filetype

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

function M.get_args(compiler, bufnum, flags_location)
    vim.validate {
        compiler = { compiler, 'string' },
        bufnum = { bufnum, 'number', true },
        flags_location = { flags_location, 'string', true },
    }

    local args
    local bufname = nvim.buf.get_name(bufnum)
    if is_file(bufname) then
        bufname = realpath(bufname)
    end

    if flags_location then
        flags_location = realpath(flags_location)
        local name = vim.fs.basename(flags_location)
        if name == 'compile_commands.json' then
            if compile_commands_dbs[bufname] then
                args = compile_commands_dbs[bufname].flags
            end
        else
            if compile_flags[flags_location] then
                args = compile_flags[flags_location].flags
            end
        end
    end

    return args or M.makeprg[compiler] or {}
end

function M.set_file_opts(flags_file, bufnum)
    if executable 'clang-tidy' then
        local tidy = vim.list_extend({ 'clang-tidy' }, M.makeprg['clang-tidy'])
        vim.bo[bufnum].makeprg = table.concat(tidy, ' ') .. ' %'
        if M.makeprg['clang-tidy'].efm then
            vim.bo[bufnum].errorformat = table.concat(M.makeprg['clang-tidy'].efm, ',')
        end
    end

    local paths = {}
    local filename = nvim.buf.get_name(bufnum)
    if is_file(filename) then
        filename = realpath(filename)
    end

    local function set_source_options(fname)
        if compile_commands_dbs[fname] then
            paths = compile_commands_dbs[fname].includes or {}
            if fname:match '%.hpp$' or fname:match '%.h$' then
                local fname_basename = vim.fs.basename(fname)
                for source_name, _ in pairs(compile_commands_dbs) do
                    local source_basename = vim.fs.basename(source_name)
                    if
                        source_basename:gsub('%.cpp$', '.hpp') == fname_basename
                        or source_basename:gsub('%.c$', '.h') == fname_basename
                    then
                        paths = compile_commands_dbs[source_name].includes or {}
                        break
                    end
                end
            end
        elseif compile_flags[flags_file] then
            paths = compile_flags[flags_file].includes or {}
        end
        local path_var = vim.split(vim.bo[bufnum].path, ',')
        for _, path in ipairs(paths) do
            if not vim.list_contains(path_var, path) then
                vim.bo[bufnum].path = vim.bo[bufnum].path .. ',' .. path
            end
        end
    end

    set_source_options(filename)
end

function M.set_default_opts(compiler, bufnum)
    vim.validate {
        compiler = { compiler, 'string' },
        bufnum = { bufnum, 'number' },
    }
    if executable 'clang-tidy' then
        local tidy = vim.list_extend({ 'clang-tidy' }, M.makeprg['clang-tidy'])
        vim.bo[bufnum].makeprg = table.concat(tidy, ' ') .. ' %'
        if M.makeprg['clang-tidy'].efm then
            vim.bo[bufnum].errorformat = table.concat(M.makeprg['clang-tidy'].efm, ',')
        end
    else
        local args = M.get_args(compiler, bufnum)
        vim.bo[bufnum].makeprg = ('%s %s %%'):format(compiler, table.concat(args, ' '))
    end
end

function M.get_formatter(stdin)
    local cmd
    if executable 'clang-format' then
        cmd = { 'clang-format' }
        vim.list_extend(cmd, M.formatprg[cmd[1]])
        local config_file = RELOAD('utils.buffers').find_config { configs = '.clang-format' }
        if config_file then
            table.insert(cmd, '--style=file')
        end
        if not stdin then
            table.insert(cmd, '-i')
        end
    end
    return cmd
end

function M.setup()
    local compiler = M.get_compiler()
    if not compiler then
        return
    end

    local bufnum = nvim.get_current_buf()

    -- TODO: Add support for other build commands like gradle
    if executable 'make' then
        local makefile = vim.fs.find('Makefile', { upward = true, type = 'file' })[1]
        if makefile then
            vim.b.makefile = makefile
            RELOAD 'filetypes.make.mappings'
        end
    end

    if executable 'cmake' then
        local cmake = vim.fs.find('CMakeLists.txt', { upward = true, type = 'file' })[1]
        if cmake then
            vim.b.cmakefile = cmake
            RELOAD 'filetypes.cmake.mappings'
        end
    end

    local flags_file = vim.fs.find(
        { 'compile_flags.txt', 'compile_commands.json' },
        { upward = true, type = 'file', limit = math.huge }
    )

    if #flags_file > 0 then
        local db
        for _, filename in ipairs(flags_file) do
            if vim.fs.basename(filename) == 'compile_commands.json' then
                db = filename
                break
            end
        end

        flags_file = realpath(db or flags_file[1])
        local parsed_files = vim.g.parsed_flags or {}

        if not parsed_files[flags_file] then
            if not vim.g.compile_flags_parse then
                vim.g.compile_flags_parse = true
                RELOAD('threads.parse').compile_flags {
                    root = vim.fs.dirname(flags_file),
                    flags_file = flags_file,
                }
            end

            -- NOTE: Setting default options while we parse the flags
            M.set_default_opts(compiler, bufnum)
        else
            M.set_file_opts(flags_file, bufnum)
        end
    else
        M.set_default_opts(compiler, bufnum)
    end
end

return M

local nvim = require 'nvim'

local executable = require('utils.files').executable
-- local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath
local getcwd = require('utils.files').getcwd
local completions = RELOAD 'completions'

local compile_flags = STORAGE.compile_flags
local databases = STORAGE.databases

local dap = vim.F.npcall(require, 'dap')

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
            if databases[bufname] then
                args = databases[bufname].flags
            end
        else
            if compile_flags[flags_location] then
                args = compile_flags[flags_location].flags
            end
        end
    end

    return args or M.makeprg[compiler] or {}
end

function M.set_opts(compiler, bufnum)
    vim.validate {
        compiler = { compiler, 'string' },
        bufnum = { bufnum, 'number' },
    }

    local args
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
        flags_file = db or flags_file[1]
    else
        flags_file = nil
    end

    if flags_file then
        if executable 'clang-tidy' then
            local tidy = vim.list_extend({ 'clang-tidy' }, M.makeprg['clang-tidy'])
            vim.bo[bufnum].makeprg = table.concat(tidy, ' ') .. ' %'
            if M.makeprg['clang-tidy'].efm then
                vim.bo[bufnum].errorformat = table.concat(M.makeprg['clang-tidy'].efm, ',')
            end
        end

        args = M.get_args(compiler, bufnum, flags_file)

        local paths = {}
        local filename = nvim.buf.get_name(bufnum)
        if is_file(filename) then
            filename = realpath(filename)
        end

        local function set_source_options(fname)
            if databases[fname] then
                paths = databases[fname].includes
            elseif compile_flags[flags_file] then
                paths = compile_flags[flags_file].includes
            end
            local path_var = vim.split(vim.bo[bufnum].path, ',')
            for _, path in ipairs(paths) do
                if not vim.tbl_contains(path_var, path) then
                    vim.bo[bufnum].path = vim.bo[bufnum].path .. ',' .. path
                end
            end
        end

        if filename:match '%.hpp$' or filename:match '%.h$' then
            if vim.g.alternates[filename] then
                set_source_options(vim.g.alternates[filename][1])
            else
                local srcname = vim.fs.basename(filename):gsub('%.hpp$', '.cpp'):gsub('%.h$', '.c')
                RELOAD('threads.functions').async_find {
                    target = srcname,
                    cb = function(data)
                        if #data > 0 then
                            local alternates = vim.g.alternates
                            alternates[filename] = data
                            vim.g.alternates = alternates
                            if vim.api.nvim_buf_is_valid(bufnum) then
                                set_source_options(data[1])
                            end
                        end
                    end,
                }
            end
        else
            set_source_options(filename)
        end
    end

    if not args then
        args = M.get_args(compiler, bufnum)
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

function M.execute(exe, args)
    local base_cwd = getcwd()
    exe = exe or base_cwd .. '/build/main'
    args = args or {}
    if not is_file(exe) and not executable(exe) then
        vim.notify('Missing executable: ' .. exe, 'ERROR', { title = 'ExecuteProject' })
        return false
    end

    RELOAD('utils.functions').async_execute {
        cmd = exe,
        args = args,
        verify_exec = false,
        context = 'Execute',
        title = 'Execute',
    }
end

function M.build(build_info)
    local flags = build_info.flags or {}
    local compiler = build_info.compiler or M.get_compiler()

    if type(flags) ~= type {} then
        flags = { flags }
    end

    local base_cwd = getcwd()
    local ft = vim.opt_local.filetype:get()

    local compile_output = base_cwd .. '/build/main'
    if nvim.has 'win32' then
        compile_output = compile_output .. '.exe'
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
        flags_file = db or flags_file[1]
    else
        flags_file = nil
    end

    vim.list_extend(flags, M.get_args(compiler, nvim.get_current_buf(), flags_file))
    vim.list_extend(flags, { '-o', compile_output })

    if build_info.build_type then
        local build_flags = { '-O2' }
        if build_info.build_type:lower() == 'debug' then
            build_flags = { '-Og', '-g' }
        elseif build_info.build_type:lower() == 'relwithdebinfo' then
            build_flags = { '-O2', '-g' }
        elseif build_info.build_type:lower() == 'minsizerel' then
            build_flags = { '-Oz' }
        end
        local tmp_flags = {}
        for _, flag in ipairs(flags) do
            if not flag:match '^-O%d?$' and not flag:match '^-g%d?$' then
                table.insert(tmp_flags, flag)
            end
        end
        flags = vim.list_extend(tmp_flags, build_flags)
    end

    local compile = function(real_flags)
        -- -- TODO: Replace mismatch std
        -- for idx, real_flags in ipairs(real_flags) do
        --     if real_flags:match '%-%-std' then
        --         -- code
        --     end
        -- end

        RELOAD('utils.functions').async_execute {
            pre_execute = function()
                require('utils.files').mkdir 'build'
            end,
            cmd = compiler,
            args = real_flags,
            context = 'Compile',
            title = 'Compile',
            auto_close = true,
            callbacks = build_info.cb,
        }
    end

    if not build_info.single then
        local files = vim.fs.find(function(filename)
            return filename:match('%.' .. ft .. '$') ~= nil
        end, { type = 'file', limit = math.huge })
        compile(vim.list_extend(flags, files))
    else
        table.insert(flags, nvim.buf.get_name(0))
        compile(flags)
    end
end

function M.setup()
    local compiler = M.get_compiler()
    if not compiler then
        return
    end

    -- TODO: Add support for other build commands like gradle
    local makefile = vim.fs.find('Makefile', { upward = true, type = 'file' })[1]
    if makefile and executable 'make' then
        require('filetypes.make').setup()
    end

    local cmake = vim.fs.find('CMakeLists.txt', { upward = true, type = 'file' })[1]
    if cmake and executable 'cmake' then
        require('filetypes.cmake').setup()
    end

    -- TODO: Add a watcher to compile_commands.json and compile_flags.txt and update the
    --       flags on any file update
    M.set_opts(compiler, nvim.get_current_buf())

    nvim.command.set('BuildProject', function(opts)
        local args = opts.fargs
        local flags = {}
        local build_type

        local builds = {
            debug = true,
            release = true,
            minsizerel = true,
            relwithdebinfo = true,
        }

        for _, arg in ipairs(args) do
            if builds[arg:lower()] then
                build_type = arg
            else
                table.insert(flags, arg)
            end
        end
        M.build {
            compiler = compiler,
            build_type = build_type,
            flags = flags,
        }
    end, {
        nargs = '*',
        force = true,
        buffer = true,
        complete = completions.cmake_build,
    })

    nvim.command.set('BuildFile', function(opts)
        local args = opts.fargs
        local flags = {}
        local build_type

        local builds = {
            debug = true,
            release = true,
            minsizerel = true,
            relwithdebinfo = true,
        }

        for _, arg in ipairs(args) do
            if builds[arg:lower()] then
                build_type = arg
            else
                table.insert(flags, arg)
            end
        end

        M.build {
            compiler = compiler,
            build_type = build_type,
            flags = flags,
            single = true,
        }
    end, {
        nargs = '*',
        force = true,
        buffer = true,
        complete = completions.cmake_build,
    })

    nvim.command.set('BuildExecuteProject', function(opts)
        local args = opts.fargs
        local flags = {}
        local build_type

        local builds = {
            debug = true,
            release = true,
            relwithdebinfo = true,
        }

        for _, arg in ipairs(args) do
            if builds[arg:lower()] then
                build_type = arg
            else
                table.insert(flags, arg)
            end
        end

        M.build {
            compiler = compiler,
            build_type = build_type,
            flags = flags,
            cb = M.execute,
        }
    end, {
        nargs = '*',
        force = true,
        buffer = true,
        complete = completions.cmake_build,
    })

    nvim.command.set('ExecuteProject', function(opts)
        M.execute(nil, opts.fargs)
    end, { nargs = '*', force = true, buffer = true })

    -- TODO: Fallback to TermDebug
    if dap then
        nvim.command.set('BuildDebugFile', function(opts)
            local args = opts.fargs
            local flags = {}

            vim.list_extend(flags, args)
            M.build {
                compiler = compiler,
                build_type = 'debug',
                flags = flags,
                cb = dap.continue,
                single = true,
            }
        end, {
            nargs = '*',
            force = true,
            buffer = true,
        })

        nvim.command.set('BuildDebug', function(opts)
            -- local args = opts.fargs
            -- local flags = {}
            -- vim.list_extend(flags, args)
            M.build {
                compiler = compiler,
                build_type = 'debug',
                flags = opts.fargs,
                cb = dap.continue,
            }
        end, {
            nargs = '*',
            force = true,
            buffer = true,
        })
    end
end

return M

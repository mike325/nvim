local nvim = require 'neovim'

local executable = require('utils.files').executable
local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath
local getcwd = require('utils.files').getcwd
-- local find_parent = require('utils.files').find_parent

local compile_flags = STORAGE.compile_flags
local databases = STORAGE.databases
-- local has_cjson = STORAGE.has_cjson

local async_execute = require('utils.functions').async_execute

local load_module = require('utils.functions').load_module
local dap = load_module 'dap'

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
            '--style=file',
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
            databases[source_name].flags = vim.list_slice(args, 2, #args)
            databases[source_name].includes = parse_includes(databases[source_name].flags)
        end
    end
end

local function parse_compile_flags(flags_file)
    local data = readfile(flags_file, true)
    if data and #data > 0 then
        flags_file = realpath(flags_file)
        compile_flags[flags_file] = {
            flags = {},
            includes = {},
        }
        for _, line in pairs(data) do
            if line:sub(1, 1) == '-' or line:sub(1, 1) == '/' then
                table.insert(compile_flags[flags_file].flags, line)
            end

            if line:sub(1, 2) == '-I' or line:sub(1, 2) == '/I' or line:match '^-isystem' then
                local path = line:sub(3, #line):gsub('^%s+', '')
                table.insert(compile_flags[flags_file].includes, path)
            end
        end
    end
end

local function get_args(compiler, bufnum)
    local args, cwd

    local bufname = nvim.buf.get_name(bufnum)
    if bufname and bufname ~= '' and is_file(bufname) then
        bufname = realpath(bufname)
    end

    if bufname and bufname ~= '' and is_file(bufname) then
        cwd = require('utils.files').basedir(bufname)
    else
        cwd = getcwd()
    end

    local db_file = vim.fn.findfile('compile_commands.json', cwd .. ';')
    if db_file and db_file ~= '' then
        parse_compiledb(readfile(db_file, false))
        if databases[bufname] then
            args = databases[bufname].flags
        end
    else
        local flags_file = vim.fn.findfile('compile_flags.txt', cwd .. ';')
        if flags_file and flags_file ~= '' then
            flags_file = realpath(flags_file)
            parse_compile_flags(flags_file)
            args = compile_flags[flags_file].flags
        end
    end

    return args or M.makeprg[compiler] or {}
end

local function set_opts(compiler, bufnum)
    local flags_file = vim.fn.findfile('compile_flags.txt', getcwd() .. ';')
    local db_file = vim.fn.findfile('compile_commands.json', getcwd() .. ';')
    local clang_tidy = vim.fn.findfile('.clang-tidy', getcwd() .. ';')

    flags_file = flags_file ~= '' and flags_file or nil
    db_file = db_file ~= '' and db_file or nil
    clang_tidy = clang_tidy ~= '' and clang_tidy or nil

    local args

    if executable 'clang-tidy' and (flags_file or db_file or clang_tidy) then
        local tidy = vim.list_extend({ 'clang-tidy' }, M.makeprg['clang-tidy'])
        vim.opt_local.makeprg = table.concat(tidy, ' ') .. ' %'
        if M.makeprg['clang-tidy'].efm then
            vim.opt_local.errorformat = M.makeprg['clang-tidy'].efm
        end
    else
        args = get_args(compiler, bufnum)
        vim.opt_local.makeprg = ('%s %s %%'):format(compiler, table.concat(args, ' '))
    end

    if flags_file or db_file then
        if not args then
            args = get_args(compiler, bufnum)
        end

        local paths = {}
        for _, flag in ipairs(args) do
            if flag:sub(1, 2) == '-I' or flag:sub(1, 2) == '/I' or flag:match '^-isystem' then
                local path = flag:sub(3, #flag):gsub('^%s+', '')
                table.insert(paths, path)
            end
        end
        for _, path in ipairs(paths) do
            if not vim.tbl_contains(vim.opt_local.path:get(), path) then
                vim.opt_local.path:append(paths)
            end
        end
    end
end

function M.get_formatter(stdin)
    local cmd
    if executable 'clang-format' then
        cmd = { 'clang-format' }
        local config = vim.fn.findfile('.clang-format', getcwd() .. ';')
        if config and config ~= '' then
            vim.list_extend(cmd, M.formatprg[cmd[1]])
            -- cmd = require('utils.buffers').replace_indent(cmd)
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

    async_execute {
        cmd = exe,
        args = args,
        verify_exec = false,
        context = 'Execute',
        title = 'Execute',
    }
end

function M.build(build_info)
    local flags = build_info.flags or {}
    local compiler = build_info.compiler or get_compiler()

    if type(flags) ~= type {} then
        flags = { flags }
    end

    local base_cwd = getcwd()
    local ft = vim.opt_local.filetype:get()

    local compile_output = base_cwd .. '/build/main'
    if nvim.has 'win32' then
        compile_output = compile_output .. '.exe'
    end

    vim.list_extend(flags, get_args(compiler, nvim.get_current_buf()))
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

        async_execute {
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
        require('utils.files').find_files(base_cwd, '*.' .. ft, function(job)
            compile(vim.list_extend(flags, job:output()))
        end)
    else
        table.insert(flags, nvim.buf.get_name(0))
        compile(flags)
    end
end

function M.setup()
    local compiler = get_compiler()
    if not compiler then
        return
    end

    local makefile = vim.fn.findfile('Makefile', getcwd() .. ';')
    if makefile and makefile ~= '' and executable 'make' then
        require('filetypes.make').setup()
    end

    local cmake = vim.fn.findfile('Makefile', getcwd() .. ';')
    if cmake and cmake ~= '' and executable 'cmake' then
        require('filetypes.cmake').setup()
    end

    -- TODO: Add a watcher to compile_commands.json and compile_flags.txt and update the
    --       flags on any file update
    set_opts(compiler, nvim.get_current_buf())

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
        complete = 'customlist,v:lua._completions.cmake_build',
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
        complete = 'customlist,v:lua._completions.cmake_build',
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
        complete = 'customlist,v:lua._completions.cmake_build',
    })

    nvim.command.set('ExecuteProject', function(opts)
        local args = opts.fargs
        M.execute(nil, args)
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

    nvim.command.set('ExecuteProject', function(opts)
        M.execute(nil, opts.fargs)
    end, { nargs = '*', force = true, buffer = true })
end

return M

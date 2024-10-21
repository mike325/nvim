local nvim = require 'nvim'

local executable = require('utils.files').executable
-- local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath
local getcwd = require('utils.files').getcwd

local compile_flags = STORAGE.compile_flags
local compile_commands_dbs = STORAGE.compile_commands_dbs

local M = {}

local compilers = {
    c = {
        'clang',
        'gcc',
        'cc',
        'zig',
    },
    cpp = {
        'clang++',
        'g++',
        'c++',
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
    elseif vim.b[ft .. '_compiler'] then
        return vim.b[ft .. '_compiler']
    elseif vim.g[ft .. '_compiler'] then
        return vim.g[ft .. '_compiler']
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

    return args or require('filetypes.cpp').makeprg[compiler] or {}
end

function M.execute(exe, args)
    vim.validate {
        exe = { exe, 'string', true },
        arg = { arg, 'table', true },
    }

    exe = exe or (getcwd() .. '/build/main')
    args = args or {}
    if not is_file(exe) or not executable(exe) then
        vim.notify('Missing executable: ' .. exe, vim.log.levels.ERROR, { title = 'ExecuteProject' })
        return false
    end

    RELOAD('utils.functions').async_execute {
        cmd = exe,
        args = args,
        verify_exec = false,
        title = 'Execute',
    }
end

function M.compile(build_info)
    vim.validate {
        build_info = { build_info, 'table', true },
    }
    build_info = build_info or {}

    local flags = build_info.flags or {}
    local compiler = build_info.compiler or M.get_compiler()

    if type(flags) ~= type {} then
        flags = { flags }
    end

    local base_cwd = getcwd()
    local ft = vim.bo.filetype

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
            if not flag:match '^-O[%d]?[zg]?$' and not flag:match '^-g%d?$' then
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
            title = 'Compile',
            auto_close = true,
            callbacks = function(job, rc)
                build_info.cb(compile_output, real_flags, job, rc)
            end,
        }
    end

    if not build_info.single then
        local blacklist = {
            ['.git'] = true,
            ['.svn'] = true,
            ['.cache'] = true,
            ['__pycache__'] = true,
            ['.vscode'] = true,
            ['.vscode_clangd_setup'] = true,
            ['node_modules'] = true,
        }

        local candidates = {}
        local function filter_func(fname)
            return fname:match('%.' .. ft .. '$') ~= nil
        end
        local path = '.'
        for fname, ftype in vim.fs.dir(path) do
            if ftype == 'file' then
                if filter_func(fname) then
                    table.insert(candidates, vim.fs.joinpath(path, fname))
                end
            elseif not blacklist[fname] then
                local results = vim.fs.find(filter_func, { type = 'file', limit = math.huge, vim.fs.joinpath(path, fname) })
                if #results > 0 then
                    candidates = vim.list_extend(candidates, results)
                end
            end
        end

        compile(vim.list_extend(flags, candidates))
    else
        table.insert(flags, nvim.buf.get_name(0))
        compile(flags)
    end
end

function M.build(build_info)
    vim.validate {
        build_info = { build_info, 'table', true },
    }
    build_info = build_info or {}

    if executable 'make' and is_file 'Makefile' then
        RELOAD('filetypes.make.utils').execute(build_info.args or {})
    elseif executable 'cmake' and is_file 'CMakeLists.txt' then
        -- NOTE: Should this also configure ?
        RELOAD('filetypes.cmake.mappings').build(build_info)
    else
        M.compile(build_info)
    end
end

return M

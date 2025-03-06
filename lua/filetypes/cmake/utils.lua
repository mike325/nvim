local M = {}

local mkdir = require('utils.files').mkdir
local is_dir = require('utils.files').is_dir
local is_file = require('utils.files').is_file
local link = require('utils.files').link

function M.execute(args)
    vim.validate('arg', arg, 'table', true)
    args = args or {}

    for idx, arg in ipairs(args) do
        args[idx] = vim.fn.expand(arg)
    end

    RELOAD('utils.functions').async_execute {
        cmd = 'cmake',
        args = args,
        progress = true,
        auto_close = true,
        silent = false,
        title = 'CMake',
        callbacks_on_success = function()
            local ns = vim.api.nvim_create_namespace 'cmake'
            vim.diagnostic.reset(ns)
        end,
        callbacks_on_failure = function()
            RELOAD('utils.qf').qf_to_diagnostic 'cmake'
        end,
    }
end

local function link_compile_commands(build_dir)
    vim.validate('build_dir', build_dir, 'string')
    local fname = string.format('%s/compile_commands.json', build_dir)
    if is_file(fname) then
        link(fname, '.', false, true)
    end
end

function M.build(opts)
    vim.validate('opts', opts, 'table', true)
    opts = opts or {}

    -- Release, Debug, RelWithDebInfo, etc.
    local build_type = opts.build_type or 'RelWithDebInfo'
    local build_dir = opts.build_dir or 'build'

    if not is_dir(build_dir) then
        mkdir(build_dir)
    end

    local args = {
        '--build',
        build_dir,
        '--config',
        build_type,
    }

    if opts.args then
        args = vim.list_extend(args, opts.args)
    end

    local cb = opts.cb
    opts.cb = nil
    RELOAD('utils.functions').async_execute {
        cmd = 'cmake',
        args = args,
        progress = true,
        auto_close = true,
        silent = false,
        title = 'CMake',
        callbacks_on_success = function()
            local ns = vim.api.nvim_create_namespace 'cmake'
            vim.diagnostic.reset(ns)
            link_compile_commands(build_dir)
            if cb then
                cb(opts)
            end
        end,
        callbacks_on_failure = function()
            RELOAD('utils.qf').qf_to_diagnostic 'cmake'
        end,
    }
end

function M.config(opts)
    vim.validate('opts', opts, 'table', true)
    opts = opts or {}

    local build_type = opts.build_type or 'RelWithDebInfo'
    local build_dir = opts.build_dir or 'build'

    if not is_dir(build_dir) then
        mkdir(build_dir)
    end

    local args = {
        '.',
        '-DCMAKE_BUILD_TYPE=' .. build_type,
        '-B' .. build_dir,
    }

    local c_compiler
    if opts.c_compiler then
        c_compiler = '-DCMAKE_C_COMPILER=' .. opts.c_compiler
    elseif vim.g.c_compiler then
        c_compiler = '-DCMAKE_C_COMPILER=' .. vim.g.c_compiler
    elseif vim.env.CC then
        c_compiler = '-DCMAKE_C_COMPILER=' .. vim.env.CC
    end

    local cpp_compiler
    if opts.cpp_compiler then
        c_compiler = '-DCMAKE_CXX_COMPILER=' .. opts.cpp_compiler
    elseif vim.g.c_compiler then
        cpp_compiler = '-DCMAKE_CXX_COMPILER=' .. vim.g.cpp_compiler
    elseif vim.env.CXX then
        cpp_compiler = '-DCMAKE_CXX_COMPILER=' .. vim.env.CXX
    end

    if c_compiler then
        table.insert(args, c_compiler)
    end

    if cpp_compiler then
        table.insert(args, cpp_compiler)
    end

    table.insert(args, ' -DCMAKE_EXPORT_COMPILE_COMMANDS=ON')

    if opts.args then
        args = vim.list_extend(args, opts.args)
    end

    local cb = opts.cb
    opts.cb = nil
    RELOAD('utils.functions').async_execute {
        cmd = 'cmake',
        args = args,
        progress = true,
        auto_close = true,
        silent = false,
        title = 'CMake',
        callbacks_on_success = function()
            local ns = vim.api.nvim_create_namespace 'cmake'
            vim.diagnostic.reset(ns)
            if cb then
                cb(opts)
            end
        end,
        callbacks_on_failure = function()
            RELOAD('utils.qf').qf_to_diagnostic 'cmake'
        end,
    }
end

return M

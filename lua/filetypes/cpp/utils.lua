local nvim = require 'nvim'

local executable = require('utils.files').executable
-- local readfile = require('utils.files').readfile
local is_file = require('utils.files').is_file
local realpath = require('utils.files').realpath

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

return M

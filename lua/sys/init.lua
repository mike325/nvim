-- luacheck: globals unpack vim
local nvim    = require'nvim'
local stdpath = vim.fn.stdpath

local function system_name()
    local name = vim.loop.os_uname().sysname:lower()
    name = vim.split(name, '_')[1]
    return name
end

local function homedir()
    local home = vim.loop.os_homedir()
    return home:gsub('\\', '/')
end

local function basedir()
    return stdpath('config'):gsub('\\', '/')
end

local function cachedir()
    return stdpath('cache'):gsub('\\', '/')
end

local function datadir()
    return stdpath('data'):gsub('\\', '/')
end

local function luajit_version()
    return vim.split(jit.version, ' ')[2]
end

local sys = {
    name  = system_name(),
    home  = homedir(),
    base  = basedir(),
    data  = datadir(),
    cache = cachedir(),
    luajit = luajit_version(),
    user = vim.loop.os_get_passwd()
}

sys.user.name = sys.user.username

function sys.tmp(filename)
    local tmpdir = sys.name == 'windows' and 'c:/temp/' or '/tmp/'
    return tmpdir .. filename
end

return sys

-- luacheck: globals unpack vim
local nvim    = require'nvim'
local stdpath = nvim.fn.stdpath

local function system_name()

    local name = 'unknown'
    if nvim.has('win32unix') or nvim.has('win32') then
        name = 'windows'
    elseif nvim.has('mac') then
        name = 'mac'
    elseif nvim.has('unix') then
        name = 'linux'
    end

    return name
end

local function homedir()
    local var = system_name() == 'windows' and 'USERPROFILE' or 'HOME'
    local home = nvim.env[var]
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
    return vim.split(jit.version, ' ', true)[2]
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

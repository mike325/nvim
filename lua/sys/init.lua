-- luacheck: globals unpack vim

-- local api = vim.api
local nvim = require('nvim')

local mkdir       = nvim.fn.mkdir
local stdpath     = nvim.fn.stdpath
local isdirectory = nvim.isdirectory
-- local executable  = nvim.executable

local function system_name()
    local name = 'unknown'

    if nvim.has('win32unix') or nvim.has('win32') then
        name = 'windows'
    elseif nvim.has('gui_mac') or nvim.has('mac') or nvim.has('macos') or nvim.has('macunix') then
        name = 'mac'
    elseif nvim.has('unix') then
        -- TODO: check for false positive problems in macOS
        name = 'linux'
    end

    name = name:lower()

    return name
end

local function homedir()
    local var = system_name() == 'windows' and 'USERPROFILE' or 'HOME'
    local home = nvim.env[var]

    home = home:gsub('\\', '/')

    return home
end

local function basedir()
    local dir = stdpath('config'):gsub('\\', '/')

    if isdirectory(dir) then
        mkdir(dir, 'p')
    end

    return dir
end

local function cachedir()
    local dir = stdpath('cache'):gsub('\\', '/')

    if isdirectory(dir) then
        mkdir(dir, 'p')
    end

    return dir
end

local function datadir()
    local dir = stdpath('data'):gsub('\\', '/')

    if isdirectory(dir) then
        mkdir(dir, 'p')
    end

    return dir
end

local sys = {
    name  = system_name(),
    home  = homedir(),
    base  = basedir(),
    data  = datadir(),
    cache = cachedir(),
}

function sys.tmp(filename)
    local tmpdir = sys.name == 'windows' and 'c:/temp/' or '/tmp/'
    return tmpdir .. filename
end

return sys

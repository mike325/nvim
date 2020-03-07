-- luacheck: globals unpack vim

-- local api = vim.api
local nvim = require('nvim')

local has         = require('nvim').fn.has
local mkdir       = require('nvim').fn.mkdir
local stdpath     = require('nvim').fn.stdpath
local isdirectory = require('nvim').fn.isdirectory
-- local system      = require('nvim').fn.system
-- local executable  = require('nvim').fn.executable

local function system_name()
    local name = 'unknown'

    if has('win32unix') == 1 or has('win32') == 1 then
        name = 'windows'
    elseif has('gui_mac') == 1 or has('mac') == 1 or has('macos') == 1 or has('macunix') == 1 then
        name = 'mac'
    elseif has('unix') == 1 then
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

    if isdirectory(dir) == 0 then
        mkdir(dir, 'p')
    end

    return dir
end

local function cachedir()
    local dir = stdpath('cache'):gsub('\\', '/')

    if isdirectory(dir) == 0 then
        mkdir(dir, 'p')
    end

    return dir
end

local function datadir()
    local dir = stdpath('data'):gsub('\\', '/')

    if isdirectory(dir) == 0 then
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

-- luacheck: globals unpack vim

local mkdir       = require('nvim').fn.mkdir
local stdpath     = require('nvim').fn.stdpath
local isdirectory = require('nvim').fn.isdirectory

local function system_name()
    return vim.loop.os_uname()['sysname']:lower():gsub('_.*', '')
end

local function homedir()
    return vim.loop.os_homedir():gsub('\\', '/')
end

local function basedir()
    local basedir = stdpath('config'):gsub('\\', '/')

    if isdirectory(basedir) == 0 then
        mkdir(basedir, 'p')
    end

    return basedir
end

local function cachedir()
    local cachedir = stdpath('cache'):gsub('\\', '/')

    if isdirectory(cachedir) == 0 then
        mkdir(cachedir, 'p')
    end

    return cachedir
end

local function datadir()
    local datadir = stdpath('data'):gsub('\\', '/')

    if isdirectory(datadir) == 0 then
        mkdir(datadir, 'p')
    end

    return datadir
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

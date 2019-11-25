-- local nvim = require('mikecommon/nvim')

local function system_name(...)
    return vim.loop.os_uname()['sysname']:lower():gsub('_.*', '')
end

local function homedir(...)
    return vim.loop.os_homedir():gsub('\\', '/')
end

local function basedir(...)
    return vim.api.nvim_call_function('stdpath', {'config'}):gsub('\\', '/')
end

local function datadir(...)
    return vim.api.nvim_call_function('stdpath', {'data'}):gsub('\\', '/')
end

local sys = {
    name = system_name(),
    home = homedir(),
    base = basedir(),
    data = datadir(),
}

return sys

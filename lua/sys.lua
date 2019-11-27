-- local nvim = require('mikecommon/nvim')

local function system_name(...)
    return vim.loop.os_uname()['sysname']:lower():gsub('_.*', '')
end

local function homedir(...)
    return vim.loop.os_homedir():gsub('\\', '/')
end

local function basedir(...)
    local basedir = vim.api.nvim_call_function('stdpath', {'config'}):gsub('\\', '/')

    if not vim.api.nvim_call_function('isdirectory', {basedir}) then
        vim.api.nvim_call_function('mkdir', {basedir, 'p'})
    end

    return basedir
end

local function datadir(...)
    local datadir = vim.api.nvim_call_function('stdpath', {'data'}):gsub('\\', '/')

    if not vim.api.nvim_call_function('isdirectory', {datadir}) then
        vim.api.nvim_call_function('mkdir', {datadir, 'p'})
    end

    return datadir
end

local sys = {
    name = system_name(),
    home = homedir(),
    base = basedir(),
    data = datadir(),
}

return sys

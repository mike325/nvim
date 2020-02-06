local nvim = require('nvim')
local api = vim.api

local has        = require('nvim').fn.has
local exists     = require('nvim').fn.exists
local system     = require('nvim').fn.system
local exepath    = require('nvim').fn.exepath
local executable = require('nvim').fn.executable

local check_version    = require('tools').check_version
local split_components = require('tools').split_components

local inspect = vim.inspect

-- global python object
python = {
    ['2'] = {
        path = nil,
        version = nil,
    },
    ['3'] = {
        path = nil,
        version = nil,
    },
}

local function get_python_exe(version)

    local pyexe = nil
    local pyeval = version == 2 and 'pyeval' or 'py3eval'
    local pyversion = version == 2 and '2' or '3'
    local variable = version == 2 and 'python_host_prog' or 'python3_host_prog'
    local deactivate = version == 2 and 'loaded_python_provider' or 'loaded_python3_provider'

    if python[pyversion]['path'] ~= nil then
        return python[pyversion]['path']
    elseif nvim.g[variable] ~= nil then
        python[pyversion]['path'] = nvim.g[variable]
        return python[pyversion]['path']
    end

    if executable('python'..pyversion) == 1 then
        pyexe = exepath('python'..pyversion)
    end

    if pyexe ~= nil then
        pyexe = pyexe:gsub('\\', '/')
        python[pyversion]['path'] = pyexe
        nvim.g[variable] = pyexe
        -- if nvim.g[deactivate] ~= nil then
        --     nvim.g[deactivate] = nil
        -- end

        local full_version = nvim.fn.system(pyexe .. ' --version')
        full_version = string.match(full_version, '[%d%p]+')
        python[pyversion]['version'] = full_version

    else
        nvim.g[deactivate] = 0
    end

    return pyexe
end

function python:setup()

    local has_python = 0

    if get_python_exe(2) ~= nil then
        has_python = 1
    end

    if get_python_exe(3) ~= nil then
        has_python = 1
    end

    return has_python
end

function python.has_version(...)
    if executable('python2') == 0 and executable('python3') == 0 then
        return 0
    end

    local opts

    if ... == nil or type(...) ~= 'table' then
        opts = ... == nil and {} or {...}
    else
        opts = ...
    end

    if #opts == 0 then
        return has('python') == 1 or has('python3') == 1
    end

    local major = opts[1]

    local version = python[tostring(major)].version
    local components = split_components(version, '%d+')

    return check_version(components, opts)
end

return python
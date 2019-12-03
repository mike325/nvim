local has        = require('nvim').has
local exists     = require('nvim').exists
local system     = require('nvim').system
local exepath    = require('nvim').exepath
local executable = require('nvim').executable

local python = {
    python2 = {
        path = nil,
        version = nil,
    },
    python3 = {
        path = nil,
        version = nil,
    },
}

local function get_var(var)
    local ok, value = pcall(vim.api.nvim_get_var, var)
    return ok and value or nil
end

local function get_python_exe(version)

    local pyexe = nil
    local pyeval = version == 2 and 'pyeval' or 'py3eval'
    local pyversion = version == 2 and 'python2' or 'python3'
    local variable = version == 2 and 'python_host_prog' or 'python3_host_prog'
    local deactivate = version == 2 and 'loaded_python_provider' or 'loaded_python3_provider'

    if python[pyversion]['path'] ~= nil then
        return python[pyversion]['path']
    elseif get_var(variable) ~= nil then
        python[pyversion]['path'] = vim.api.nvim_get_var(variable)
        return python[pyversion]['path']
    end

    if executable(pyversion) then
        pyexe = exepath(pyversion)
    end

    if pyexe ~= nil then
        pyexe = pyexe:gsub('\\', '/')
        python[pyversion]['path'] = pyexe
        vim.api.nvim_set_var(variable, pyexe)
        if get_var(deactivate) ~= nil then
            vim.api.nvim_del_var(deactivate)
        end

        local full_version = vim.api.nvim_call_function('system', {pyexe .. ' --version'})
        full_version = string.match(full_version, '[%d%p]+')
        python[pyversion]['version'] = full_version

    else
        vim.api.nvim_set_var(deactivate, 0)
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

return python

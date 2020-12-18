local nvim = require'nvim'
-- local api = vim.api

local has        = nvim.has
local system     = nvim.fn.system
local exepath    = nvim.fn.exepath
local executable = nvim.executable

local check_version    = require'tools'.helpers.check_version
local split_components = require'tools'.strings.split_components

-- local inspect = vim.inspect

local M = {
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
    -- local pyeval = version == 2 and 'pyeval' or 'py3eval'
    local pyversion = version == 2 and '2' or '3'
    local variable = version == 2 and 'python_host_prog' or 'python3_host_prog'
    local deactivate = version == 2 and 'loaded_python_provider' or 'loaded_python3_provider'

    if python[pyversion]['path'] ~= nil then
        return python[pyversion]['path']
    elseif nvim.g[variable] ~= nil then
        _G['python'][pyversion]['path'] = nvim.g[variable]
        return python[pyversion]['path']
    end

    if _G['python']['3']['path'] ~= nil and pyversion == '2' then
        nvim.g[deactivate] = 0
    end

    if nvim.g[deactivate] == 0 then
        return nil
    end

    if executable('python'..pyversion) then
        pyexe = exepath('python'..pyversion)
    end

    if pyexe ~= nil then

        pyexe = pyexe:gsub('\\', '/')

        -- TODO: This is slowing down neovim as hell
        --       need to find another way to figure out if pynvim is installed
        --
        -- local has_pynvim = system(pyexe .. ' -c "import pynvim"')
        -- if has_pynvim ~= '' then
        --     nvim.g[deactivate] = 0
        --     return nil
        -- end

        _G['python'][pyversion]['path'] = pyexe
        nvim.g[variable] = pyexe

        local full_version = system(pyexe .. ' --version')
        full_version = string.match(full_version, '[%d%p]+')
        _G['python'][pyversion]['version'] = full_version

    else
        nvim.g[deactivate] = 0
    end

    return pyexe
end

function M:setup()

    local has_python = false

    if get_python_exe(3) ~= nil then
        has_python = true
    end

    if get_python_exe(2) ~= nil then
        has_python = true
    end

    return has_python
end

function M.has_version(...)
    if not executable('python2') and not executable('python3') then
        return 0
    end

    local opts

    if ... == nil or type(...) ~= 'table' then
        opts = ... == nil and {} or {...}
    else
        opts = ...
    end

    if #opts == 0 then
        return has('python') or has('python3')
    end

    local major = opts[1]

    local version = python[tostring(major)].version
    local components = split_components(version, '%d+')

    return check_version(components, opts)
end

_G['python'] = M

return _G['python']

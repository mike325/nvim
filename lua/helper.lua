-- luacheck: globals unpack vim
local nvim = vim.api

local helper = {}

helper.plug = nvim.nvim_get_var('plugs')

helper.contains = function(array, value)
    for _, data in pairs(array) do
        if data == value then
            return true
        end
    end
    return false
end

local contains = helper.contains

helper.has_key = function(array, key)
    for index, _ in pairs(array) do
        if index == key then
            return true
        end
    end
    return false
end

local has_key = helper.has_key

helper.os_name = function()
    local name = 'unknown'
    if nvim.nvim_call_function('has', {'win32'}) == 1 then
        name = 'windows'
    elseif nvim.nvim_call_function('has', {'unix'}) == 1 then
        name = 'windows'
    elseif nvim.nvim_call_function('has', {'macos'}) == 1 then
        name = 'macos'
    end
    return name
end

local nvimFuncWrapper = function(name, ...)
    return nvim.nvim_call_function(name, {...})
end

helper.has        = function(feature) return nvimFuncWrapper('has', feature) end
helper.executable = function(program) return nvimFuncWrapper('executable', program) end
helper.exepath    = function(program) return nvimFuncWrapper('exepath', program) end
helper.system     = function(cmd) return nvimFuncWrapper('system', cmd) end
helper.systemlist = function(cmd) return nvimFuncWrapper('systemlist', cmd) end
helper.split      = function(str, pattern, keepempty) return nvimFuncWrapper('split', str, pattern, keepempty) end
helper.join       = function(str, separator) return nvimFuncWrapper('join', str, separator) end

helper.json = {}

helper.json.decode = function(json) return nvimFuncWrapper('json_decode', json) end
helper.json.encode = function(json) return nvimFuncWrapper('json_encode', json) end

return helper

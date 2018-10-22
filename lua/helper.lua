-- luacheck: globals unpack vim
local nvim = vim.api

local helper = {}

helper.plug = nvim.nvim_get_var('plugs')

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

local nvimFuncWrapper = function(name, args) return nvim.nvim_call_function(name, {args}) end

helper.has        = function(args) return nvimFuncWrapper('has', args) end
helper.executable = function(args) return nvimFuncWrapper('executable', args) end
helper.exepath    = function(args) return nvimFuncWrapper('exepath', args) end

return helper

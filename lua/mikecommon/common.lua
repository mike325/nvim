-- luacheck: globals unpack vim
local api = vim.api

local common = {}

common.os_name = function()
    local name = 'unknown'
    if api.nvim_call_function('has', {'win32'}) == 1 then
        name = 'windows'
    elseif api.nvim_call_function('has', {'unix'}) == 1 then
        name = 'unix'
    elseif api.nvim_call_function('has', {'macos'}) == 1 then
        name = 'macos'
    end
    return name
end

return common

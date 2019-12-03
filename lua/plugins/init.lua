local nvim = require('nvim')

local plugs = require('plugins/plugs')
local api = vim.api

local function convert2settings(name)
    if name:find('-', 1, true) or name:find('.', 1, true) then
        name = name:gsub('-', '_')
        name = name:gsub('%.', '_')
    end
    return name:lower()
end

-- TODO: Add glob function to call just the available configs
for plugin, data in pairs(plugs) do
    local name = plugin
    local func_name = convert2settings(name)
    local ok, error_code = pcall(api.nvim_call_function, 'plugins#'..func_name..'#init', {data})
    -- if not ok then
    --     -- print('Something failed "'..error_code..'" Happened trying to call '..'plugins#'..func_name..'#init')
    -- else
    --     -- print('Success calling plugins#'..func_name..'#init')
    -- end
end

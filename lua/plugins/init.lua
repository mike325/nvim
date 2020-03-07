local nvim = require('nvim')

-- local inspect = nvim.inspect
local api = nvim.api

local installed, plugs = pcall(api.nvim_get_var, 'plugs')

if not installed then
    nvim.echoerr('Plugs are not load yet')
    return nil
end

local function convert2settings(name)
    if name:find('-', 1, true) or name:find('.', 1, true) then
        name = name:gsub('-', '_')
        name = name:gsub('%.', '_')
    end
    return name:lower()
end

-- TODO: Add glob function to call just the available configs
for plugin, _ in pairs(plugs) do
    _ = nvim.plugs[plugin] -- Cache plugins for future use
    local func_name = convert2settings(plugin)
    local ok, error_code = pcall(nvim.command, 'runtime! autoload/plugins/'..func_name..'.vim')
    if not ok then
        if not string.match(error_code, 'Vim:E117') then
            nvim.echoerr("Something failed '"..error_code.."' Happened trying to source "..func_name..".vim")
        end
    end
end

require('plugins/config')

if nvim.has('nvim-0.5') then
    require('plugins/lsp')
end

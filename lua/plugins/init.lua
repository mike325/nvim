local nvim = require('nvim')

-- local inspect = nvim.inspect
local api = nvim.api

local get_plugins = function()
    local installed, plugins = pcall(api.nvim_get_var, 'plugs')

    if installed then
        return plugins
    end

    return nil
end

local plugins = get_plugins()

if plugins == nil then
    nvim.echoerr('No plugins were load')
    return nil
end

local convert2settings = function(name)
    name = name:gsub('+', '')
    name = name:gsub('[-/%.]', '_')

    return name:lower()
end

-- TODO: Add glob function to call just the available configs
for plugin, _ in pairs(plugins) do
    _ = nvim.plugins[plugin] -- Cache plugins for future use
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
    require('plugins/treesitter')
    require('grep')
end

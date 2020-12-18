local nvim = require('nvim')

-- TODO: Add dynamic plugin load
require('plugins/iron')

if nvim.has('nvim-0.5') then
    require('plugins/treesitter')
    require('plugins/lsp')
    require('plugins/completion')
    local telescope = require('plugins/telescope')
    if not telescope then
        require('grep')
    end
end

local function get_plugins()
    return nvim.g.plugs
end

local plugins = get_plugins()

if plugins == nil then
    return nil
end

local function convert2settings(name)
    name = name:gsub('+', '')
    name = name:gsub('[-/%.]', '_')

    return name:lower()
end

-- TODO: Add glob function to call just the available configs
for plugin, _ in pairs(plugins) do
    _ = nvim.plugins[plugin] -- Cache plugins for future use
    local func_name = convert2settings(plugin)
    local ok, error_code = pcall(nvim.command, 'runtime! autoload/plugins/'..func_name..'.vim')
    if not ok and not error_code:match('Vim:E117') then
        nvim.echoerr("Something failed '"..error_code.."' Happened trying to source "..func_name..".vim")
    end
end

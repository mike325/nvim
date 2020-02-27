local inspect = vim.inspect
local api = vim.api

local nvim = require('nvim')

nvim.command('packadd! cfilter')
nvim.command('packadd! matchit')

local ok, plugs = pcall(api.nvim_get_var, 'plugs')

if not ok then
    nvim.command('echoerr "Plugs are not load yet"')
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
for plugin, data in pairs(plugs) do
    _ = nvim.plugs[plugin] -- Cache plugins for future use
    local func_name = convert2settings(plugin)
    local ok, error_code = pcall(api.nvim_call_function, 'plugins#'..func_name..'#init', {data})
    if not ok then
        if not string.match(error_code, 'Vim:E117') then
            nvim.echoerr('Something failed "'..error_code..'" Happened trying to call '..'plugins#'..func_name..'#init')
        end
    end
end

require('plugins/config')

if nvim.has('nvim-0.5') then
    local lsp = require('plugins/lsp')
end

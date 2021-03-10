local nvim = require'nvim'
local echoerr = require'tools'.messages.echoerr
-- local load_module = require'tools'.helpers.load_module

-- TODO: Add dynamic plugin load

if nvim.has('nvim-0.5') then
    local plugins = {
        iron       = { ok = false, status  = false},
        lsp        = { ok = false, status  = false},
        telescope  = { ok = false, status  = false},
        neorocks   = { ok = false, status  = false},
        treesitter = { ok = false, status  = false},
        -- snippets   = { ok = false, status  = false},
        colors     = { ok = false, status  = false},
        statusline = { ok = false, status  = false},
        completion = { ok = false, status  = false},
    }

    for plugin, _ in pairs(plugins) do
        local ok, status = pcall(require, 'plugins/'..plugin)
        plugins[plugin].ok = ok
        plugins[plugin].status = status
        if not ok then
            echoerr(string.format('Failed to load %s, Error: %s', plugin, status))
            plugins[plugin].status = false
        end
    end

    if plugins.telescope.ok and not plugins.telescope.status then
        pcall(require, 'grep')
    end

    pcall(require, 'host')
    pcall(require, 'work')
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
    -- _ = nvim.plugins[plugin] -- Cache plugins for future use
    local func_name = convert2settings(plugin)
    local ok, error_code = pcall(nvim.command, 'runtime! autoload/plugins/'..func_name..'.vim')
    if not ok and not error_code:match('Vim:E117') then
        echoerr("Something failed '"..error_code.."' Happened trying to source "..func_name..".vim")
    end
end

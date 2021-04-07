local nvim      = require'nvim'
local get_files = require'tools'.files.get_files
local basename  = require'tools'.files.basename
local echoerr   = require'tools'.messages.echoerr

if nvim.has('nvim-0.5') then

    local plugins = get_files {
        path = require'sys'.base .. '/lua/plugins',
        glob = '*.lua'
    }

    for _,plugin in pairs(plugins) do
        plugin = basename(plugin:gsub('%.lua', ''))
        if plugin ~= 'init' then
            local ok, status = pcall(require, 'plugins/'..plugin)
            if not ok then
                echoerr(string.format('Failed to load "%s", Error: "%s"', plugin, status))
            end
        end
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
    name = name:gsub('+', ''):gsub('[-/%.]', '_')
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

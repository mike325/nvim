local host_plugins = {}

local share_dir = vim.fn.stdpath 'data'
local plugin_path = '%s/site/pack/%s/start/%s'

local plugin_names = {
    'host',
    'work',
    vim.uv.os_gethostname(),
}

for _, plugin in ipairs(plugin_names) do
    local plugin_dir = plugin_path:format(share_dir, plugin, plugin)
    if vim.fn.isdirectory(plugin_dir) == 1 then
        table.insert(host_plugins, { dir = plugin_dir })
    end
end

return host_plugins

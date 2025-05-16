local host_plugins = {}

local plugin_names = {
    'host',
    'work',
    vim.uv.os_gethostname(),
}

local share_dir = vim.fn.stdpath 'data' --[[@as string]]
for plugin in vim.iter(plugin_names) do
    for _, dir in ipairs { plugin, 'deps' } do
        for _, pack_dir in ipairs({'start', 'opt'}) do
            local plugin_dir = vim.fs.joinpath(share_dir, 'site', 'pack', dir, pack_dir, plugin)
            if vim.fn.isdirectory(vim.fs.normalize(plugin_dir)) == 1 then
                table.insert(host_plugins, {
                    dir = plugin_dir,
                    event = 'VeryLazy',
                })
            end
        end
    end
end

return host_plugins

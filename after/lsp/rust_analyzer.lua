local function reload_workspace(bufnr)
    -- bufnr = util.validate_bufnr(bufnr)
    local clients = vim.lsp.get_clients { bufnr = bufnr, name = 'rust_analyzer' }
    for _, client in ipairs(clients) do
        vim.notify 'Reloading Cargo Workspace'
        client.request('rust-analyzer/reloadWorkspace', nil, function(err)
            if err then
                error(tostring(err))
            end
            vim.notify 'Cargo workspace reloaded'
        end, 0)
    end
end

return {
    cmd = {
        'rust-analyzer',
    },
    filetypes = { 'rust' },
    root_markers = { 'Cargo.toml', '.git' },
    capabilities = {
        experimental = {
            serverStatusNotification = true,
        },
    },
    before_init = function(init_params, config)
        -- See https://github.com/rust-lang/rust-analyzer/blob/eb5da56d839ae0a9e9f50774fa3eb78eb0964550/docs/dev/lsp-extensions.md?plain=1#L26
        if config.settings and config.settings['rust-analyzer'] then
            init_params.initializationOptions = config.settings['rust-analyzer']
        end
    end,
    on_attach = function()
        vim.api.nvim_buf_create_user_command(0, 'CargoReload', function()
            reload_workspace(0)
        end, { desc = 'Reload current cargo workspace' })
    end,
}

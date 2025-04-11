-- local lua_runtime = vim.split(package.path, ';')
-- table.insert(lua_runtime, 'lua/?.lua')
-- table.insert(lua_runtime, 'lua/?/init.lua')

return {
    cmd = {
        'lua-language-server',
    },
    filetypes = { 'lua' },
    root_markers = { 'init.lua', '.git' },
    settings = {
        Lua = {
            hint = {
                enable = true,
            },
            -- completion = {
            --     keywordSnippet = 'Enable',
            --     callSnippet = 'Both',
            -- },
            runtime = {
                -- Tell the language server which version of Lua you're using
                -- (most likely LuaJIT in the case of Neovim)
                version = 'LuaJIT',
                -- Setup your lua path
                -- path = lua_runtime,
            },
            workspace = {
                -- Make the server aware of Neovim runtime files
                -- library = vim.api.nvim_get_runtime_file('', true),
                checkThirdParty = false,
                library = {
                    vim.env.VIMRUNTIME,
                },
            },
            telemetry = {
                enable = false,
            },
            diagnostics = {
                globals = {
                    'packer_plugins',
                    'bit',
                    'vim',
                    'nvim',
                    'python',
                    'P',
                    'RELOAD',
                    'PASTE',
                    'STORAGE',
                    'use',
                    'use_rocks',
                    'describe',
                    'it',
                    'before_each',
                    'after_each',
                    'setup',
                    'teardown',
                    'assert',
                },
            },
        },
    },
}

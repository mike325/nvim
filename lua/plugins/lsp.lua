return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            require 'configs.lsp'
        end,
        lazy = false,
        priority = 100,
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        priority = 90,
        pin = true,
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'nvim-lua/plenary.nvim' },
        },
    },
    -- {
    --     'weilbith/nvim-floating-tag-preview',
    --     lazy = true,
    --     event = { 'CursorHold' },
    --     dependencies = {
    --         { 'neovim/nvim-lspconfig' },
    --     },
    -- },
}

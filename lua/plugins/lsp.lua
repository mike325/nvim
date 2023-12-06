return {
    {
        'neovim/nvim-lspconfig',
        config = function()
            require 'configs.lsp'
        end,
        event = 'VeryLazy',
        -- lazy = false,
        -- priority = 100,
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        -- priority = 90,
        event = 'VeryLazy',
        pin = true,
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'nvim-lua/plenary.nvim' },
        },
    },
    {
        'nvimdev/lspsaga.nvim',
        enabled = false,
        config = function()
            require('lspsaga').setup {}
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            'nvim-tree/nvim-web-devicons', -- optional
        },
    },
}

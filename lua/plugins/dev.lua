return {
    {
        'mfussenegger/nvim-dap',
        -- event = 'VeryLazy',
        -- event = { 'CursorHold', 'CmdlineEnter' },
        cmd = { 'DapStart', 'DapContinue' },
        cond = function()
            return not vim.g.vscode and not vim.g.minimal
        end,
        config = function()
            require 'configs.dap'
        end,
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                cond = not vim.g.minimal,
            },
            {
                'jbyuki/one-small-step-for-vimkind',
                cond = not vim.g.minimal,
            },
            {
                'folke/neodev.nvim',
                cond = not vim.g.minimal,
                opts = {},
            },
        },
    },
    {
        'L3MON4D3/LuaSnip',
        config = function()
            require 'configs.luasnip'
        end,
        event = { 'InsertEnter', 'CursorHold' },
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'onsails/lspkind-nvim' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'ray-x/cmp-treesitter' },
            { 'lukas-reineke/cmp-under-comparator' },
            { 'hrsh7th/cmp-cmdline' },
        },
        config = function()
            require 'configs.cmp'
        end,
        event = { 'InsertEnter', 'CursorHold' },
        cond = function()
            return not vim.g.vscode
        end,
        -- after = 'nvim-lspconfig',
    },
    {
        'neovim/nvim-lspconfig',
        config = function()
            require 'configs.lsp'
        end,
        -- event = 'VeryLazy',
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
        cond = function()
            return not vim.g.vscode
        end,
        dependencies = {
            'nvim-treesitter/nvim-treesitter', -- optional
            'nvim-tree/nvim-web-devicons', -- optional
        },
    },
}

return {
    {
        'mfussenegger/nvim-dap',
        event = 'VeryLazy',
        -- event = { 'CursorHold', 'CmdlineEnter' },
        cmd = { 'DapStart', 'DapContinue' },
        cond = not vim.env.VIM_MIN and not vim.g.minimal,
        config = function()
            require 'configs.dap'
        end,
        dependencies = {
            {
                'rcarriga/nvim-dap-ui',
                cond = not vim.env.VIM_MIN and not vim.g.minimal,
            },
        },
    },
    {
        'L3MON4D3/LuaSnip',
        config = function()
            require 'configs.luasnip'
        end,
        event = 'VeryLazy',
        -- event = 'InsertEnter',
        lazy = true,
    },
    {
        'hrsh7th/nvim-cmp',
        dependencies = {
            { 'hrsh7th/cmp-nvim-lsp', lazy = true, event = 'VeryLazy' },
            { 'hrsh7th/cmp-buffer', lazy = true, event = 'VeryLazy' },
            { 'hrsh7th/cmp-path', lazy = true, event = 'VeryLazy' },
            { 'hrsh7th/cmp-nvim-lua', lazy = true, event = 'VeryLazy' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help', lazy = true, event = 'VeryLazy' },
            { 'onsails/lspkind-nvim', lazy = true, event = 'VeryLazy' },
            { 'saadparwaiz1/cmp_luasnip', lazy = true, event = 'VeryLazy' },
            { 'ray-x/cmp-treesitter', lazy = true, event = 'VeryLazy' },
            { 'lukas-reineke/cmp-under-comparator', lazy = true, event = 'VeryLazy' },
            { 'hrsh7th/cmp-cmdline', lazy = true, event = 'VeryLazy' },
        },
        config = function()
            require 'configs.cmp'
        end,
        event = 'InsertEnter',
        -- after = 'nvim-lspconfig',
    },
}

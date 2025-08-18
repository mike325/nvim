return {
    {
        'tpope/vim-dadbod',
    },
    {
        'mfussenegger/nvim-dap',
        -- event = { 'CursorHold', 'CmdlineEnter' },
        cmd = { 'DapStart', 'DapContinue' },
        keys = { '<F5>' },
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
                dependencies = { 'nvim-neotest/nvim-nio' },
            },
            {
                'theHamsta/nvim-dap-virtual-text',
                opts = { virt_text_pos = 'eol' },
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
        build = function(plugin)
            local has_compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
            local has_make = vim.fn.executable 'make' == 1
            if not has_compiler or not has_make then
                return 0
            end
            local plugin_dir = plugin.dir
            local cmd = { 'make', 'install_jsregexp' }
            local rc = vim.system(cmd, { text = true, cwd = plugin_dir }):wait()
            _G['luasnip_build_log'] = rc
            return rc.code == 0
        end,
        event = { 'InsertEnter', 'CursorHold' },
    },
    {
        'hrsh7th/nvim-cmp',
        enabled = false,
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
    },
    {
        'neovim/nvim-lspconfig',
        -- enabled = false,
        -- priority = 100,
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
        },
    },
}

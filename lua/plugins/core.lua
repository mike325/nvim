-- TODO: Add support for luarocks ?
-- if has_compiler and has_python then
--     use_rocks { 'luacheck', 'jsregexp', 'lua-yaml' }
-- end
return {
    { 'folke/lazy.nvim', version = '*' },
    {
        'catppuccin/nvim',
        name = 'catppuccin',
        lazy = false,
        opts = {
            flavour = 'mocha', -- latte, frappe, macchiato, mocha
            integrations = {
                cmp = true,
                gitsigns = true,
                nvimtree = false,
                telescope = true,
                notify = true,
                mini = true,
                hop = true,
                dap = {
                    enabled = true,
                    enable_ui = true,
                },
                native_lsp = {
                    enabled = true,
                    underlines = {
                        errors = { 'undercurl' },
                    },
                },
                treesitter = true,
                treesitter_context = true,
                -- lsp_trouble = true,
                vimwiki = true,
            },
        },
    },
    { 'tpope/vim-abolish' },
    -- { 'tpope/vim-repeat' },
    { 'nvim-lua/popup.nvim', lazy = true },
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'rcarriga/nvim-notify', lazy = true },
    { 'kevinhwang91/nvim-bqf', lazy = true, ft = 'qf' },
    { 'tweekmonster/startuptime.vim', cmd = { 'StartupTime' } },
    {
        'nvim-tree/nvim-web-devicons',
        cond = not vim.env.NO_COOL_FONTS,
    },
    {
        'tami5/sqlite.lua',
        name = 'sqlite',
        cond = require('sys').has_sqlite,
        lazy = true,
    },
    {
        'echasnovski/mini.nvim',
        config = function()
            require 'configs.mini'
        end,
        event = 'CursorHold',
        cmd = {
            'SessionSave',
            'SessionLoad',
            'SessionDelete',
        },
    },
    {
        'ojroques/vim-oscyank',
        event = 'TextYankPost',
        init = function()
            vim.g.oscyank_silent = true
        end,
        config = function()
            require 'configs.oscyank'
        end,
    },
}

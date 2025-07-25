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
        cond = function()
            return not vim.g.vscode
        end,
        opts = {
            flavour = 'mocha', -- latte, frappe, macchiato, mocha
            ui = { border = 'rounded' },
            -- change_detection = { notify = false },
            -- dev = { path = vim.g.projects_dir },
            install = {
                missing = false, -- Do not automatically install on startup.
            },
            performance = {
                -- cache = {
                --     enabled = false,
                -- },
                -- reset_packpath = true, -- reset the package path to improve startup time
                rtp = {
                    -- reset = true,
                    -- paths = {},
                    disabled_plugins = {
                        -- 'gzip',
                        -- "matchit",
                        -- "matchparen",
                        -- "netrwPlugin",
                        'tarPlugin',
                        'tohtml',
                        'tutor',
                        'zipPlugin',
                    },
                },
            },
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
    {
        'tpope/vim-abolish',
        event = 'CmdlineEnter',
        cmd = {
            'S',
            'Subvert',
            'Abolish',
        },
    },
    -- { 'tpope/vim-repeat' },
    { 'nvim-lua/popup.nvim', lazy = true },
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'rcarriga/nvim-notify', lazy = true },
    {
        'kevinhwang91/nvim-bqf',
        cond = function()
            return not vim.g.vscode
        end,
        lazy = true,
        ft = 'qf',
        opts = {
            auto_enable = true,
            auto_resize_height = true,
            func_map = {
                -- drop = 'o',
                -- openc = 'O',
                -- split = '<C-s>',
                -- tabdrop = '<C-t>',
                -- -- set to empty string to disable
                -- tabc = '',
                -- ptogglemode = 'z,',
            },
        },
    },
    {
        'tweekmonster/startuptime.vim',
        cmd = { 'StartupTime' },
        cond = function()
            return not vim.g.vscode
        end,
    },
    {
        'tami5/sqlite.lua',
        name = 'sqlite',
        cond = require('sys').has_sqlite,
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
}

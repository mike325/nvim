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
    { 'tpope/vim-repeat' },
    { 'nvim-lua/popup.nvim', lazy = true },
    { 'nvim-lua/plenary.nvim', lazy = true },
    { 'rcarriga/nvim-notify', lazy = true },
    { 'kevinhwang91/nvim-bqf', lazy = true },
    { 'nanotee/luv-vimdocs', event = 'CmdlineEnter' },
    { 'tweekmonster/startuptime.vim', cmd = { 'StartupTime' } },
    {
        'kyazdani42/nvim-web-devicons',
        cond = not vim.env.NO_COOL_FONTS,
    },
    {
        'tami5/sqlite.lua',
        name = 'sqlite',
        cond = require('sys').has_sqlite,
        lazy = true,
    },
    {
        'tpope/vim-surround',
        event = { 'CursorHold', 'CursorHoldI' },
        init = function()
            vim.g['surround_' .. vim.fn.char2nr '¿'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '?'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '¡'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr '!'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr ';'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr ':'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr 'q'] = [[``\r'']]
        end,
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
        'numToStr/Comment.nvim',
        config = function()
            require 'configs.comments'
        end,
    },
    {
        'chrisgrieser/nvim-various-textobjs',
        config = function()
            require('various-textobjs').setup {
                useDefaultKeymaps = false,
            }

            vim.keymap.set({ 'o', 'x' }, 'ie', function()
                require('various-textobjs').entireBuffer()
            end)

            -- NOTE: Add missing key text-obj?
            vim.keymap.set({ 'o', 'x' }, 'av', function()
                require('various-textobjs').value(true)
            end)
            vim.keymap.set({ 'o', 'x' }, 'iv', function()
                require('various-textobjs').value(true)
            end)

            vim.keymap.set({ 'o', 'x' }, 'ii', function()
                require('various-textobjs').indentation(true, true)
            end)
            vim.keymap.set({ 'o', 'x' }, 'ai', function()
                require('various-textobjs').indentation(false, false)
            end)
        end,
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
    {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require 'configs.pairs'
        end,
    },
}

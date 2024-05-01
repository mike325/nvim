return {
    { 'imsnif/kdl.vim' },
    {
        'vimwiki/vimwiki',
        init = function()
            vim.g.vimwiki_list = {
                { path = '~/notes/', syntax = 'markdown', ext = '.md' },
                { path = '~/work/', syntax = 'markdown', ext = '.md' },
            }
            vim.g.vimwiki_hl_headers = 1
            vim.g.vimwiki_hl_cb_checked = 2
            vim.g.vimwiki_listsyms = ' ○◐●✓'
            vim.g.vimwiki_listsym_rejected = '✗'
        end,
        config = function() end,
        ft = { 'markdown', 'wiki', 'vimwiki' },
    },
    {
        'lervag/vimtex',
        cond = vim.fn.executable 'latexmk' == 1 and not vim.g.minimal,
        init = function()
            require 'configs.vimtex'
        end,
        ft = { 'bib', 'tex', 'latex', 'bibtex' },
    },
    {
        'norcalli/nvim-colorizer.lua',
        config = function()
            require('colorizer').setup()
        end,
        opts = {},
        lazy = true,
        event = { 'CursorHold', 'CursorHoldI', 'BufWritePost', 'TextChanged', 'TextChangedI' },
    },
    {
        'Yggdroot/indentLine',
        cond = function()
            return not vim.g.vscode and not vim.g.minimal
        end,
        init = function()
            vim.g.indentLine_fileTypeExclude = {
                'Telescope',
                'TelescopePrompt',
                'TelescopeResults',
                'log',
                'help',
                'packer',
            }

            vim.g.indentLine_bufTypeExclude = {
                'terminal',
                'man',
                'nofile',
            }

            vim.g.indentLine_bufNameExclude = {
                'term://.*',
                'man://.*',
            }
        end,
        event = { 'VeryLazy', 'Filetype' },
    },
    {
        'tommcdo/vim-lion',
        cond = not vim.g.minimal,
        config = function()
            vim.g.lion_squeeze_spaces = 1
        end,
        event = 'VeryLazy',
    },
    {
        'folke/todo-comments.nvim',
        cond = function()
            local has_rg = vim.fn.executable 'rg' == 1
            return not vim.g.minimal and has_rg
        end,
        config = function()
            require 'configs.todos'
        end,
        lazy = true,
        event = 'VeryLazy',
    },
    {
        'folke/trouble.nvim',
        cond = not vim.g.minimal and not vim.g.vscode,
        config = function()
            require 'configs.trouble'
        end,
        lazy = true,
        event = 'VeryLazy',
    },

    {
        'nvim-lualine/lualine.nvim',
        cond = function()
            return not vim.g.vscode
        end,
        config = function()
            require 'configs.lualine'
        end,
        event = 'VeryLazy',
        dependencies = {
            { 'arkav/lualine-lsp-progress' },
            { 'catppuccin' },
        },
    },
    {
        'folke/noice.nvim',
        enabled = false,
        -- cond = function()
        --     return not vim.g.vscode
        -- end,
        config = function()
            require 'configs.noice'
        end,
        dependencies = {
            { 'MunifTanjim/nui.nvim' },
        },
    },
}

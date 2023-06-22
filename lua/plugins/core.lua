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
}

-- packer.startup(function()
--     -- BUG: Seems like luarocks is not supported in windows
--     if has_compiler and has_python then
--         use_rocks { 'luacheck', 'jsregexp', 'lua-yaml' }
--     end
--
--
--     use {
--         'chrisgrieser/nvim-various-textobjs',
--         config = function()
--             require('various-textobjs').setup {
--                 useDefaultKeymaps = false,
--             }
--
--             vim.keymap.set({ 'o', 'x' }, 'ie', function()
--                 require('various-textobjs').entireBuffer()
--             end)
--
--             -- NOTE: Add missing key text-obj?
--             vim.keymap.set({ 'o', 'x' }, 'av', function()
--                 require('various-textobjs').value(true)
--             end)
--             vim.keymap.set({ 'o', 'x' }, 'iv', function()
--                 require('various-textobjs').value(true)
--             end)
--
--             vim.keymap.set({ 'o', 'x' }, 'ii', function()
--                 require('various-textobjs').indentation(true, true)
--             end)
--             vim.keymap.set({ 'o', 'x' }, 'ai', function()
--                 require('various-textobjs').indentation(false, false)
--             end)
--         end,
--     }
--
--     use {
--         'lervag/vimtex',
--         cond = function()
--             return vim.fn.executable 'latexmk' == 1 and not vim.env.VIM_MIN and not vim.g.minimal
--         end,
--         setup = function()
--             require 'configs.vimtex'
--         end,
--         ft = { 'bib', 'tex', 'latex', 'bibtex' },
--     }
--
--     use {
--         'norcalli/nvim-colorizer.lua',
--         config = function()
--             vim.opt.termguicolors = true
--             require('colorizer').setup()
--         end,
--         event = { 'CursorHold', 'CursorMoved', 'InsertEnter' },
--     }
--
--     use {
--         'tpope/vim-surround',
--         event = 'VimEnter',
--         setup = function()
--             vim.g['surround_' .. vim.fn.char2nr '¿'] = '¿\r?'
--             vim.g['surround_' .. vim.fn.char2nr '?'] = '¿\r?'
--             vim.g['surround_' .. vim.fn.char2nr '¡'] = '¡\r!'
--             vim.g['surround_' .. vim.fn.char2nr '!'] = '¡\r!'
--             vim.g['surround_' .. vim.fn.char2nr ';'] = ':\r:'
--             vim.g['surround_' .. vim.fn.char2nr ':'] = ':\r:'
--             vim.g['surround_' .. vim.fn.char2nr 'q'] = [[``\r'']]
--         end,
--     }
--
--     use {
--         'ojroques/vim-oscyank',
--         event = 'VimEnter',
--         setup = function()
--             vim.g.oscyank_silent = true
--         end,
--         config = function()
--             require 'configs.oscyank'
--         end,
--     }
--
--     use {
--         'windwp/nvim-autopairs',
--         event = 'InsertEnter',
--         config = function()
--             require 'configs.pairs'
--         end,
--     }
--
--     use {
--         'Yggdroot/indentLine',
--         cond = function()
--             return not vim.env.VIM_MIN and not vim.g.minimal
--         end,
--         setup = function()
--             vim.g.indentLine_fileTypeExclude = {
--                 'Telescope',
--                 'TelescopePrompt',
--                 'TelescopeResults',
--                 'log',
--                 'help',
--                 'packer',
--             }
--
--             vim.g.indentLine_bufTypeExclude = {
--                 'terminal',
--                 'man',
--                 'nofile',
--             }
--
--             vim.g.indentLine_bufNameExclude = {
--                 'term://.*',
--                 'man://.*',
--             }
--         end,
--     }
--
--
--     use {
--         'glacambre/firenvim',
--         cond = function()
--             local ssh = vim.env.SSH_CONNECTION or false
--             local min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
--             local firenvim = vim.g.started_by_firenvim ~= nil
--             return (not min and not ssh) or firenvim
--         end,
--         config = function()
--             if vim.g.started_by_firenvim ~= nil then
--                 vim.api.nvim_set_keymap('n', '<C-z>', '<cmd>call firenvim#hide_frame()<CR>', { noremap = true })
--             end
--         end,
--         run = function()
--             vim.fn['firenvim#install'](0)
--         end,
--     }
--
--     use {
--         'phaazon/hop.nvim',
--         cond = function()
--             return not vim.env.VIM_MIN and not vim.g.minimal
--         end,
--         config = function()
--             require 'configs.hop'
--         end,
--     }
--
--     use {
--         'nvim-telescope/telescope.nvim',
--         config = function()
--             require 'configs.telescope'
--         end,
--         requires = {
--             { 'nvim-lua/plenary.nvim' },
--             { 'nvim-lua/popup.nvim' },
--         },
--         tag = (vim.fn.has 'nvim-0.6' == 0 and 'nvim-0.5.0' or nil),
--     }
--
--     use {
--         'L3MON4D3/LuaSnip',
--         config = function()
--             require 'configs.luasnip'
--         end,
--     }
--
--     use {
--         'hrsh7th/nvim-cmp',
--         commit = (vim.fn.has 'nvim-0.7' == 0 and '07132dc597e94a8b6df75efce9784a581f55742c' or nil),
--         requires = {
--             { 'hrsh7th/cmp-nvim-lsp' },
--             { 'hrsh7th/cmp-buffer' },
--             { 'hrsh7th/cmp-path' },
--             { 'hrsh7th/cmp-nvim-lua' },
--             { 'hrsh7th/cmp-nvim-lsp-signature-help' },
--             { 'onsails/lspkind-nvim' },
--             { 'saadparwaiz1/cmp_luasnip' },
--             { 'ray-x/cmp-treesitter' },
--             { 'lukas-reineke/cmp-under-comparator' },
--             { 'hrsh7th/cmp-cmdline' },
--         },
--         config = function()
--             require 'configs.cmp'
--         end,
--         -- after = 'nvim-lspconfig',
--     }
--
--     use {
--         'AckslD/nvim-neoclip.lua',
--         config = function()
--             local db_path
--             local has_sqlite = require('sys').has_sqlite
--             if has_sqlite then
--                 db_path = require('sys').db_root .. '/neoclip.sqlite3'
--             end
--             require('neoclip').setup {
--                 enable_persistent_history = has_sqlite,
--                 db_path = db_path,
--                 default_register = '+',
--                 keys = {
--                     telescope = {
--                         i = {
--                             select = '<CR>',
--                             paste = '<A-p>',
--                             paste_behind = '<A-P>',
--                         },
--                         n = {
--                             select = '<CR>',
--                             paste = 'p',
--                             paste_behind = 'P',
--                         },
--                     },
--                 },
--             }
--             -- Since we need to load after telescope, it should be safe to call this here
--             require('telescope').load_extension 'neoclip'
--         end,
--         cond = function()
--             -- Windows throws an error complaining it has an invalid syntax, I look in to it later
--             return vim.fn.has 'win32' == 0
--         end,
--         requires = {
--             { 'nvim-telescope/telescope.nvim' },
--             (require('sys').has_sqlite and { 'tami5/sqlite.lua' } or nil),
--         },
--     }
--
--     use {
--         'numToStr/Comment.nvim',
--         config = function()
--             require 'configs.comments'
--         end,
--     }
--
--     use {
--         'vimwiki/vimwiki',
--         setup = function()
--             vim.g.vimwiki_list = {
--                 { path = '~/notes/', syntax = 'markdown', ext = '.md' },
--                 { path = '~/work/', syntax = 'markdown', ext = '.md' },
--             }
--             vim.g.vimwiki_hl_headers = 1
--             vim.g.vimwiki_hl_cb_checked = 2
--             vim.g.vimwiki_listsyms = ' ○◐●✓'
--             vim.g.vimwiki_listsym_rejected = '✗'
--         end,
--         -- config = function()
--         --     require 'configs.vimwiki'
--         -- end,
--     }
--
--     use {
--         'echasnovski/mini.nvim',
--         config = function()
--             require 'configs.mini'
--         end,
--     }
--
--     use {
--         'mfussenegger/nvim-dap',
--         -- event = { 'CursorHold', 'CmdlineEnter' },
--         -- cmd = { 'DapStart', 'DapContinue' },
--         cond = function()
--             return not vim.env.VIM_MIN and not vim.g.minimal
--         end,
--         config = function()
--             require 'configs.dap'
--         end,
--         requires = {
--             {
--                 'rcarriga/nvim-dap-ui',
--                 cond = function()
--                     return not vim.env.VIM_MIN and not vim.g.minimal
--                 end,
--             },
--         },
--     }
--
--     use {
--         'nvim-lualine/lualine.nvim',
--         config = function()
--             require 'configs.lualine'
--         end,
--         requires = {
--             { 'arkav/lualine-lsp-progress' },
--         },
--     }
--
--     use {
--         'tommcdo/vim-lion',
--         cond = function()
--             return not vim.env.VIM_MIN and not vim.g.minimal
--         end,
--         config = function()
--             vim.g.lion_squeeze_spaces = 1
--         end,
--     }
--
--     use {
--         'folke/todo-comments.nvim',
--         cond = function()
--             local no_min = vim.env.VIM_MIN == nil and vim.g.minimal == nil
--             local has_rg = vim.fn.executable 'rg' == 1
--             return no_min and has_rg
--         end,
--         config = function()
--             require 'configs.todos'
--         end,
--         requires = {
--             {
--                 'folke/trouble.nvim',
--                 cond = function()
--                     return not vim.env.VIM_MIN and not vim.g.minimal
--                 end,
--                 config = function()
--                     require 'configs.trouble'
--                 end,
--             },
--         },
--     }
-- end)

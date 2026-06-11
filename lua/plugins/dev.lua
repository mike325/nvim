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
        'saghen/blink.cmp',
        dependencies = { 'rafamadriz/friendly-snippets' },
        version = '1.*',
        ---@module 'blink.cmp'
        ---@type blink.cmp.Config
        opts = {
            -- 'default' (recommended) for mappings similar to built-in completions (C-y to accept)
            -- 'super-tab' for mappings similar to vscode (tab to accept)
            -- 'enter' for enter to accept
            -- 'none' for no mappings
            --
            -- All presets have the following mappings:
            -- C-space: Open menu or open docs if already open
            -- C-n/C-p or Up/Down: Select next/previous item
            -- C-e: Hide menu
            -- C-k: Toggle signature help (if signature.enabled = true)
            --
            -- See :h blink-cmp-config-keymap for defining your own keymap
            keymap = {
                preset = 'none',
                ['<Up>'] = { 'select_prev', 'fallback' },
                ['<Down>'] = { 'select_next', 'fallback' },
                ['<C-n>'] = { 'select_next', 'fallback' },
                ['<C-p>'] = { 'select_prev', 'fallback' },
                ['<C-space>'] = {
                    function(cmp)
                        cmp.show { providers = { 'snippets' } }
                    end,
                },
            },

            appearance = {
                -- 'mono' (default) for 'Nerd Font Mono' or 'normal' for 'Nerd Font'
                -- Adjusts spacing to ensure icons are aligned
                nerd_font_variant = 'mono',
            },

            -- (Default) Only show the documentation popup when manually triggered
            completion = {
                menu = {
                    border = 'single',
                },
                ghost_text = { enabled = true },
                documentation = { auto_show = true, window = { border = 'single' } },
            },

            cmdline = {
                keymap = {
                    preset = 'default',
                    ['<CR>'] = { 'accept', 'fallback' },
                    ['<Tab>'] = { 'show_and_insert_or_accept_single', 'select_next' },
                    ['<S-Tab>'] = { 'show_and_insert_or_accept_single', 'select_prev' },
                    ['<C-n>'] = { 'select_next', 'fallback' },
                    ['<C-p>'] = { 'select_prev', 'fallback' },
                    ['<C-y>'] = { 'select_and_accept', 'fallback' },
                    ['<C-e>'] = { 'cancel', 'fallback' },
                },
                completion = {
                    menu = { auto_show = true },
                    -- ghost_text = { enabled = true },
                    list = {
                        selection = { preselect = false },
                    },
                },
            },

            signature = { window = { border = 'single' } },

            -- Default list of enabled providers defined so that you can extend it
            -- elsewhere in your config, without redefining it, due to `opts_extend`
            sources = {
                default = { 'lsp', 'path', 'snippets', 'buffer' },
            },

            -- (Default) Rust fuzzy matcher for typo resistance and significantly better performance
            -- You may use a lua implementation instead by using `implementation = "lua"`
            -- or fallback to the lua implementation,
            -- when the Rust fuzzy matcher is not available, by using `implementation = "prefer_rust"`
            --
            -- See the fuzzy documentation for more information
            fuzzy = { implementation = 'prefer_rust_with_warning' },
        },
        opts_extend = { 'sources.default' },
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

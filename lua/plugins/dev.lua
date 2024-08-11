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
        -- lazy = false,
        -- priority = 100,
    },
    {
        'jose-elias-alvarez/null-ls.nvim',
        enabled = false,
        -- priority = 90,
        event = 'VeryLazy',
        pin = true,
        dependencies = {
            { 'neovim/nvim-lspconfig' },
            { 'nvim-lua/plenary.nvim' },
        },
    },
    {
        'ycm-core/YouCompleteMe',
        -- enabled = false,
        -- priority = 90,
        -- event = 'SwapExists',
        cond = function()
            local has_compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
            if vim.fn.has 'win32' == 1 then
                has_compiler = vim.fn.executable 'msbuild' == 1
            end
            local has_cmake = vim.fn.executable 'cmake' == 1
            local has_python = vim.fn.executable 'python3' == 1
            return has_compiler and has_cmake and has_python and vim.fn.has 'python3' == 1
        end,
        build = function(plugin)
            local plugin_dir = plugin.dir
            local cmd = { vim.fn.exepath 'python3', 'install.py' }
            local rc = vim.system(cmd, { text = true, cwd = plugin_dir }):wait()
            _G['ycm_build_log'] = rc
            return rc.code == 0
        end,
        init = function()
            vim.g.ycm_enabled = true
            -- TODO: Turnoff nvim-cmp and integrate mappings into ycm

            vim.g.ycm_min_num_of_chars_for_completion = 2
            vim.g.ycm_auto_trigger = 1
            vim.g.ycm_complete_in_comments = 1
            vim.g.ycm_seed_identifiers_with_syntax = 1
            vim.g.ycm_add_preview_to_completeopt = 0
            vim.g.ycm_autoclose_preview_window_after_completion = 1
            vim.g.ycm_autoclose_preview_window_after_insertion = 1

            vim.g.ycm_key_list_select_completion = { '<C-n>', '<Down>' }
            vim.g.ycm_key_list_previous_completion = { '<C-p>', '<Up>' }
            vim.g.ycm_key_list_stop_completion = { '<C-y>', '<CR>' }
            -- vim.g.ycm_error_symbol   = tools#get_icon('error')
            -- vim.g.ycm_warning_symbol = tools#get_icon('warn')
            vim.g.ycm_extra_conf_globlist = { '~/.vim/*', '~/.config/nvim/*', '~/AppData/nvim/*' }
            vim.g.ycm_python_interpreter_path = vim.fn.exepath 'python3'
            -- vim.g.ycm_key_detailed_diagnostics = '<leader>D'

            vim.g.ycm_collect_identifiers_from_tags_files = 1
            vim.g.ycm_filetype_specific_completion_to_disable = {}
            vim.g.ycm_confirm_extra_conf = 0
            vim.g.ycm_seed_identifiers_with_syntax = 1
            vim.g.ycm_filetype_whitelist = { python = 1 }
        end,
        config = function() end,
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

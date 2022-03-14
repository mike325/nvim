local ok, packer = pcall(require, 'packer')

local has_compiler
if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
    -- NOTE: windows' clang by default needs msbuild to compile treesitter parsers,
    has_compiler = vim.fn.executable 'gcc' == 1
else
    has_compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
end

-- local has_make = vim.fn.executable('make') == 1

if not ok then
    return false
end

packer.init {
    -- log = {level = 'debug'},
    luarocks = { python_cmd = 'python3' },
    profile = {
        enable = false,
        threshold = 1, -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },
    display = {
        open_fn = require('packer.util').float,
    },
    git = {
        clone_timeout = 90, -- Timeout, in seconds, for git clones
    },
}

packer.startup(function()
    -- BUG: Seems like luarocks is not supported in windows
    if has_compiler then
        use_rocks { 'luacheck', 'lua-cjson', 'md5' }
    end

    use 'wbthomason/packer.nvim'

    use { 'PProvost/vim-ps1' }
    use { 'kurayama/systemd-vim-syntax' }
    use { 'raimon49/requirements.txt.vim' }

    use { 'nanotee/luv-vimdocs', event = 'CmdlineEnter' }
    use { 'tweekmonster/startuptime.vim', cmd = { 'StartupTime' } }

    use { 'kyazdani42/nvim-web-devicons' }
    use { 'kevinhwang91/nvim-bqf' }

    use { 'nvim-lua/popup.nvim' }
    use { 'nvim-lua/plenary.nvim' }
    use { 'rcarriga/nvim-notify' }

    use {
        'tami5/sqlite.lua',
        module = 'sqlite',
        cond = function()
            return require('sys').has_sqlite
        end,
    }

    use {
        'lervag/vimtex',
        cond = function()
            return vim.fn.executable 'latexmk' == 1 and not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
            require 'plugins.vimtex'
        end,
        ft = { 'bib', 'tex', 'latex', 'bibtex' },
    }

    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            vim.opt.termguicolors = true
            require('colorizer').setup()
        end,
        event = { 'CursorHold', 'CursorMoved', 'InsertEnter' },
    }

    use { 'tpope/vim-repeat', event = 'VimEnter' }
    use { 'tpope/vim-apathy', event = 'VimEnter' }
    -- use {'tpope/vim-commentary', event = 'VimEnter'}

    use {
        'tpope/vim-surround',
        event = 'VimEnter',
        setup = function()
            vim.g['surround_' .. vim.fn.char2nr '¿'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '?'] = '¿\r?'
            vim.g['surround_' .. vim.fn.char2nr '¡'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr '!'] = '¡\r!'
            vim.g['surround_' .. vim.fn.char2nr ';'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr ':'] = ':\r:'
            vim.g['surround_' .. vim.fn.char2nr 'q'] = [[``\r'']]
        end,
    }

    use {
        'tpope/vim-projectionist',
        event = { 'CmdlineEnter', 'CursorHold' },
        config = function()
            local set_autocmd = require('neovim.autocmds').set_autocmd
            -- TODO: Make this more "project" tailored, set git and language specific
            --       projections depending of what's in the cwd
            -- stylua: ignore
            vim.g.common_projections = {
                ['.projections.json']          = { type = 'Projections' },
                ['.gitignore']                 = { type = 'Gitignore' },
                ['.git/hooks/*']               = { type = 'GitHooks' },
                ['.git/config']                = { type = 'Git' },
                ['.git/info/*']                = { type = 'Git' },
                ['.github/workflows/main.yml'] = { type = 'Github' },
                ['.github/workflows/*.yml']    = { type = 'Github' },
                ['.travis.yml']                = { type = 'Travis' },
                ['.pre-commit-config.yaml']    = { type = 'PreCommit' },
                ['.ycm_extra_conf.py']         = { type = 'YCM' },
                ['pyproject.toml']             = { type = 'PyProject' },
                ['.flake8']                    = { type = 'Flake' },
                ['.stylua.toml']               = { type = 'Stylua' },
                ['.project.vim']               = { type = 'Project' },
                ['.clang-format']              = { type = 'Clang' },
                ['.clang-*']                   = { type = 'Clang' },
                ['compile_flags.txt']          = { type = 'CompileFlags' },
                ['compile_commands.json']      = { type = 'CompileDB' },
                ['UltiSnips/*.snippets']       = { type = 'UltiSnips' },
                ['README.md']                  = { type = 'Readme' },
                ['LICENSE']                    = { type = 'License' },
                ['Makefile']                   = { type = 'Makefile' },
                ['CMakeLists.txt']             = { type = 'CMake' },
                ['*.cmake']                    = { type = 'CMake' },
            }
            set_autocmd {
                event = 'User',
                pattern = 'ProjectionistDetect',
                cmd = 'call projectionist#append(getcwd(), g:common_projections)',
                group = 'CommonProjections',
            }
        end,
    }

    use { 'tpope/vim-fugitive', event = { 'CmdlineEnter', 'CursorHold' } }
    use { 'junegunn/gv.vim', cmd = 'GV', wants = 'vim-fugitive' }

    use {
        'kana/vim-textobj-user',
        requires = {
            { 'kana/vim-textobj-line' },
            { 'kana/vim-textobj-entire' },
            { 'michaeljsmith/vim-indent-object' },
            { 'glts/vim-textobj-comment' },
        },
    }

    use {
        'ojroques/vim-oscyank',
        event = 'VimEnter',
        config = function()
            require 'plugins.oscyank'
        end,
    }

    use {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require 'plugins.pairs'
        end,
    }

    use {
        'tommcdo/vim-lion',
        event = 'VimEnter',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            vim.g.lion_squeeze_spaces = 1
        end,
    }

    use {
        'tpope/vim-abolish',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        event = { 'InsertEnter', 'CmdwinEnter' },
        -- TODO: configs
        -- config = function() require'plugins.abolish' end,
    }

    use {
        'Yggdroot/indentLine',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
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
    }

    use {
        'sindrets/diffview.nvim',
        event = 'CmdlineEnter',
        cmd = { 'DiffviewToggle', 'DiffviewFileHistory' },
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.diffview'

            local set_autocmd = require('neovim.autocmds').set_autocmd

            set_autocmd {
                event = 'Filetype',
                pattern = 'Diff{viewFiles,FileHistory}',
                cmd = 'lua require"plugins.diffview".set_mappings()',
                group = 'DiffViewMappings',
            }

            set_autocmd {
                event = 'TabEnter',
                pattern = '*',
                cmd = 'lua require"plugins.diffview".set_mappings()',
                group = 'DiffViewMappings',
            }
        end,
    }

    use {
        'rhysd/git-messenger.vim',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        setup = function()
            vim.g.git_messenger_no_default_mappings = 1
        end,
        config = function()
            vim.api.nvim_set_keymap('n', '=m', '<Plug>(git-messenger)', { silent = true, nowait = true })
        end,
    }

    use {
        'lewis6991/gitsigns.nvim',
        event = { 'CursorHold', 'CursorHoldI' },
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        wants = 'plenary.nvim',
        config = function()
            require('gitsigns').setup {
                keymaps = {
                    -- Default keymap options
                    noremap = true,
                    buffer = true,

                    ['n ]c'] = {
                        expr = true,
                        "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'",
                    },
                    ['n [c'] = {
                        expr = true,
                        "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'",
                    },

                    ['n =s'] = '<cmd>lua require"gitsigns".stage_hunk()<CR>',
                    ['v =s'] = '<cmd>lua require"gitsigns".stage_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n =S'] = '<cmd>lua require"gitsigns".undo_stage_hunk()<CR>',
                    ['n =u'] = '<cmd>lua require"gitsigns".reset_hunk()<CR>',
                    ['v =u'] = '<cmd>lua require"gitsigns".reset_hunk({vim.fn.line("."), vim.fn.line("v")})<CR>',
                    ['n =U'] = '<cmd>lua require"gitsigns".reset_buffer()<CR>',
                    ['n =f'] = '<cmd>lua require"gitsigns".preview_hunk()<CR>',
                    ['n =M'] = '<cmd>lua require"gitsigns".blame_line({full = false, ignore_whitespace = true})<CR>',

                    -- Text objects
                    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['o ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                },
                -- current_line_blame = true,
                -- current_line_blame_opts = {
                --     virt_text = true,
                --     virt_text_pos = 'eol', -- 'eol' | 'overlay' | 'right_align'
                --     delay = 1000,
                --     ignore_whitespace = false,
                -- },
                -- current_line_blame_formatter_opts = {
                --     relative_time = false,
                -- },
            }
        end,
    }

    use {
        'sainnhe/sonokai',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            vim.opt.termguicolors = true

            -- vim.g.sonokai_current_word = 'bold'
            vim.g.sonokai_enable_italic = 1
            vim.g.sonokai_diagnostic_text_highlight = 1
            vim.g.sonokai_diagnostic_line_highlight = 1
            vim.g.sonokai_diagnostic_virtual_text = 'colored'
            vim.g.sonokai_better_performance = 1

            vim.g.airline_theme = 'sonokai'

            vim.cmd [[colorscheme sonokai]]
        end,
    }

    use {
        'glacambre/firenvim',
        cond = function()
            local ssh = vim.env.SSH_CONNECTION or false
            local min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
            local firenvim = vim.g.started_by_firenvim ~= nil
            return (not min and not ssh) or firenvim
        end,
        config = function()
            if vim.g.started_by_firenvim ~= nil then
                vim.api.nvim_set_keymap(
                    'n',
                    '<C-z>',
                    '<cmd>call firenvim#hide_frame()<CR>',
                    { noremap = true }
                )
            end
        end,
        run = function()
            vim.fn['firenvim#install'](0)
        end,
    }

    use {
        'phaazon/hop.nvim',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.hop'
        end,
    }

    -- use {
    --     'folke/trouble.nvim',
    --     event = { 'CmdlineEnter', 'CursorHold' },
    --     cmd = { 'Trouble' },
    --     cond = function()
    --         return not vim.env.VIM_MIN and not vim.g.minimal
    --     end,
    --     config = function()
    --         require 'plugins.trouble'
    --     end,
    -- }

    use {
        'vim-airline/vim-airline',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.airline'
        end,
        requires = {
            {
                'vim-airline/vim-airline-themes',
                cond = function()
                    return not vim.env.VIM_MIN and not vim.g.minimal
                end,
            },
        },
        -- after = 'firenvim',
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require 'plugins.treesitter'
        end,
        cond = function()
            local compiler
            if vim.fn.has 'win32' == 1 or vim.fn.has 'win64' == 1 then
                compiler = vim.fn.executable 'gcc' == 1
            else
                compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
            end
            return compiler
        end,
        requires = {
            { 'nvim-treesitter/playground' },
            { 'nvim-treesitter/nvim-treesitter-refactor' },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'Badhi/nvim-treesitter-cpp-tools' },
        },
    }

    use {
        'nvim-telescope/telescope.nvim',
        config = function()
            require 'plugins.telescope'
        end,
        wants = {
            'plenary.nvim',
            'popup.nvim',
        },
        tag = (vim.fn.has 'nvim-0.6' == 0 and 'nvim-0.5.0' or nil),
    }

    use {
        'nvim-telescope/telescope-smart-history.nvim',
        cond = function()
            return require('sys').has_sqlite
        end,
        module = 'telescope',
        config = function()
            require('telescope').load_extension 'smart_history'
        end,
        wants = { 'sqlite.lua', 'telescope.nvim' },
    }

    use {
        'nvim-telescope/telescope-frecency.nvim',
        cond = function()
            return require('sys').has_sqlite
        end,
        module = 'telescope',
        config = function()
            require('telescope').load_extension 'frecency'
        end,
        wants = { 'sqlite.lua', 'telescope.nvim' },
    }

    use { 'folke/lsp-colors.nvim' }
    use {
        'neovim/nvim-lspconfig',
        config = function()
            require 'plugins.lsp'
        end,
        after = 'telescope.nvim',
        requires = {
            { 'weilbith/nvim-lsp-smag' },
            { 'weilbith/nvim-floating-tag-preview' },
        },
    }

    use {
        'norcalli/nvim-terminal.lua',
        config = function()
            require('terminal').setup()
        end,
    }

    use {
        'L3MON4D3/LuaSnip',
        config = function()
            require 'plugins.snippets'
        end,
    }

    use {
        'hrsh7th/nvim-cmp',
        requires = {
            { 'hrsh7th/cmp-nvim-lsp' },
            { 'hrsh7th/cmp-buffer' },
            { 'hrsh7th/cmp-path' },
            { 'hrsh7th/cmp-nvim-lua' },
            { 'hrsh7th/cmp-nvim-lsp-signature-help' },
            { 'onsails/lspkind-nvim' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'ray-x/cmp-treesitter' },
            -- { 'quangnguyen30192/cmp-nvim-ultisnips' },
        },
        config = function()
            require 'plugins.completion'
        end,
        -- after = 'nvim-lspconfig',
    }

    use {
        'AckslD/nvim-neoclip.lua',
        config = function()
            local db_path
            local has_sqlite = require('sys').has_sqlite
            if has_sqlite then
                db_path = require('sys').db_root .. '/neoclip.sqlite3'
            end
            require('neoclip').setup {
                enable_persistent_history = has_sqlite,
                db_path = db_path,
                keys = {
                    telescope = {
                        i = {
                            select = '<CR>',
                            paste = '<A-p>',
                            paste_behind = '<A-P>',
                        },
                        n = {
                            select = '<CR>',
                            paste = 'p',
                            paste_behind = 'P',
                        },
                    },
                },
            }
            -- Since we need to load after telescope, it should be safe to call this here
            require('telescope').load_extension 'neoclip'
        end,
        cond = function()
            -- Windows throws an error complaining it has an invalid syntax, I look in to it later
            return vim.fn.has 'win32' == 0
        end,
        wants = { 'telescope.nvim', (require('sys').has_sqlite and 'sqlite.lua' or nil) },
    }

    use {
        'numToStr/Comment.nvim',
        config = function()
            require 'plugins.comments'
        end,
    }

    use {
        'danymat/neogen',
        config = function()
            require('neogen').setup {
                enabled = true,
                input_after_comment = true,
                languages = {
                    lua = {
                        template = {
                            annotation_convention = 'emmylua',
                        },
                    },
                    python = {
                        template = {
                            annotation_convention = 'google_docstrings',
                        },
                    },
                },
            }
        end,
        -- requires = { { 'nvim-treesitter/nvim-treesitter' } },
        wants = { 'nvim-treesitter' },
        after = 'nvim-treesitter',
    }

    use {
        'vimwiki/vimwiki',
        setup = function()
            vim.g.vimwiki_list = {
                { path = '~/notes/' },
                { path = '~/work/' },
            }
            vim.g.vimwiki_hl_headers = 1
            vim.g.vimwiki_hl_cb_checked = 2
            vim.g.vimwiki_listsyms = ' ○◐●✓'
            vim.g.vimwiki_listsym_rejected = '✗'
        end,
        -- config = function()
        --     require 'plugins.vimwiki'
        -- end,
    }

    -- TODO: Add neovim 0.5 compatibility layer/setup
    use {
        'jose-elias-alvarez/null-ls.nvim',
        wants = { 'nvim-lspconfig', 'plenary.nvim' },
        branch = (vim.fn.has 'nvim-0.6' == 0 and '0.5.1-compat' or nil),
    }

    use {
        'echasnovski/mini.nvim',
        config = function()
            require 'plugins.mini'
        end,
    }

    use {
        'ThePrimeagen/harpoon',
        config = function()
            vim.keymap.set('n', '=h', function()
                require('harpoon.ui').toggle_quick_menu()
            end, { noremap = true })

            vim.keymap.set('n', '=a', function()
                require('harpoon.mark').add_file()
            end, { noremap = true })

            vim.keymap.set('n', ']h', function()
                require('harpoon.ui').nav_next()
            end, { noremap = true })

            vim.keymap.set('n', '[h', function()
                require('harpoon.ui').nav_prev()
            end, { noremap = true })
        end,
    }

    use {
        'ray-x/go.nvim',
        cond = function()
            return vim.fn.executable 'go'
        end,
        config = function()
            local gofmt = 'gofmt'
            local goimport = 'goimport'
            if vim.fn.executable 'gopls' == 1 then
                gofmt = 'gopls'
                goimport = 'gopls'
            end

            require('go').setup {
                gofmt = gofmt,
                goimport = goimport,
                max_line_len = 120,
                tag_transform = false,
                test_dir = '',
                comment_placeholder = '   ',
                textobjects = false, -- enable default text jobects through treesittter-text-objects
                lsp_cfg = false, -- false: use your own lspconfig
                lsp_gofumpt = false, -- true: set default gofmt in gopls format to gofumpt
                lsp_on_attach = false, -- use on_attach from go.nvim
                dap_debug = true,
            }
        end,
    }

    use {
        'mfussenegger/nvim-dap',
        -- event = { 'CursorHold', 'CmdlineEnter' },
        -- cmd = { 'DapStart', 'DapContinue' },
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            require 'plugins.dap'
        end,
    }

    use {
        'theHamsta/nvim-dap-virtual-text',
        config = function()
            require('nvim-dap-virtual-text').setup {}
        end,
        wants = 'nvim-dap',
        after = 'nvim-dap',
    }

    use {
        'rcarriga/nvim-dap-ui',
        cond = function()
            return not vim.env.VIM_MIN and not vim.g.minimal
        end,
        config = function()
            local dapui = require 'dapui'
            dapui.setup {}

            local set_command = require('neovim.commands').set_command
            set_command {
                lhs = 'DapUI',
                rhs = require('dapui').toggle,
                args = { force = true },
            }
            vim.keymap.set('n', '=I', require('dapui').toggle, { noremap = true, silent = true })

            local dap = require 'dap'
            dap.listeners.after.event_initialized['dapui_config'] = function()
                dapui.open()
            end
            dap.listeners.before.event_terminated['dapui_config'] = function()
                dapui.close()
            end
            dap.listeners.before.event_exited['dapui_config'] = function()
                dapui.close()
            end
        end,
        wants = 'nvim-dap',
        after = 'nvim-dap',
    }
end)

if has_compiler then
    local rocks = require 'packer.luarocks'
    rocks.install_commands()
end

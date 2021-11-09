local ok, packer = pcall(require, 'packer')
local has_compiler = vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
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
    if vim.fn.has 'win32' == 0 and has_compiler then
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
            local os = jit.os:lower()
            if os == 'windows' then
                -- TODO: search for dll
                return false
            end
            return vim.fn.executable 'sqlite3' == 1
        end,
    }

    use {
        'lervag/vimtex',
        cond = function()
            return vim.fn.executable 'latexmk' == 1 and vim.env.VIM_MIN == nil and vim.g.minimal == nil
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
        event = 'CmdlineEnter',
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
                ['stylua.toml']                = { type = 'Stylua' },
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

    -- use {
    --     'TimUntersberger/neogit',
    --     config = function()
    --         require 'plugins.neogit'
    --     end,
    --     wants = { 'plenary.nvim', 'diffview.nvim' },
    -- }

    use { 'tpope/vim-fugitive', event = { 'CmdlineEnter', 'CursorHold' } }
    use { 'junegunn/gv.vim', cmd = 'GV', wants = 'vim-fugitive' }

    use {
        'sindrets/diffview.nvim',
        event = 'CmdlineEnter',
        cmd = { 'DiffviewToggle', 'DiffviewFileHistory' },
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
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
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        setup = function()
            vim.g.git_messenger_no_default_mappings = 1
        end,
        config = function()
            vim.api.nvim_set_keymap('n', '=m', '<Plug>(git-messenger)', { silent = true, nowait = true })
        end,
    }

    -- use {'rhysd/committia.vim'}

    use {
        'lewis6991/gitsigns.nvim',
        event = { 'CursorHold', 'CursorHoldI' },
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
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
                    ['n =M'] = '<cmd>lua require"gitsigns".blame_line(true)<CR>',

                    -- Text objects
                    ['o ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ih'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['o ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                    ['x ah'] = ':<C-U>lua require"gitsigns.actions".select_hunk()<CR>',
                },
                -- current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol',
                    delay = 1000,
                },
                -- numhl = false,
                -- linehl = false,
                -- status_formatter = nil, -- Use default
                -- word_diff = false,
            }
        end,
    }

    use {
        'sainnhe/sonokai',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
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
        'tommcdo/vim-lion',
        event = 'VimEnter',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        config = function()
            vim.g.lion_squeeze_spaces = 1
        end,
    }

    use {
        'tpope/vim-abolish',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        event = { 'InsertEnter', 'CmdwinEnter' },
        -- TODO: configs
        -- config = function() require'plugins.abolish' end,
    }

    use {
        'tpope/vim-markdown',
        ft = 'markdown',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
    }

    use {
        'Yggdroot/indentLine',
        event = { 'VimEnter' },
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
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

    -- use {
    --     'ludovicchabant/vim-gutentags',
    --     cond = function()
    --         local executable = function(exe) return vim.fn.executable(exe) == 1 end
    --         local min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
    --         local is_firenvim = vim.g.started_by_firenvim
    --         return not min and not is_firenvim and (executable('ctags') or executable('cscope'))
    --     end,
    --     config = function() require'plugins.gutentags' end,
    -- }

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
        'phaazon/hop.nvim',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        config = function()
            require 'plugins.hop'
        end,
    }

    use {
        'folke/trouble.nvim',
        event = { 'CmdlineEnter', 'CursorHold' },
        cmd = { 'Trouble' },
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        config = function()
            require 'plugins.trouble'
        end,
    }

    -- use {
    --     'folke/todo-comments.nvim',
    --     cond = function()
    --         local no_min = vim.env.VIM_MIN == nil and vim.g.minimal == nil
    --         local has_rg = vim.fn.executable 'rg' == 1
    --         return no_min and has_rg
    --     end,
    --     config = function()
    --         require 'plugins.todos'
    --     end,
    --     wants = 'trouble.nvim',
    -- }

    use {
        'vim-airline/vim-airline',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        config = function()
            require 'plugins.airline'
        end,
        requires = {
            {
                'vim-airline/vim-airline-themes',
                cond = function()
                    return vim.env.VIM_MIN == nil and vim.g.minimal == nil
                end,
            },
        },
        after = 'firenvim',
    }

    -- use {
    --     'vimwiki/vimwiki',
    --     setup = function()
    --         local general_wiki = {
    --             auto_tags = 1,
    --             syntax = 'markdown',
    --             ext = '.md',
    --             nested_syntaxes = {
    --                 python  = 'python',
    --                 lua     = 'lua',
    --                 ['c++'] = 'cpp',
    --                 sh      = 'sh',
    --                 bash    = 'sh' ,
    --             },
    --
    --         }
    --
    --         local personal_wiki = { path = '~/notes/', }
    --         local work_wiki = { path = '~/vimwiki/', }
    --
    --         vim.g.vimwiki_table_mappings = 0
    --         vim.g.vimwiki_list = {
    --             vim.tbl_extend('force', personal_wiki, general_wiki),
    --             vim.tbl_extend('force', work_wiki, general_wiki),
    --         }
    --         vim.g.vimwiki_ext2syntax = {
    --             ['.md']   = 'markdown',
    --             ['.mkd']  = 'markdown',
    --             ['.wiki'] = 'media'
    --         }
    --     end,
    --     -- config = function()
    --     --     vim.cmd [[nmap gww <Plug>VimwikiIndex]]
    --     --     vim.cmd [[nmap gwt <Plug>VimwikiTabIndex]]
    --     --     vim.cmd [[nmap gwd <Plug>VimwikiDiaryIndex]]
    --     --     vim.cmd [[nmap gwn <Plug>VimwikiMakeDiaryNote]]
    --     --     vim.cmd [[nmap gwu <Plug>VimwikiUISelect]]
    --     -- end,
    -- }

    use {
        'neomake/neomake',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has 'python3' == 1
        end,
        setup = function()
            local get_icon = require('utils.helpers').get_icon

            local lsp_sign = vim.fn.has 'nvim-0.6' == 1 and 'DiagnosticSign' or 'LspDiagnosticsSign'
            local names = { 'error', 'hint', 'warn', 'info' }
            local levels = { 'Error', 'Hint' }
            if vim.fn.has 'nvim-0.6' == 1 then
                vim.list_extend(levels, { 'Warn', 'Info' })
            else
                vim.list_extend(levels, { 'Warning', 'Information' })
            end

            local hl_group = {}
            for idx, level in ipairs(levels) do
                hl_group[names[idx]] = lsp_sign .. level
            end

            vim.g.neomake_error_sign = {
                text = get_icon 'error',
                texthl = hl_group['error'],
            }
            vim.g.neomake_warning_sign = {
                text = get_icon 'warn',
                texthl = hl_group['warn'],
            }
            vim.g.neomake_info_sign = {
                text = get_icon 'info',
                texthl = hl_group['info'],
            }
            vim.g.neomake_message_sign = {
                text = get_icon 'hint',
                texthl = hl_group['hint'],
            }

            -- Don't show the location list, silently run Neomake
            vim.g.neomake_open_list = 0

            vim.g.neomake_echo_current_error = 0
            vim.g.neomake_virtualtext_current_error = 1
            vim.g.neomake_virtualtext_prefix = get_icon 'virtual_text' .. ' '

            -- vim.g.neomake_ft_maker_remove_invalid_entries = 1
        end,
        config = function()
            vim.fn['neomake#configure#automake']('nrw', 200)
        end,
        event = 'VimEnter',
    }

    -- use {
    --     'SirVer/ultisnips',
    --     cond = function()
    --         return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has 'python3' == 1
    --     end,
    --     event = 'VimEnter',
    --     setup = function()
    --         vim.g.UltiSnipsEditSplit = 'context'
    --         vim.g.UltiSnipsExpandTrigger = '<C-,>'
    --
    --         -- Remove all select mappigns in expanded snip
    --         -- vim.g.UltiSnipsRemoveSelectModeMappings = 0
    --         vim.g.UltiSnipsUsePythonVersion = 3
    --
    --         vim.g.ulti_expand_or_jump_res = 0
    --         vim.g.ulti_jump_backwards_res = 0
    --         vim.g.ulti_jump_forwards_res = 0
    --         vim.g.ulti_expand_res = 0
    --
    --         vim.g.ultisnips_python_quoting_style = 'single'
    --         vim.g.ultisnips_python_triple_quoting_style = 'double'
    --         vim.g.ultisnips_python_style = 'google'
    --
    --         -- vim.g.UltiSnipsSnippetDirectories = {}
    --
    --         vim.api.nvim_set_keymap(
    --             'x',
    --             '<CR>',
    --             ':call UltiSnips#SaveLastVisualSelection()<CR>gv"_s',
    --             { silent = true }
    --         )
    --     end,
    --     requires = {
    --         {
    --             'honza/vim-snippets',
    --             cond = function()
    --                 return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has 'python3' == 1
    --             end,
    --         },
    --     },
    -- }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function()
            require 'plugins.treesitter'
        end,
        cond = function()
            return vim.fn.executable 'gcc' == 1 or vim.fn.executable 'clang' == 1
        end,
        requires = {
            { 'nvim-treesitter/playground' },
            { 'nvim-treesitter/nvim-treesitter-refactor' },
            { 'nvim-treesitter/nvim-treesitter-textobjects' },
            { 'David-Kunz/treesitter-unit' },
        },
    }

    use {
        'mfussenegger/nvim-dap',
        event = { 'CursorHold', 'CmdlineEnter' },
        cmd = { 'DapStart', 'DapContinue' },
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        config = function()
            require 'plugins.dap'
        end,
        requires = {
            {
                'theHamsta/nvim-dap-virtual-text',
                cond = function()
                    return vim.env.VIM_MIN == nil and vim.g.minimal == nil
                end,
                config = function()
                    require('nvim-dap-virtual-text').setup()
                end,
            },
        },
    }

    -- use {
    --     'rcarriga/nvim-dap-ui',
    --     cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    --     config = function()
    --         require'dapui'.setup{}
    --         local set_command = require'neovim.commands'.set_command
    --         local set_mapping = require'neovim.mappings'.set_mapping
    --         -- require("dapui").open()
    --         -- require("dapui").close()
    --         -- require("dapui").toggle()
    --         set_command{
    --             lhs = 'DapUI',
    --             rhs = require("dapui").toggle,
    --             args = { force = true, }
    --         }
    --         set_mapping{
    --             mode = 'n',
    --             lhs = '=I',
    --             rhs = require("dapui").toggle,
    --             args = {noremap = true, silent = true},
    --         }
    --     end,
    --     wants = 'nvim-dap'
    -- }

    -- use {
    --     'nvim-telescope/telescope-smart-history.nvim',
    --     cond = function()
    --         local os = jit.os:lower()
    --         if os == 'windows' then
    --             -- TODO: search for dll
    --             return false
    --         end
    --         return vim.fn.executable 'sqlite3' == 1
    --     end,
    --     module = 'telescope',
    --     config = function()
    --         require('telescope').load_extension 'smart_history'
    --     end,
    --     wants = { 'sqlite.lua' },
    -- }

    -- use {
    --     'nvim-telescope/telescope-frecency.nvim',
    --     cond = function()
    --         local os = jit.os:lower()
    --         if os == 'windows' then
    --             -- TODO: search for dll
    --             return false
    --         end
    --         return vim.fn.executable 'sqlite3' == 1
    --     end,
    --     module = 'telescope',
    --     config = function()
    --         require('telescope').load_extension 'frecency'
    --     end,
    --     wants = { 'sqlite.lua' },
    -- }

    use {
        'nvim-telescope/telescope.nvim',
        config = function()
            require 'plugins.telescope'
        end,
        wants = {
            'plenary.nvim',
            'popup.nvim',
        },
    }

    -- local lsp_navigator = {'glepnir/lspsaga.nvim'}
    -- if has_compiler and has_make then
    --     lsp_navigator = {
    --         'ray-x/navigator.lua',
    --         requires = {'ray-x/guihua.lua', run = 'cd lua/fzy && make'},
    --         config = function()
    --         end,
    --     }
    -- end

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
            { 'onsails/lspkind-nvim' },
            { 'saadparwaiz1/cmp_luasnip' },
            { 'quangnguyen30192/cmp-nvim-ultisnips' },
        },
        config = function()
            require 'plugins.completion'
        end,
        -- after = 'nvim-lspconfig',
    }

    -- -- TODO: Check for python 3.8.5
    -- use {
    --     'ms-jpq/coq_nvim',
    --     branch = 'coq',
    --     cond = function()
    --         return vim.fn.has 'python3' == 1
    --     end,
    --     setup = function()
    --         vim.g.coq_settings = {
    --             auto_start = true,
    --             ['keymap.recommended'] = false,
    --         }
    --     end,
    --     -- config = function()
    --     --     vim.cmd('COQdeps')
    --     -- end,
    -- }

    -- use {
    --     'lewis6991/spellsitter.nvim',
    --     config = function()
    --         require('spellsitter').setup{
    --             hl = 'Error',
    --             captures = {'comment', 'string'},
    --         }
    --     end,
    --     after = 'nvim-treesitter',
    -- }

    -- use {
    --     'segeljakt/vim-silicon',
    --     cond = function() return vim.fn.executable('silicon') == 1 end,
    --     setup = function()
    --         vim.g.silicon = {
    --             theme                  = 'Dracula',
    --             font                   = 'Hack',
    --             background             = '#000000',
    --             ['shadow-color']       = '#555555',
    --             ['line-pad']           = 2,
    --             ['pad-horiz']          = 80,
    --             ['pad-vert']           = 100,
    --             ['shadow-blur-radius'] = 0,
    --             ['shadow-offset-x']    = 0,
    --             ['shadow-offset-y']    = 0,
    --             ['line-number']        = true,
    --             ['round-corner']       = true,
    --             ['window-controls']    = true,
    --         }
    --     end,
    -- }
end)

if has_compiler then
    local rocks = require 'packer.luarocks'
    rocks.install_commands()
end

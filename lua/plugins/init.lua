local ok,packer = pcall(require, 'packer')

if not ok then
    return false
end

packer.init{
    -- log = {level = 'debug'},
    luarocks = { python_cmd = 'python3' },
    profile = {
        enable = false,
        threshold = 1 -- the amount in ms that a plugins load time must be over for it to be included in the profile
    },
    display = {
        open_fn = require('packer.util').float,
    },
    git = {
        clone_timeout = 90, -- Timeout, in seconds, for git clones
    }
}

packer.startup(function()

    -- BUG: Seems like luarocks is not supported in windows
    if vim.fn.has('win32') == 0 and
      (vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1) then
        use_rocks { 'luacheck','lua-cjson' }
    end

    use 'wbthomason/packer.nvim'

    use {'PProvost/vim-ps1'}
    use {'kurayama/systemd-vim-syntax'}
    use {'raimon49/requirements.txt.vim'}

    use {'nanotee/luv-vimdocs', event = 'CmdlineEnter' }
    use {'tweekmonster/startuptime.vim', cmd = {'StartupTime'} }

    use {'kyazdani42/nvim-web-devicons'}
    use {'kevinhwang91/nvim-bqf'}

    use {'nvim-lua/popup.nvim'}
    use {'nvim-lua/plenary.nvim'}

    use {
        'rcarriga/nvim-notify',
        config = function()
            local has_notify, notify = pcall(require, 'notify')
            vim.notify = has_notify and notify or vim.notify
        end,
    }

    use {
        'lervag/vimtex',
        cond = function()
            return vim.fn.executable('latexmk') == 1 and vim.env.VIM_MIN == nil and vim.g.minimal == nil
        end,
        setup = function() require'plugins.vimtex' end,
        ft = {'bib', 'tex', 'latex', 'bibtex'},
    }

    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            vim.opt.termguicolors = true
            require'colorizer'.setup()
        end,
        event = {'CursorHold', 'CursorMoved', 'InsertEnter'},
    }

    use {'tpope/vim-repeat', event = 'VimEnter'}
    use {'tpope/vim-apathy', event = 'VimEnter'}
    -- use {'tpope/vim-commentary', event = 'VimEnter'}

    use {
        'ojroques/vim-oscyank',
        event = 'VimEnter',
        config = function() require'plugins.oscyank' end,
    }

    use {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function() require'plugins.pairs' end,
    }

    use {
        'tpope/vim-surround',
        event = 'VimEnter',
        config = function()
            vim.g['surround_'..vim.fn.char2nr("¿")] = '¿\r?'
            vim.g['surround_'..vim.fn.char2nr("?")] = '¿\r?'
            vim.g['surround_'..vim.fn.char2nr("¡")] = '¡\r!'
            vim.g['surround_'..vim.fn.char2nr("!")] = '¡\r!'
            vim.g['surround_'..vim.fn.char2nr(";")] = ':\r:'
            vim.g['surround_'..vim.fn.char2nr(":")] = ':\r:'
            vim.g['surround_'..vim.fn.char2nr('q')] = [[``\r'']]
        end,
    }

    use {
        'tpope/vim-projectionist',
        config = function()
            local set_autocmd = require'neovim.autocmds'.set_autocmd
            -- TODO: Make this more "project" tailored, set git and language specific
            --       projections depending of what's in the cwd
            vim.g.common_projections = {
                ['.projections.json']          = {type = 'Projections'},
                ['.gitignore']                 = {type = 'Gitignore'},
                ['.git/hooks/*']               = {type = 'GitHooks'},
                ['.git/config']                = {type = 'Git'},
                ['.git/info/*']                = {type = 'Git'},
                ['.github/workflows/main.yml'] = {type = 'Github'},
                ['.github/workflows/*.yml']    = {type = 'Github'},
                ['.travis.yml']                = {type = 'Travis' },
                ['.pre-commit-config.yaml']    = {type = 'PreCommit'},
                ['.ycm_extra_conf.py']         = {type = 'YCM'},
                ['.project.vim']               = {type = 'Project'},
                ['.clang-format']              = {type = 'Clang'},
                ['.clang-*']                   = {type = 'Clang'},
                ['compile_flags.txt']          = {type = 'CompileFlags'},
                ['compile_commands.json']      = {type = 'CompileDB'},
                ['UltiSnips/*.snippets']       = {type = 'UltiSnips'},
                ['README.md']                  = {type = 'Readme'},
                ['LICENSE']                    = {type = 'License'},
                ['Makefile']                   = {type = 'Makefile'},
                ['CMakeLists.txt']             = {type = 'CMake'},
                ['*.cmake']                    = {type = 'CMake'},
            }
            set_autocmd{
                event   = 'User',
                pattern = 'ProjectionistDetect',
                cmd     = 'call projectionist#append(getcwd(), g:common_projections)',
                group   = 'CommonProjections',
            }
        end,
    }

    use {'tpope/vim-fugitive',}
    use {'junegunn/gv.vim', cmd = 'GV', wants = 'vim-fugitive'}

    use {
        'sindrets/diffview.nvim',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function()
            require'plugins.diffview'

            local set_autocmd = require'neovim.autocmds'.set_autocmd

            set_autocmd{
                event   = 'Filetype',
                pattern = 'Diff{viewFiles,FileHistory}',
                cmd     = 'lua require"plugins.diffview".set_mappings()',
                group   = 'DiffViewMappings',
            }

            set_autocmd{
                event   = 'TabEnter',
                pattern = '*',
                cmd     = 'lua require"plugins.diffview".set_mappings()',
                group   = 'DiffViewMappings',
            }
        end,
    }

    use {
        'rhysd/git-messenger.vim',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        setup = function() vim.g.git_messenger_no_default_mappings = 1 end,
        config = function()
            vim.api.nvim_set_keymap(
                'n',
                '=m',
                '<Plug>(git-messenger)',
                {silent = true, nowait = true}
            )
        end,
    }

    -- use {'rhysd/committia.vim'}

    use {
        'lewis6991/gitsigns.nvim',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        wants = 'plenary.nvim',
        config = function()
            require('gitsigns').setup {
                keymaps = {
                    -- Default keymap options
                    noremap = true,
                    buffer = true,

                    ['n ]c'] = { expr = true, "&diff ? ']c' : '<cmd>lua require\"gitsigns.actions\".next_hunk()<CR>'"},
                    ['n [c'] = { expr = true, "&diff ? '[c' : '<cmd>lua require\"gitsigns.actions\".prev_hunk()<CR>'"},

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
                current_line_blame = true,
                current_line_blame_opts = {
                    virt_text = true,
                    virt_text_pos = 'eol',
                    delay = 1000
                },
                -- numhl = false,
                -- linehl = false,
                -- status_formatter = nil, -- Use default
                -- word_diff = false,
            }
        end
    }

    use {
        'sainnhe/sonokai',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function()
            vim.opt.termguicolors = true

            -- vim.g.sonokai_current_word = 'bold'
            vim.g.sonokai_enable_italic = 1
            vim.g.sonokai_diagnostic_text_highlight = 1
            vim.g.sonokai_diagnostic_line_highlight = 1
            vim.g.sonokai_diagnostic_virtual_text = 'colored'
            vim.g.sonokai_better_performance = 1

            vim.g.airline_theme = 'sonokai'

            vim.cmd[[colorscheme sonokai]]
        end,
    }

    use {
        'tommcdo/vim-lion',
        event = 'VimEnter',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() vim.g.lion_squeeze_spaces = 1 end,
    }

    use {
        'tpope/vim-abolish',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        event = {'InsertEnter', 'CmdwinEnter'},
        -- TODO: configs
        -- config = function() require'plugins.abolish' end,
    }

    use {
        'tpope/vim-markdown',
        ft = 'markdown',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    }

    use {
        'Yggdroot/indentLine',
        event = 'VimEnter',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        setup = function()
            vim.g.indentLine_fileTypeExclude = {
                'Telescope',
                'TelescopePrompt',
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
                    {noremap = true}
                )
            end
        end,
        run = function() vim.fn['firenvim#install'](0) end,
    }

    use {
        'ludovicchabant/vim-gutentags',
        cond = function()
            local executable = function(exe) return vim.fn.executable(exe) == 1 end
            local min = vim.env.VIM_MIN ~= nil or vim.g.minimal ~= nil
            local is_firenvim = vim.g.started_by_firenvim
            return not min and not is_firenvim and (executable('ctags') or executable('cscope'))
        end,
        config = function() require'plugins.gutentags' end,
    }


    use {
        'kana/vim-textobj-user',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        event = 'VimEnter',
        requires = {
            {
                'kana/vim-textobj-line',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
                event = 'VimEnter',
            },
            {
                'kana/vim-textobj-entire',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
                event = 'VimEnter',
            },
            {
                'michaeljsmith/vim-indent-object',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
                event = 'VimEnter',
            },
            {
                'glts/vim-textobj-comment',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
                event = 'VimEnter',
            },
        }
    }

    use {
        'phaazon/hop.nvim',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.hop' end,
    }

    use {
        'folke/trouble.nvim',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.trouble' end,
    }

    use {
        'folke/todo-comments.nvim',
        cond = function()
            local no_min = vim.env.VIM_MIN == nil and vim.g.minimal == nil
            local has_rg = vim.fn.executable('rg') == 1
            return no_min and has_rg
        end,
        config = function() require'plugins.todos' end,
        wants = 'trouble.nvim',
    }

    use {
        'vim-airline/vim-airline',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.airline' end,
        requires = {
            {
                'vim-airline/vim-airline-themes',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
            }
        },
        after = 'firenvim',
    }

    -- use{
    --     "vhyrro/neorg",
    --     config = function()
    --         require('neorg').setup {
    --             -- Tell Neorg what modules to load
    --             load = {
    --                 ["core.defaults"] = {}, -- Load all the default modules
    --                 ["core.keybinds"] = { -- Configure core.keybinds
    --                     config = {
    --                         default_keybinds = true, -- Generate the default keybinds
    --                         neorg_leader = "<Leader>o" -- This is the default if unspecified
    --                     }
    --                 },
    --                 ["core.norg.concealer"] = {}, -- Allows for use of icons
    --                 ["core.norg.dirman"] = { -- Manage your directories with Neorg
    --                     config = {
    --                         workspaces = {
    --                             my_workspace = "~/neorg"
    --                         }
    --                     }
    --                 }
    --             },
    --         }
    --     end,
    --     wants = 'plenary.nvim'
    -- }

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
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has('python3') == 1
        end,
        event = 'VimEnter',
    }

    use {
        'SirVer/ultisnips',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has('python3') == 1
        end,
        event = 'VimEnter',
        setup = function()
            vim.g.UltiSnipsEditSplit     = 'context'
            vim.g.UltiSnipsExpandTrigger = '<C-,>'

            -- Remove all select mappigns in expanded snip
            -- vim.g.UltiSnipsRemoveSelectModeMappings = 0
            vim.g.UltiSnipsUsePythonVersion = 3

            vim.g.ulti_expand_or_jump_res = 0
            vim.g.ulti_jump_backwards_res = 0
            vim.g.ulti_jump_forwards_res  = 0
            vim.g.ulti_expand_res         = 0

            vim.g.ultisnips_python_quoting_style = 'single'
            vim.g.ultisnips_python_triple_quoting_style = 'double'
            vim.g.ultisnips_python_style = 'google'

            -- vim.g.UltiSnipsSnippetDirectories = {}

            vim.api.nvim_set_keymap(
                'x',
                '<CR>',
                ':call UltiSnips#SaveLastVisualSelection()<CR>gv"_s',
                {silent = true}
            )
        end,
        requires = {
            {
                'honza/vim-snippets',
                cond = function()
                    return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has('python3') == 1
                end,
            },
        },
    }

    use {
        'hrsh7th/nvim-compe',
        config = function() require'plugins.completion' end,
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        event = 'VimEnter', -- NOTE: Nees to defer this as much as possible because it needs info from other plugins
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function() require'plugins.treesitter' end,
        cond = function()
            return vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1
        end,
        requires = {
            {'nvim-treesitter/playground'},
            {'nvim-treesitter/nvim-treesitter-refactor'},
            {'nvim-treesitter/nvim-treesitter-textobjects'},
        }
    }

    use {
        'mfussenegger/nvim-dap',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.dap' end,
        requires = {
            {
                'theHamsta/nvim-dap-virtual-text',
                cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
                setup = function() vim.g.dap_virtual_text = true end,
            },
        }
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


    use {
        'nvim-telescope/telescope.nvim',
        config = function() require'plugins.telescope' end,
        wants = {
            'plenary.nvim',
            'popup.nvim'
        },
    }

    use {'folke/lsp-colors.nvim'}
    use {'weilbith/nvim-lsp-smag'}
    use {'weilbith/nvim-floating-tag-preview'}

    use {
        'neovim/nvim-lspconfig',
        config = function() require'plugins.lsp' end,
        after = 'telescope.nvim',
        requires = {
            {'glepnir/lspsaga.nvim'},
        },
    }

    use {
        'norcalli/nvim-terminal.lua',
        config = function() require'terminal'.setup() end,
    }

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

if vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1 then
    local rocks = require'packer.luarocks'
    rocks.install_commands()
end

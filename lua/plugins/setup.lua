local packer = require'packer'

packer.init{
    luarocks = {
        python_cmd = 'python3'
    },
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
    use_rocks {'luacheck',  'lua-cjson'}

    use 'wbthomason/packer.nvim'
    use {'PProvost/vim-ps1'}
    use {'kurayama/systemd-vim-syntax'}
    use {'raimon49/requirements.txt.vim'}

    use {'nanotee/luv-vimdocs', event = 'CmdlineEnter' }
    use {'tweekmonster/startuptime.vim', cmd = {'StartupTime'} }

    use {'kyazdani42/nvim-web-devicons'}
    use {'kevinhwang91/nvim-bqf'}

    use {
        'norcalli/nvim-colorizer.lua',
        config = function()
            vim.opt.termguicolors = true
            require 'colorizer'.setup()
        end,
    }

    use {'tpope/vim-repeat', event = 'VimEnter'}
    use {'tpope/vim-apathy', event = 'VimEnter'}
    use {'tpope/vim-commentary', event = 'VimEnter'}
    use {
        'ojroques/vim-oscyank',
        event = 'VimEnter',
        config = function()
            require'plugins.oscyank'
        end,
    }

    use {
        'windwp/nvim-autopairs',
        event = 'InsertEnter',
        config = function()
            require'plugins.pairs'
        end,
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

    use {'tpope/vim-projectionist', event = 'VimEnter'}

    use {
        'tpope/vim-fugitive',
        cond = function() return vim.fn.executable('git') == 1 end,
    }
    use {'junegunn/gv.vim', cmd = 'GV', after = 'vim-fugitive'}

    use {
        'mhinz/vim-signify',
        cond = function() return vim.fn.executable('git') == 1 end,
        config = function() require'plugins.signify' end,
    }

    use {
        'rhysd/git-messenger.vim',
        cond = function() return vim.fn.executable('git') == 1 end,
        keys = '=m',
        config = function()
            vim.g.git_messenger_no_default_mappings = 1
            vim.api.nvim_set_keymap(
                'n',
                '=m',
                '<Plug>(git-messenger)',
                {silent = true, nowait = true}
            )
        end,
    }

    -- use {'rhysd/committia.vim'}

    use {'folke/lsp-colors.nvim'}

    use {
        'sainnhe/sonokai',
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

    -- use {
    --     'marko-cerovac/material.nvim',
    --     cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    --     event = {'CursorHold', 'CmdlineEnter'},
    -- }
    -- use {
    --     'glepnir/zephyr-nvim',
    --     cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    --     event = {'CursorHold', 'CmdlineEnter'},
    -- }
    -- use {
    --     'ayu-theme/ayu-vim',
    --     cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    --     event = {'CursorHold', 'CmdlineEnter'},
    -- }
    -- use {
    --     'joshdick/onedark.vim',
    --     cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    --     event = {'CursorHold', 'CmdlineEnter'},
    -- }
    -- use {'tiagovla/tokyodark.nvim'}
    -- use {'bluz71/vim-moonfly-colors'}
    -- use {'bluz71/vim-nightfly-guicolors'}
    -- use {'nanotech/jellybeans.vim'}
    -- use {'whatyouhide/vim-gotham'}

    use {
        'tommcdo/vim-lion',
        event = 'VimEnter',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() vim.g.lion_squeeze_spaces = 1 end,
    }

    use {
        'tpope/vim-abolish',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        -- TODO: configs
        -- config = function() require'plugins.abolish' end,
    }

    use {
        'tpope/vim-dadbod',
        cmd = 'DB',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
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
            }
            vim.g.indentLine_bufTypeExclude = {
                'terminal',
                'man'
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

    -- use {'editorconfig/editorconfig-vim'}
    -- use {'tpope/vim-endwise'}

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
    }

    use {'kana/vim-textobj-line', after = 'vim-textobj-user'}
    use {'kana/vim-textobj-entire', after = 'vim-textobj-user'}
    use {'glts/vim-textobj-comment', after = 'vim-textobj-user'}
    use {'michaeljsmith/vim-indent-object', after = 'vim-textobj-user'}

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
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.todos' end,
    }

    use {
        'vim-airline/vim-airline',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
        config = function() require'plugins.airline' end,
        after = 'firenvim',
    }
    use {'vim-airline/vim-airline-themes', after = 'vim-airline'}

    use {
        'vimwiki/vimwiki',
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    }

    use {
        'neomake/neomake',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has('python3') == 1
        end,
    }

    use {
        'SirVer/ultisnips',
        cond = function()
            return vim.env.VIM_MIN == nil and vim.g.minimal == nil and vim.fn.has('python3') == 1
        end,
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
    }

    use {'honza/vim-snippets', after = 'ultisnips'}

    use {
        'hrsh7th/nvim-compe',
        config = function() require'plugins.completion' end,
        cond = function() return vim.env.VIM_MIN == nil and vim.g.minimal == nil end,
    }

    use {
        'nvim-treesitter/nvim-treesitter',
        run = ':TSUpdate',
        config = function() require'plugins.treesitter' end,
        cond = function()
            return vim.fn.executable('gcc') == 1 or vim.fn.executable('clang') == 1
        end,
        requires = {
            'nvim-treesitter/nvim-treesitter-refactor',
            'nvim-treesitter/nvim-treesitter-textobjects',
            'nvim-treesitter/playground',
        }
    }

    use {
        'neovim/nvim-lspconfig',
        config = function() require'plugins.lsp' end,
        requires = {
            {
                'glepnir/lspsaga.nvim',
                cond = function()
                    return vim.env.VIM_MIN == nil and vim.g.minimal == nil
                end,
                config = function()
                    require'plugins.lspsaga'
                end,
            },
        }
    }

    use {
        'nvim-telescope/telescope.nvim',
        config = function() require'plugins.telescope' end,
        requires = {
            {'nvim-lua/popup.nvim'},
            {'nvim-lua/plenary.nvim'},
        }
    }

    use {
        'pwntester/octo.nvim',
        cond = function() return vim.fn.executable('gh') == 1 end,
        confg = function() require'octo'.setup() end,
    }

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

    -- use {
    --     'ycm-core/YouCompleteMe',
    --     config = function()
    --        vim.fn['plugins#youcompleteme#install']()
    --     end,
    --     cond = function()
    --         -- TODO: has lsp
    --         local ycm = vim.env.YCM ~= nil
    --         local min = vim.env.VIM_MIN ~= nil
    --         local executable = function(exe) return vim.fn.executable(exe) == 1 end
    --         local has_win = vim.fn.has('win32') == 1
    --         local has_python = vim.fn.has('python3') == 1
    --         if ycm and not min and executable('cmake') and has_python then
    --             if has_win and executable('msbuild') then
    --                 return true
    --             elseif not has_win and (executable('g++') or executable('clang++')) then
    --                 return true
    --             end
    --         end
    --         return false
    --     end,
    -- }

end)

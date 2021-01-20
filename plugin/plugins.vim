" plugins.vim Setttings
" github.com/mike325/.vim

if exists('g:loaded_mike_plugins') || has#minimal() || has#bare() || !has#plugin_manager()
    finish
endif

let g:loaded_mike_plugins = 1

Plug 'ayu-theme/ayu-vim'
Plug 'joshdick/onedark.vim'
Plug 'sainnhe/sonokai'
" Plug 'bluz71/vim-moonfly-colors'
" Plug 'bluz71/vim-nightfly-guicolors'

Plug 'easymotion/vim-easymotion'
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-abolish'
Plug 'honza/vim-snippets'
Plug 'Yggdroot/indentLine'
Plug 'tpope/vim-dadbod', {'on': ['DB']}
Plug 'tpope/vim-endwise'
Plug 'tpope/vim-markdown'
" Plug 'henrik/vim-indexed-search'
" Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }
" Plug 'morhetz/gruvbox'
" Plug 'sickill/vim-monokai'
" Plug 'nanotech/jellybeans.vim'
" Plug 'whatyouhide/vim-gotham'
" Plug 'AndrewRadev/switch.vim'
" Plug 'AndrewRadev/splitjoin.vim'
" Plug 'editorconfig/editorconfig-vim'
" Plug 'pechorin/any-jump.vim'

if has('nvim-0.5') && (executable('gcc') || executable('clang'))
    Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
    " Plug '~/source/nvim-treesitter', {'do': ':TSUpdate'}
    Plug 'nvim-treesitter/nvim-treesitter-refactor'
    " Plug '~/source/nvim-treesitter-refactor'
    Plug 'nvim-treesitter/nvim-treesitter-textobjects'
    " Plug '~/source/nvim-treesitter-textobjects'
    " Plug 'romgrk/nvim-treesitter-context'
else
    Plug 'tbastos/vim-lua'
    Plug 'octol/vim-cpp-enhanced-highlight'

    if has('nvim') && has#python('3', '5')
        Plug 'numirias/semshi', {'do': ':silent! UpdateRemotePlugins'}
    endif

endif

if has('nvim-0.4') && empty($SSH_CONNECTION)
    Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
endif

if !os#name('windows')
    Plug 'tpope/vim-vinegar'
endif

if has#python() && has#async()
    Plug 'neomake/neomake'
endif

if has('nvim-0.5')
    Plug 'nvim-lua/popup.nvim'
    Plug 'nvim-lua/plenary.nvim'
    Plug 'nvim-lua/telescope.nvim'
elseif executable('fzf') && !os#name('cygwin')
    " Use chocolately/scoop install in windows
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': function('plugins#fzf_vim#install')}
    Plug 'junegunn/fzf.vim'
elseif exists('g:gonvim_running')
    Plug 'akiyosi/gonvim-fuzzy'
else
    Plug 'ctrlpvim/ctrlp.vim'

    if has('python3')
        Plug 'raghur/fruzzy', {'do': function('fruzzy#install')}
    elseif has#python()
        " Fast and 'easy' to compile C CtrlP matcher
        if (executable('gcc') || executable('clang')) && empty($NO_PYTHON_DEV) && !os#name('windows')
            " Windows must have msbuild compiler to work, temporally disabled
            Plug 'JazzCore/ctrlp-cmatcher', { 'do': function('plugins#ctrlp_vim#installcmatcher')}
        else
            " Fast matcher for ctrlp
            Plug 'FelikZ/ctrlp-py-matcher'
        endif
    endif
endif

if executable('git') || executable('hg') || executable('svn')
    " These are the only VCS I care, if none is installed, then skip this plugin
    if has#async()
        Plug 'mhinz/vim-signify'
    else
        Plug 'mhinz/vim-signify', { 'branch': 'legacy' }
    endif
endif

if executable('git')
    if v:version > 704
        Plug 'rhysd/git-messenger.vim'
    endif
    if !os#name('windows')
        Plug 'rhysd/committia.vim'
    endif
endif

if (v:version > 703 || has('nvim')) && !exists('g:started_by_firenvim')
    Plug 'vim-airline/vim-airline'
    Plug 'vim-airline/vim-airline-themes'
endif

if has#python() && (has('nvim') || (v:version >= 704))
    if has#python(3, 5)
        Plug 'SirVer/ultisnips'
    else
        " Froze ultisnips to latest python2 and python3.4 supported version
        Plug 'SirVer/ultisnips', {'commit': '30e651f', 'frozen': 1, 'dir': vars#basedir().'/plugged/frozen_ultisnips'}
    endif
else
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
endif

if !empty($YCM) && empty($NO_PYTHON_DEV) &&
    \ has#python() && has#async() && !os#name('cygwin') && executable('cmake') &&
    \ ((has('unix') && (executable('gcc')  || executable('clang'))) ||
    \ (os#name('windows') && executable('msbuild')))

    if has#python('3', '5', '1')
        Plug 'ycm-core/YouCompleteMe', { 'do': function('plugins#youcompleteme#install') }
    else
        Plug 'ycm-core/YouCompleteMe', { 'branch': 'legacy-py2', 'do': function('plugins#youcompleteme#install'), 'frozen': 1, 'dir': vars#basedir().'/plugged/frozen_ycm'}
    endif

elseif has('nvim-0.5')
    Plug 'nvim-lua/completion-nvim'

    if executable('gcc') || executable('clang')
        Plug 'nvim-treesitter/completion-treesitter'
    endif

    if tools#CheckLanguageServer()
        Plug 'neovim/nvim-lspconfig'
    endif

    " TODO: Integrate this with treesitter
    " if executable('ccls')
    "     Plug 'jackguo380/vim-lsp-cxx-highlight'
    " endif

elseif v:version >= 704
    Plug 'lifepillar/vim-mucomplete'
endif

if executable('tex') && (has('nvim') || (v:version >= 704))
    Plug 'lervag/vimtex'
endif

if has('nvim') || (v:version >= 704)
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-line'
    Plug 'kana/vim-textobj-entire'
    Plug 'glts/vim-textobj-comment'
    Plug 'michaeljsmith/vim-indent-object'
endif

if v:version > 704
    Plug 'vimwiki/vimwiki'
endif

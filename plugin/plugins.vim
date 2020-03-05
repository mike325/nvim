" plugins.vim Setttings
" github.com/mike325/.vim

if exists('g:loaded_mike_plugins') || exists('g:minimal') || exists('g:bare')
    finish
endif

let g:loaded_mike_plugins = 1

Plug 'ayu-theme/ayu-vim'
Plug 'joshdick/onedark.vim'
Plug 'elzr/vim-json'
Plug 'tbastos/vim-lua'
Plug 'peterhoeg/vim-qml'
Plug 'tpope/vim-markdown'
Plug 'PProvost/vim-ps1'
Plug 'cespare/vim-toml'
Plug 'bjoernd/vim-syntax-simics'
Plug 'kurayama/systemd-vim-syntax'
Plug 'mhinz/vim-nginx'
Plug 'raimon49/requirements.txt.vim'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'easymotion/vim-easymotion'
Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }
Plug 'tommcdo/vim-lion'
Plug 'tpope/vim-abolish'
Plug 'honza/vim-snippets'
Plug 'Yggdroot/indentLine'
Plug 'henrik/vim-indexed-search'
Plug 'tpope/vim-dadbod', {'on': ['DB']}
Plug 'tpope/vim-endwise'
" Plug 'morhetz/gruvbox'
" Plug 'sickill/vim-monokai'
" Plug 'nanotech/jellybeans.vim'
" Plug 'whatyouhide/vim-gotham'
" Plug 'AndrewRadev/switch.vim'
" Plug 'AndrewRadev/splitjoin.vim'
" Plug 'editorconfig/editorconfig-vim'

if has('nvim-0.4')
    Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
endif

if has('nvim') && has#python('3', '5')
    Plug 'numirias/semshi', {'do': ':silent! UpdateRemotePlugins'}
endif

if !os#name('windows')
    Plug 'tpope/vim-vinegar'
endif

if has#python() && has#async() && !has('nvim-0.5')
    Plug 'neomake/neomake'
endif

if executable('fzf') && !os#name('cygwin')
    " Use chocolately install in windows
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
    Plug 'rhysd/git-messenger.vim'
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
    elseif has('python3')
        Plug 'ycm-core/YouCompleteMe', { 'commit': '299f8e48e7d34e780d24b4956cd61e4d42a139eb', 'do': function('plugins#youcompleteme#install'), 'frozen': 1, 'dir': vars#basedir().'/plugged/frozen_ycm'}
    else
        Plug 'ycm-core/YouCompleteMe', { 'branch': 'legacy-py2', 'do': function('plugins#youcompleteme#install'), 'frozen': 1, 'dir': vars#basedir().'/plugged/frozen_ycm'}
    endif

elseif has('nvim-0.5') && tools#CheckLanguageServer()
    Plug 'neovim/nvim-lsp'
    Plug 'lifepillar/vim-mucomplete'
elseif v:version >= 800 && tools#CheckLanguageServer()
    Plug 'natebosch/vim-lsc'
elseif has#async() && (has('nvim-0.2.0') || (!has('nvim') && has('lambda')))
    Plug 'maralla/completor.vim'
elseif has('lua') && !has('nvim') && v:version >= 704
    Plug 'Shougo/neocomplete.vim'
else
    Plug 'ervandew/supertab'
endif

if executable('ccls')
    Plug 'jackguo380/vim-lsp-cxx-highlight'
endif

if (has('nvim') || (v:version >= 704)) && (executable('tex'))
    Plug 'lervag/vimtex'
endif

if (has('nvim') || (v:version >= 704))
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-line'
    Plug 'kana/vim-textobj-entire'
    Plug 'glts/vim-textobj-comment'
    Plug 'michaeljsmith/vim-indent-object'
endif

if os#name('windows') && v:version > 704
    " NOTE: Urls doesn't work in master branch because vimwiki pass the wrong variable
    Plug 'vimwiki/vimwiki', {'branch': 'dev'}
elseif v:version > 704
    Plug 'vimwiki/vimwiki'
endif

" Unix commands
if has('unix')
    Plug 'tpope/vim-eunuch'
endif

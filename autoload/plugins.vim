" Plugins Setttings
" github.com/mike325/.vim

function! plugins#init() abort

    " Plug 'morhetz/gruvbox'
    " Plug 'sickill/vim-monokai'
    " Plug 'nanotech/jellybeans.vim'
    " Plug 'whatyouhide/vim-gotham'
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

    if has('nvim') && has#python('3', '5')
        Plug 'numirias/semshi', {'do': ':silent! UpdateRemotePlugins'}
    endif

    " Project standardize file settings
    " Plug 'editorconfig/editorconfig-vim'

    " Easy alignment with motions and text objects
    Plug 'tommcdo/vim-lion'

    " Have some problmes with vinager in windows
    if !os#name('windows')
        Plug 'tpope/vim-vinegar'
    endif

    " Project check
    if has#python() && has#async()
        Plug 'neomake/neomake'
    endif

    if executable('fzf') && !os#name('cygwin')
        " Use chocolately install in windows
        Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': function('plugins#fzf_vim#install')}
        Plug 'junegunn/fzf.vim'
    elseif exists('g:gonvim_running')
        Plug 'akiyosi/gonvim-fuzzy'
    elseif has('patch-8.1.2114') || has('nvim-0.4.2')
        Plug 'liuchengxu/vim-clap'
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
        if executable('hub')
            Plug 'tpope/vim-rhubarb'
        endif
        if !os#name('windows')
            Plug 'rhysd/committia.vim'
        endif
    endif

    " Vim airline is available for >= Vim 7.4
    if v:version > 703 || has('nvim')
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
    endif

    Plug 'tpope/vim-abolish'
    Plug 'honza/vim-snippets'
    Plug 'Shougo/neco-vim'

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

    " This env var allow us to know if the python version has the dev libs
    " Awesome has#async completion engine for Neovim
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

        " Plug 'davits/DyeVim'

        " C/C++ project generator
        " Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
    elseif has('nvim-0.5') && tools#CheckLanguageServer()
        Plug 'neovim/nvim-lsp'
        Plug 'lifepillar/vim-mucomplete'
    elseif has#async() && tools#CheckLanguageServer()
        Plug 'natebosch/vim-lsc'
    elseif has#async() && (has('nvim-0.2.0') || (!has('nvim') && has('lambda')))
        Plug 'maralla/completor.vim'
    " Neovim does not support Lua plugins yet
    elseif has('lua') && !has('nvim') && v:version >= 704
        Plug 'Shougo/neocomplete.vim'
    elseif v:version >= 703 || has('nvim')
        Plug 'roxma/SimpleAutoComplPop'
        if !has('nvim') && v:version < 800
            Plug 'ervandew/supertab'
        endif
    endif

    Plug 'tpope/vim-endwise'

    " if executable('go') && has#async()
    "     Plug 'fatih/vim-go'
    " endif

    if (has('nvim') || (v:version >= 704)) && (executable('tex'))
        Plug 'lervag/vimtex'
    endif

    if (has('nvim') || (v:version >= 704))
        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-line'
        Plug 'glts/vim-textobj-comment'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'kana/vim-textobj-entire'

        " TODO: Solve conflict with comment plugin
        " Plug 'coderifous/textobj-word-column.vim'
    endif

    " Better motions
    Plug 'easymotion/vim-easymotion'

    " Better buffer deletions
    Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

    " Easy change text
    " Plug 'AndrewRadev/switch.vim'

    " Simple Join/Split operators
    " Plug 'AndrewRadev/splitjoin.vim'

    if os#name('windows') && v:version > 704
        " NOTE: Urls doesn't work in master branch because vimwiki pass the wrong
        "       variable
        Plug 'vimwiki/vimwiki', {'branch': 'dev'}
    elseif v:version > 704
        Plug 'vimwiki/vimwiki'
    endif

    " Display indention
    Plug 'Yggdroot/indentLine'

    " " Automatically clears search highlight when cursor is moved
    " Plug 'junegunn/vim-slash'

    " Print the number of the available buffer matches
    Plug 'henrik/vim-indexed-search'

    " Database management
    Plug 'tpope/vim-dadbod', {'on': ['DB']}

    " Unix commands
    if has('unix')
        Plug 'tpope/vim-eunuch'
    endif

endfunction

function! s:Convert2settings(name) abort
    let l:name = (a:name =~? '[\.\-]') ? substitute(a:name, '[\.\-]', '_', 'g') : a:name
    let l:name = substitute(l:name, '.', '\l\0', 'g')
    return l:name
endfunction

function! plugins#settings() abort
    let s:available_configs = map(glob(vars#basedir() . '/autoload/plugins/*.vim', 0, 1), 'fnamemodify(v:val, ":t:r")')

    try
        for [s:name, s:data] in items(filter(deepcopy(g:plugs), 'index(s:available_configs, s:Convert2settings(v:key), 0) != -1'))
            let s:func_name = s:Convert2settings(s:name)
            call plugins#{s:func_name}#init(s:data)
        endfor
    catch
        echomsg 'Error trying to read config from ' . s:name
    endtry
endfunction


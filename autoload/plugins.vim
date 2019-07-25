" ############################################################################
"
"                               plugins Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################


function! plugins#init() abort

    " ####### Colorschemes {{{
    " Plug 'morhetz/gruvbox'
    " Plug 'sickill/vim-monokai'
    " Plug 'nanotech/jellybeans.vim'
    " Plug 'whatyouhide/vim-gotham'
    if has('nvim')
        Plug 'ayu-theme/ayu-vim'
    else
        Plug 'joshdick/onedark.vim'
    endif

    " }}} END Colorschemes

    " ####### Syntax {{{

    Plug 'elzr/vim-json'
    Plug 'tbastos/vim-lua'
    Plug 'peterhoeg/vim-qml'
    Plug 'tpope/vim-markdown'
    Plug 'PProvost/vim-ps1'
    Plug 'cespare/vim-toml'
    Plug 'ekalinin/Dockerfile.vim'
    Plug 'bjoernd/vim-syntax-simics'
    Plug 'kurayama/systemd-vim-syntax'
    Plug 'mhinz/vim-nginx'
    Plug 'raimon49/requirements.txt.vim'

    if has('nvim') && has#python('3', '5')
        Plug 'numirias/semshi', {'do': ':silent! UpdateRemotePlugins'}
        " Plug 'blahgeek/neovim-colorcoder', {'do': ':silent! UpdateRemotePlugins'}
        " Plug 'arakashic/chromatica.nvim', {'do': ':silent! UpdateRemotePlugins'}
    endif

    Plug 'octol/vim-cpp-enhanced-highlight'

    " }}} END Syntax

    " ####### Project base {{{

    " Project standardize file settings
    " Plug 'editorconfig/editorconfig-vim'

    " Easy alignment with motions and text objects
    Plug 'tommcdo/vim-lion'

    " Have some problmes with vinager in windows
    if !os#name('windows')
        Plug 'tpope/vim-vinegar'
    endif

    " Project check
    if has#python()
        if has#async()
            Plug 'neomake/neomake'
        else
            Plug 'vim-syntastic/syntastic'
        endif
    endif

    " TODO: Fugitive seems to break tcd, try to fix it
    if ( executable('fzf') && isdirectory(vars#home() . '/.fzf') ) || !os#name('windows')
        if os#name('windows')  " install in windows by using choco install
            Plug 'junegunn/fzf', { 'dir': '~/.fzf'}
        else
            Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all --no-update-rc'}
        endif
        Plug 'junegunn/fzf.vim'
    elseif exists('g:gonvim_running')
        Plug 'akiyosi/gonvim-fuzzy'
    elseif has('nvim') && has#python('3')

        Plug 'Shougo/denite.nvim'
        Plug 'raghur/fruzzy', {'do': { -> fruzzy#install()}}
        " Plug 'dunstontc/projectile.nvim'
        " Plug 'chemzqm/denite-git'
    else
        Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

        Plug 'ctrlpvim/ctrlp.vim'

        if os#name('unix') && executable('git')
            Plug 'jasoncodes/ctrlp-modified.vim'
        endif

        if has#python('3')

            Plug 'raghur/fruzzy', {'do': { -> fruzzy#install()}}

        elseif has#python()
            " Fast and 'easy' to compile C CtrlP matcher
            if (executable('gcc') || executable('clang')) && empty($NO_PYTHON_DEV) && !os#name('windows')
                " Windows must have msbuild compiler to work, temporally disabled
                Plug 'JazzCore/ctrlp-cmatcher', { 'do': function('plugins#ctrlp_vim#installcmatcher')}
            else
                " Fast matcher for ctrlp
                Plug 'FelikZ/ctrlp-py-matcher'
            endif

            " The fastes matcher (as far as I know) but way more complicated to setup
            " Plug 'nixprime/cpsm'
        endif
    endif

    " }}} END Project base

    " ####### Git integration {{{

    " Plug 'airblade/vim-gitgutter'
    if executable('git') || executable('hg') || executable('svn')
        " These are the only VCS I care, if none is installed, then skip this plugin
        Plug 'mhinz/vim-signify'
    endif

    if executable('git')
        if executable('hub')
            Plug 'tpope/vim-rhubarb'
        endif
        Plug 'rhysd/git-messenger.vim', {'on': ['GitMessenger']}
        if !os#name('windows')
            Plug 'rhysd/committia.vim'
        endif
    endif

    " }}} END Git integration

    " ####### Status bar {{{

    " Vim airline is available for >= Vim 7.4
    if v:version > 703 || has('nvim')
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
    endif

    " }}} END Status bar

    " ####### Completions {{{

    Plug 'tpope/vim-abolish'
    Plug 'honza/vim-snippets'
    Plug 'Shougo/neco-vim'

    if has#python() && (has('nvim') || (v:version >= 704))
        Plug 'SirVer/ultisnips'
    else
        Plug 'MarcWeber/vim-addon-mw-utils'
        Plug 'tomtom/tlib_vim'
        Plug 'garbas/vim-snipmate'
    endif

    let l:ycm_installed = 0
    let l:deoplete_installed = 0
    let l:completor = 0

    " This env var allow us to know if the python version has the dev libs
    if empty($NO_PYTHON_DEV) && has#python() " Python base completions {{{

        " Awesome has#async completion engine for Neovim
        if !empty($YCM) && has#async() && executable('cmake') && (( has('unix') && ( executable('gcc')  || executable('clang') )) ||
                    \ (os#name('windows') && executable('msbuild')))

            if has#python('3', '5', '1')
                Plug 'ycm-core/YouCompleteMe', { 'do': function('plugins#youcompleteme#install') }
            else
                Plug 'ycm-core/YouCompleteMe', { 'commit': '299f8e48e7d34e780d24b4956cd61e4d42a139eb', 'do': function('plugins#youcompleteme#install') , 'frozen', 1}
            endif
            " Plug 'davits/DyeVim'

            " C/C++ project generator
            " Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
            let l:ycm_installed = 1
        elseif has('nvim-0.2.0') && has#python('3', '4')

            if has('nvim-0.3.0') && has#python('3', '6', '1')
                Plug 'Shougo/deoplete.nvim', { 'do': ':silent! UpdateRemotePlugins'}
            else
                Plug 'Shougo/deoplete.nvim', { 'tag': '2.0', 'do': ':silent! UpdateRemotePlugins', 'frozen' : 1}
            endif

            " Show parameters of the current function
            Plug 'Shougo/echodoc.vim'

            " TODO: I had had some probles with pysl in windows, so let's
            "       skip it until I can figure it out how to fix this
            if tools#CheckLanguageServer()
                let g:branch =  has('nvim-0.2') ? {'branch': 'next', 'do': function('plugins#languageclient_neovim#install')} :
                                                \ {'tag': '0.1.66', 'do': function('plugins#languageclient_neovim#install'), 'frozen': 1}
                Plug 'autozimu/LanguageClient-neovim', g:branch
                unlet g:branch
            endif

            if !tools#CheckLanguageServer('c')
                " C/C++ completion base on clang compiler
                if executable('clang')
                    if os#name('windows')
                        " A bit faster C/C++ completion
                        Plug 'tweekmonster/deoplete-clang2'
                    else
                        " NOTE: Doesn't support windows
                        Plug 'zchee/deoplete-clang'
                        " Plug 'Shougo/neoinclude.vim'
                    endif
                endif
            endif

            if !tools#CheckLanguageServer('python')
                " Python completion
                if has('nvim-0.2')
                    Plug 'zchee/deoplete-jedi'
                else
                    Plug 'zchee/deoplete-jedi', {'commit': '3f510b467baded4279c52147e98f840b53324a8b', 'frozen': 1}
                endif
            endif

            " Go completion
            if !tools#CheckLanguageServer('go') && executable('make') && executable('go')
                Plug 'zchee/deoplete-go', { 'do':function('plugins#deoplete_nvim#gocomletion')}
            endif

            " JavaScript completion
            if !tools#CheckLanguageServer('javascript') && executable('ternjs')
                Plug 'carlitux/deoplete-ternjs'
            endif

            let l:deoplete_installed = 1
        elseif has#async() && (has('nvim-0.2.0')) || !has('nvim')
            " Test new completion has#async framework that require python and vim 8 or
            " Neovim (without python3)
            if tools#CheckLanguageServer('any')
                Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': function('plugins#languageclient_neovim#install')}
            endif

            Plug 'maralla/completor.vim'
            let l:completor = 1
        endif

        if l:ycm_installed==0 && l:deoplete_installed==0
            " Completion for python without engines
            Plug 'davidhalter/jedi-vim'

        endif

    endif " }}} END Python base completions

    " Vim clang does not require python
    if executable('clang') && l:ycm_installed==0 && l:deoplete_installed==0
        Plug 'justmao945/vim-clang'
    endif

    " Completion without python completion engines ( ycm, deoplete or completer )
    if l:ycm_installed==0 && l:deoplete_installed==0 && l:completor==0
        " Neovim does not support Lua plugins yet
        if has('lua') && !has('nvim') && (v:version >= 704)
            Plug 'Shougo/neocomplete.vim'
        elseif (v:version >= 703) || has('nvim')
            Plug 'roxma/SimpleAutoComplPop'

            if !has('nvim') && (v:version < 800)
                Plug 'ervandew/supertab'
            endif
        endif
    endif

    " }}} END Completions

    " ####### Languages {{{

    Plug 'tpope/vim-endwise'
    " Plug 'fidian/hexmode'

    if executable('go') && has#async()
        Plug 'fatih/vim-go'
    endif

    if (has('nvim') || (v:version >= 704)) && (executable('tex'))
        Plug 'lervag/vimtex'
    endif

    " }}} END Languages

    " ####### Text objects, Motions and Text manipulation {{{

    if (has('nvim') || (v:version >= 704))
        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-line'
        Plug 'glts/vim-textobj-comment'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'kana/vim-textobj-entire'

        " TODO: Solve conflict with comment plugin
        " Plug 'coderifous/textobj-word-column.vim'
    endif

    " JSON text objects
    " Plug 'tpope/vim-jdaddy'

    " Better motions
    Plug 'easymotion/vim-easymotion'

    " }}} END Text objects, Motions and Text manipulation

    " ####### Misc {{{

    " Better buffer deletions
    Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

    " Easy change text
    " Plug 'AndrewRadev/switch.vim'

    " Simple Join/Split operators
    " Plug 'AndrewRadev/splitjoin.vim'

    if os#name('windows')
        " NOTE: Urls doesn't work in master branch because vimwiki pass the wrong
        "       variable
        Plug 'vimwiki/vimwiki', {'branch': 'dev'}
    else
        Plug 'vimwiki/vimwiki'
    endif

    " Display indention
    Plug 'Yggdroot/indentLine'

    " Automatically clears search highlight when cursor is moved
    Plug 'junegunn/vim-slash'

    " Print the number of the available buffer matches
    Plug 'henrik/vim-indexed-search'

    " Database management
    Plug 'tpope/vim-dadbod', {'on': ['DB']}

    " Unix commands
    if has('unix')
        Plug 'tpope/vim-eunuch'
    endif

    if has('nvim')
        Plug 'Vigemus/iron.nvim'
    elseif !has('terminal')
        " Useful to get the console output in Vim (since :terminal is not enable yet)
        Plug 'tpope/vim-dispatch'
    endif

    " }}} END Misc
endfunction

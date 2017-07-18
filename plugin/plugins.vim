" HEADER {{{
"
"                             Plugin installation
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
" }}} END HEADER

" We just want to source this file once
if exists("g:plugins_loaded") && g:plugins_loaded
    finish
endif

let g:plugins_loaded = 1

call plug#begin(g:base_path.'plugged')

" ####### Colorschemes {{{

Plug 'morhetz/gruvbox'
Plug 'sickill/vim-monokai'
Plug 'nanotech/jellybeans.vim'
Plug 'whatyouhide/vim-gotham'
Plug 'joshdick/onedark.vim'

" }}} END Colorschemes

" ####### Syntax {{{

Plug 'ekalinin/Dockerfile.vim', { 'for': 'Dockerfile' }
Plug 'elzr/vim-json', { 'for': 'json' }
Plug 'tbastos/vim-lua', { 'for': 'lua' }
Plug 'octol/vim-cpp-enhanced-highlight', { 'for': 'cpp' }
Plug 'peterhoeg/vim-qml', { 'for': 'qml' }
Plug 'plasticboy/vim-markdown'
Plug 'bjoernd/vim-syntax-simics', { 'for': 'simics' }

" }}} END Syntax

" ####### Project base {{{

Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }
Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': [ 'NERDTreeToggle' ] }
Plug 'mhinz/vim-grepper'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

if executable("ctags")
    " Simple view of Tags using ctags
    Plug 'majutsushi/tagbar'
endif

" Syntax check
if has("python") || has("pyhton3")
    if has("nvim") || ( v:version >= 800 )
        Plug 'neomake/neomake'
    else
        Plug 'vim-syntastic/syntastic'
    endif
endif

" Autoformat tools
" TODO Check this fork, No +python required
" Plug 'umitkablan/vim-auf'
" TODO Check google's own formatter
" Plug 'google/vim-codefmt'
if (has("nvim") || (v:version >= 704))
    " Code Format tool
    Plug 'chiel92/vim-autoformat'
endif

" Easy alignment
Plug 'godlygeek/tabular'

Plug 'ctrlpvim/ctrlp.vim', { 'on': [ 'CtrlPBuffer', 'CtrlP', 'CtrlPMRUFiles'] }
" Plug 'tacahiroy/ctrlp-funky'

if has("python") || has("pyhton3")
    function! BuildCtrlPMatcher(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            if ( has("win32") || has("win64") ) && executable("gcc")
                !./install_windows.bat
            else
                !./install.sh
            endif
        endif
    endfunction

    " Faster matcher for ctrlp
    Plug 'FelikZ/ctrlp-py-matcher'

    " Fast and 'easy' to compile C CtrlP matcher
    " Plug 'JazzCore/ctrlp-cmatcher', { 'do': function('BuildCtrlPMatcher') }

    " The fastes matcher (as far as I know) but way more complicated to setup
    " Plug 'nixprime/cpsm'

endif

" }}} END Project base

" ####### Git integration {{{

Plug 'airblade/vim-gitgutter'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv'

" }}} END Git integration

" ####### Status bar {{{

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'enricobacis/vim-airline-clock'

" }}} END Status bar

" ####### Completions {{{

Plug 'Raimondi/delimitMate'
Plug 'tpope/vim-abolish'
Plug 'honza/vim-snippets'

if (has("python") || has("python3")) && (has("nvim") || (v:version >= 704))
    Plug 'SirVer/ultisnips'
else
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
endif

let b:ycm_installed = 0
let b:deoplete_installed = 0
let b:completor = 0
if ( has("python") || has("python3") )

    if has("nvim") || ( v:version >= 800 ) || ( v:version >= 704 )
        " Only works with JDK8!!!
        Plug 'artur-shaik/vim-javacomplete2', { 'for': 'java' }
    endif


    function! BuildOmniSharp(info)
        if a:info.status == 'installed' || a:info.force
            if ( has("win32") || has("win64") )
                !cd server && msbuild
            else
                !cd server && xbuild
            endif
        endif
    endfunction

    " Plug 'OmniSharp/omnisharp-vim', { 'do': function('BuildOmniSharp') }

    " Awesome Async completion engine for Neovim
    if ( has("nvim") && has("python3") )
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

        " Python completion
        Plug 'zchee/deoplete-jedi'

        " C/C++ completion base on clang compiler
        if executable("clang")
            Plug 'zchee/deoplete-clang'
            " Plug 'zchee/deoplete-clang'

            " A bit faster C/C++ completion
            " Plug 'tweekmonster/deoplete-clang2'
        endif

        " Go completion
        if executable("go") && executable("make")
            Plug 'zchee/deoplete-go', { 'do': 'make'}
        endif

        " JavaScript completion
        if executable("tern")
            Plug 'carlitux/deoplete-ternjs'
        endif

        let b:deoplete_installed = 1

    elseif ( v:version >= 800 ) || has("nvim")
        " Test new completion Async framework that require python and vim 8 or
        " Neovim (without python3)
        Plug 'maralla/completor.vim'
        let b:completor = 1
    elseif (has("unix") || ((has("win32") || has("win64")) && executable("msbuild"))) &&
        \  (has("nvim") || (v:version >= 800) || (v:version == 704 && has("patch143")) )

        function! BuildYCM(info)
            if a:info.status == 'installed' || a:info.force
                " !./install.py --all
                " !./install.py --gocode-completer --tern-completer --clang-completer --omnisharp-completer
                if executable('go') && executable("tern")
                    !./install.py --gocode-completer --tern-completer
                elseif executable("tern")
                    !./install.py --tern-completer
                elseif executable('go')
                    !./install.py --gocode-completer
                else
                    !./install.py
                endif
            endif
        endfunction

        " Install ycm if Neovim/vim 8/Vim 7.143 is running on unix or
        " If it is running on windows with Neovim/Vim 8/Vim 7.143 and ms C compiler
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

        " C/C++ project generator
        Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
        let b:ycm_installed = 1
    endif


    if b:ycm_installed==0 && b:deoplete_installed==0 && b:completor==0
        " Completion for python without engines
        Plug 'davidhalter/jedi-vim'
    endif

endif

" completion without python completion engines ( ycm, deoplete or completer )
if b:ycm_installed==0 && b:deoplete_installed==0 && b:completor==0
    " Neovim does not support Lua plugins yet
    if has("lua") && !has("nvim") && (v:version >= 704)
        Plug 'Shougo/neocomplete.vim'
    elseif (v:version >= 703) || has("nvim")
        Plug 'Shougo/neocomplcache.vim'
        " Plug 'ervandew/supertab'
        " Plug 'roxma/SimpleAutoComplPop'
    endif
endif

" }}} END Completions

" ####### Languages {{{

Plug 'tpope/vim-endwise'
Plug 'fidian/hexmode'

if (has("nvim") || (v:version >= 704))
    Plug 'lervag/vimtex'
endif

if executable("go")
    Plug 'fatih/vim-go', { 'for': 'go' }
endif

if has("python") || has("python3")
    Plug 'python-mode/python-mode', { 'for': 'python' }
endif

" Easy comments
" TODO check other comment plugins with motions
Plug 'scrooloose/nerdcommenter'

" }}} END Languages

" ####### Text objects, Motions and Text manipulation {{{

if (has("nvim") || (v:version >= 704))
    Plug 'sickill/vim-pasta'
    Plug 'kana/vim-textobj-user'
    Plug 'kana/vim-textobj-line'
    Plug 'glts/vim-textobj-comment'
    Plug 'whatyouhide/vim-textobj-xmlattr'
    Plug 'kana/vim-textobj-entire'
    Plug 'michaeljsmith/vim-indent-object'
    " Plug 'coderifous/textobj-word-column.vim'
endif

" Better motions
Plug 'easymotion/vim-easymotion'

" Surround motions
Plug 'tpope/vim-surround'

" Map repeat key . for plugins
Plug 'tpope/vim-repeat'

" }}} END Text objects, Motions and Text manipulation

" ####### Misc {{{

" Better buffer deletions
Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

" Visual marks
Plug 'kshenoy/vim-signature'

" Move with indentation
Plug 'matze/vim-move'

" Easy change text
" Plug 'AndrewRadev/switch.vim'

" Simple Join/Split operators
Plug 'AndrewRadev/splitjoin.vim'

" Expand visual regions
Plug 'terryma/vim-expand-region'

" Display indention
Plug 'Yggdroot/indentLine'

" Change buffer position in the current layout
Plug 'wesQ3/vim-windowswap'

" Unix commands
if has("unix")
    Plug 'tpope/vim-eunuch'
endif

if !has("nvim")
    Plug 'tpope/vim-sensible'
endif

" }}} END Misc

" Initialize plugin system
call plug#end()

filetype plugin indent on

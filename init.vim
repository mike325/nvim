" ############################################################################
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
"                   `++:.                           `-/+/
"                   .`                                 `/
"
" ############################################################################

" I use this later in global.vim
let g:os_editor = ""

" Specify a directory for plugins
if has("nvim")
    if has("win32") || has("win64")
        let g:os_editor = '~\AppData\Local\nvim\'
    else
        let g:os_editor = '~/.config/nvim/'
    endif
elseif has("win32") || has("win64")
    let g:os_editor = '~\vimfiles\'
else
    let g:os_editor = '~/.vim/'
endif

call plug#begin(g:os_editor.'plugged')

" Colorschemes for vim
Plug 'morhetz/gruvbox'
Plug 'sickill/vim-monokai'
Plug 'nanotech/jellybeans.vim'
Plug 'whatyouhide/vim-gotham'
Plug 'joshdick/onedark.vim'

" Auto Close ' " () [] {}
Plug 'Raimondi/delimitMate'

" File explorer, and
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }

" Easy comments
Plug 'scrooloose/nerdcommenter'

" Status bar and some themes
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'enricobacis/vim-airline-clock'

" Git integrations
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'gregsexton/gitv'
Plug 'rhysd/committia.vim'
Plug 'tpope/vim-git'

" Easy alignment
Plug 'godlygeek/tabular'

" Better motions
Plug 'easymotion/vim-easymotion'

" Surround motions
Plug 'tpope/vim-surround'

" Better buffer deletions
Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

" Visual marks
Plug 'kshenoy/vim-signature'

" Search files, buffers, etc
Plug 'ctrlpvim/ctrlp.vim', { 'on': [ 'CtrlPBuffer', 'CtrlP' ] }

" Better sessions management
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" Auto convert bin files
Plug 'fidian/hexmode'

" Collection of snippets
Plug 'honza/vim-snippets'

" Move with indentation
Plug 'matze/vim-move'

" Better substitution, improve abbreviations and coercion
Plug 'tpope/vim-abolish'

" Map repeat key . for plugins
Plug 'tpope/vim-repeat'

" Display indention
Plug 'Yggdroot/indentLine'

" Auto indention put command
Plug 'sickill/vim-pasta'

" Easy change text
" Plug 'AndrewRadev/switch.vim'

" Search into files
Plug 'mhinz/vim-grepper'

" Improve Dockerfiles syntax highlight
Plug 'ekalinin/Dockerfile.vim'

" Improve json syntax highlight
Plug 'elzr/vim-json'

" Improve Lua syntax
Plug 'tbastos/vim-lua'

" Improve cpp syntax highlight
Plug 'octol/vim-cpp-enhanced-highlight'

" Add Qml syntax highlight
Plug 'peterhoeg/vim-qml'

" Latex plugin
Plug 'lervag/vimtex'

" Change buffer position in the current layout
Plug 'wesQ3/vim-windowswap'

" Some useful text objects
Plug 'kana/vim-textobj-user'

" il inside the line (without leading and trailing spaces)
" al around the line (with leading and trailing spaces)
Plug 'kana/vim-textobj-line'

" ic inside the comment (without leading and trailing spaces and
"                        without comment characters)
" iC inside the comment (with leading and trailing spaces and
"                        without comment characters)
" ac around the comment (without leading and trailing spaces and
"                        with comment characters)
" aC around the comment (with leading and trailing spaces and
"                        with comment characters)
Plug 'glts/vim-textobj-comment'

if has("unix")
    Plug 'tpope/vim-eunuch'
endif

if executable("go")
    " Go development
    Plug 'fatih/vim-go'
endif

if !has("nvim")
    " Basic settings
    Plug 'tpope/vim-sensible'
endif

if executable("ctags")
    " Simple view of Tags using ctags
    Plug 'majutsushi/tagbar'
endif

let b:neomake_installed = 0
if has("nvim") || ( v:version >= 800 )
    " Async Syntax's check
    Plug 'neomake/neomake'
    let b:neomake_installed = 1
endif

let b:ycm_installed = 0
let b:deoplete_installed = 0
let b:completor = 0
if ( has("python") || has("python3") )
    " Code Format tool
    Plug 'chiel92/vim-autoformat'

    " Add python highlight, folding, virtualenv, etc
    Plug 'python-mode/python-mode'

    " Snippets engine
    Plug 'SirVer/ultisnips'

    function! BuildYCM(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            " !./install.py --all
            if executable('go') && executable("tern")
                !./install.py --gocode-completer --tern-completer --clang-completer
            elseif executable("tern")
                !./install.py --tern-completer --clang-completer
            elseif executable('go')
                !./install.py --gocode-completer --clang-completer
            else
                !./install.py --clang-completer
            endif
        endif
    endfunction

    if has("nvim") || ( v:version >= 800 ) || ( v:version == 704 )
        " Only works with JDK8!!!
        Plug 'artur-shaik/vim-javacomplete2'
    endif

    " Awesome Async completion engine for Neovim
    if ( has("nvim") && has("python3") )
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }

        " Python completion
        Plug 'zchee/deoplete-jedi'

        " C/C++ completion base on clang compiler
        if executable("clang")
            Plug 'zchee/deoplete-clang'
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
                \ has("nvim") || ( v:version >= 800 ) || ( v:version == 704 && has("patch143"))
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

    if b:neomake_installed==0
        " Synchronous Syntax check
        Plug 'vim-syntastic/syntastic'
    endif
else
" Snippets without python interface
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
endif

" completion without python completion engines ( ycm, deoplete or completer )
if b:ycm_installed==0 && b:deoplete_installed==0 && b:completor==0
    " Neovim does not support Lua plugins yet
    if has("lua") && !has("nvim")
        Plug 'Shougo/neocomplete.vim'
    else
        Plug 'ervandew/supertab'
        " Plug 'roxma/SimpleAutoComplPop'
    endif
endif

" Initialize plugin system
call plug#end()

filetype plugin indent on

" Load general configurations (key mappings and autocommands)
execute 'source '.fnameescape(g:os_editor.'global.vim')

" Load plugins configurations
execute 'source '.fnameescape(g:os_editor.'plugins.vim')

" Load especial host configurations
if filereadable(expand(fnameescape(g:os_editor.'extras.vim')))
    execute 'source '.fnameescape(g:os_editor.'extras.vim')
endif

" " Load project settings
" function! GetLocalSettings()
"     return fnameescape(getcwd().'/local.vim')
" endfunction
"
" if filereadable(GetLocalSettings())
"     execute 'source '.GetLocalSettings()
" endif

" ############################################################################
"
"                               Plugin installation
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
Plug 'flazz/vim-colorschemes' | Plug 'icymind/NeoSolarized' | Plug 'morhetz/gruvbox'

" Auto Close ' " () [] {}
Plug 'Raimondi/delimitMate'

" File explorer, and
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }

" Easy comments
Plug 'scrooloose/nerdcommenter'

" Status bar and some themes
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" Git integrations
Plug 'airblade/vim-gitgutter' | Plug 'tpope/vim-fugitive' | Plug 'rhysd/committia.vim'
Plug 'tpope/vim-git'

" Easy aligment
Plug 'godlygeek/tabular'

" Better motions
Plug 'easymotion/vim-easymotion'

" Easy surround text objects with ' " () [] {} etc
Plug 'tpope/vim-surround'

" Better buffer deletions
Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

" Visual marks
Plug 'kshenoy/vim-signature'

" Search files, buffers, etc
Plug 'kien/ctrlp.vim', { 'on': [ 'CtrlPBuffer', 'CtrlP' ] }

" Better sessions management
Plug 'xolox/vim-misc' | Plug 'xolox/vim-session'

" Auto convert bin files
Plug 'fidian/hexmode'

" Collection of snippets
Plug 'honza/vim-snippets'

" Move with identation
Plug 'matze/vim-move'

" Easy edit registers
Plug 'dohsimpson/vim-macroeditor', { 'on': [ 'MacroEdit' ] }

" Better sustition, improve aibbreviations and coercion
Plug 'tpope/vim-abolish'

" Map repeat key . for plugins
Plug 'tpope/vim-repeat'

" Display indention
Plug 'Yggdroot/indentLine'

" Auto indention put command
Plug 'sickill/vim-pasta'

" Code Format tool
Plug 'chiel92/vim-autoformat'

" Easy change text
Plug 'AndrewRadev/switch.vim'

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

" Add python highlight, folding, virtualenv, etc
Plug 'python-mode/python-mode'

" Add Qml syntax highlight
Plug 'peterhoeg/vim-qml'

" Latex plugin
Plug 'lervag/vimtex'

" Change buffer position in the current layout
Plug 'wesQ3/vim-windowswap'

if executable("go")
    " Go developement
    Plug 'fatih/vim-go'
endif

if !has("nvim")
    " Basic settings
    Plug 'tpope/vim-sensible'
endif

if executable("ctags")
    " Simple view of Tags using ctags
    Plug 'majutsushi/tagbar'
    " if ( has("nvim") || ( v:version >= 800 ) ) && has("python3")
    "     Plug 'c0r73x/neotags.nvim'
    " else
    Plug 'xolox/vim-easytags'
    " endif
endif

let b:neomake_installed = 0
if has("nvim") || ( v:version >= 800 )
    " Async Syntaxis check
    Plug 'neomake/neomake'
    let b:neomake_installed = 1
endif

let b:ycm_installed = 0
let b:deoplete_installed = 0
if ( has("python") || has("python3") )
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

" Awesome completion engine, comment the following if to deactivate ycm
    if ( has("nvim") && has("python3") )
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        Plug 'zchee/deoplete-jedi'

        " Only works with JDK8
        Plug 'artur-shaik/vim-javacomplete2'

        if executable("clang")
            Plug 'zchee/deoplete-clang'
        endif

        if executable("go") && executable("make")
            Plug 'zchee/deoplete-go', { 'do': 'make'}
        endif

        if executable("tern")
            Plug 'carlitux/deoplete-ternjs'
        endif

        let b:deoplete_installed = 1
    elseif has("nvim") || ( v:version >= 800 ) || ( v:version == 704 && has("patch143") )
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
        let b:ycm_installed = 1
    endif


    if b:ycm_installed==0 && b:deoplete_installed==0
        " completion for python
        Plug 'davidhalter/jedi-vim'
    endif

    if b:neomake_installed==0
        " Syntaxis check
        Plug 'vim-syntastic/syntastic'
    endif

else
" Snippets without python interface
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
endif

" completion without ycm
if b:ycm_installed==0 && b:deoplete_installed==0
    Plug 'ervandew/supertab'
    if has("lua")
        Plug 'Shougo/neocomplete.vim'
    else
        Plug 'roxma/SimpleAutoComplPop'
    endif
endif

" Initialize plugin system
call plug#end()

filetype plugin indent on

execute 'source '.fnameescape(g:os_editor.'global.vim')
execute 'source '.fnameescape(g:os_editor.'plugins.vim')

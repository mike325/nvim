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
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################


" Improve compatibility between Unix and DOS platfomrs {{{

let g:base_path = ""

if has("nvim")
    if has("win32") || has("win64")
        let g:base_path = substitute( expand($USERPROFILE), "\\", "/", "g" ) . '/AppData/Local/nvim/'
    else
        let g:base_path = expand($HOME) . '/.config/nvim/'
    endif
elseif has("win32") || has("win64")
    let g:base_path =  substitute( expand($USERPROFILE), "\\", "/", "g" ) . '/vimfiles/'
else
    let g:base_path = expand($HOME) . '/.vim/'
endif

" Better compatibility with Unix paths in DOS systems
if exists("+shellslash")
    set shellslash
endif

" }}} END Improve compatibility between Unix and DOS platfomrs

function! s:SetIgnorePatterns() " Create Ignore rules {{{
    " Files and dirs we want to ignore in searches and plugins
    " The *.  and */patter/* will be add in the add after
    if !exists("g:ignores")
        let g:ignores = {
                    \   "bin": [ "bin", "exe", "dat",],
                    \   "vcs": [ "hg", "svn", "git",],
                    \   "compile" : ["obj", "class", "pyc", "o", "dll", "a", "moc",],
                    \   "tmp_dirs": [ "trash", "tmp", "__pycache__", "ropeproject"],
                    \   "vim_dirs": [ "backup", "swap", "sessions", "cache", "undos",],
                    \   "tmp_file" : ["swp", "bk",],
                    \   "docs": ["docx", "doc", "xls", "xlsx", "odt", "ppt", "pptx", "pdf",],
                    \   "image": ["jpg", "jpeg", "png", "gif", "raw"],
                    \   "video": ["mp4", "mpeg", "avi", "mkv", "3gp"],
                    \   "logs": ["log",],
                    \   "compress": ["zip", "tar", "rar", "7z",],
                    \   "full_name_files": ["tags", "cscope", "shada", "viminfo", "COMMIT_EDITMSG"],
                    \}
    endif

    if !exists( "g:ignore_patterns" )
        let g:ignore_patterns = {
                    \   "git" : "",
                    \   "ag" : "",
                    \   "find" : "",
                    \   "grep" : "",
                    \   "dir" : "",
                    \}
    endif

    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore logs here
        if l:ignore_type == "logs" || l:ignore_type == "bin"
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ""

            if l:ignore_type == "vcs"
                let l:ignore_pattern = "." . l:item . "/*"
            elseif l:ignore_type =~? "_dirs"
                let l:ignore_pattern = l:item . "/*"
            elseif l:ignore_type != "full_name_files"
                let l:ignore_pattern = "*." . l:item
            else
                let l:ignore_pattern = l:item
            endif

            let g:ignore_patterns.git   .= ' -x "' . l:ignore_pattern . '" '
            let g:ignore_patterns.ag    .= ' --ignore "' . l:ignore_pattern . '" '

            if l:ignore_type == "vcs" || l:ignore_type =~? "_dirs"
                let g:ignore_patterns.grep  .= ' --exclude-dir "' . l:ignore_pattern . '" '
                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
            else
                let g:ignore_patterns.grep  .= ' --exclude "' . l:ignore_pattern . '" '
                let g:ignore_patterns.find  .= ' ! -iname "' . l:ignore_pattern . '" '
            endif
            " TODO: Make this crap work in Windows
            " let g:ignore_patterns.dir  .= ' '

            " Add both versions, normal and hidden versions
            if l:ignore_type =~? "_dirs"
                let l:ignore_pattern = "." . l:item . "/*"

                let g:ignore_patterns.git   .= ' -x "' . l:ignore_pattern . '" '
                let g:ignore_patterns.ag    .= ' --ignore "' . l:ignore_pattern . '" '
                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
                let g:ignore_patterns.grep  .= ' --exclude-dir "' . l:ignore_pattern . '" '
                " TODO: Make this crap work in Windows
                " let g:ignore_patterns.dir  .= ' '
            endif
        endfor
    endfor

    " Clean settings before assign the ignore stuff, just lazy stuff
    execute "set wildignore="
    execute "set backupskip="

    " Set system ignores and skips
    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore vcs here
        if l:ignore_type == "vcs"
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ""

            if l:ignore_type =~? "_dirs"
                " Add both versions, normal and hidden
                let l:ignore_pattern = "*/" . l:item . "/*,*/." . l:item . "/*"
            elseif l:ignore_type != "full_name_files"
                let l:ignore_pattern = "*." . l:item
            else
                let l:ignore_pattern = l:item
            endif

            " I don't want to ignore logs or sessions files but I don't want
            " to backup them
            if l:ignore_type != "logs" && l:item != "sessions"
                execute "set wildignore+=" . fnameescape(l:ignore_pattern)
            endif

            execute "set backupskip+=" . fnameescape(l:ignore_pattern)
        endfor
    endfor

endfunction " }}} END Create Ignore rules

function! s:InitConfigs() " Vim's InitConfig {{{
    " Hidden path in `g:base_path` with all generated files
    if !exists("g:parent_dir")
        let g:parent_dir = g:base_path . ".resources/"
    endif

    if !exists("g:dirpaths")
        let g:dirpaths = {
                    \   "backup" : "backupdir",
                    \   "swap" : "directory",
                    \   "undo" : "undodir",
                    \   "cache" : "",
                    \   "sessions" : "",
                    \}
    endif

    " Better backup, swap and undos storage
    set backup   " make backup files
    set undofile " persistent undos - undo after you re-open the file

    " Config all
    for [l:dirname, l:dir_setting] in items(g:dirpaths)
        if exists("*mkdir")
            if !isdirectory(fnameescape( g:parent_dir . l:dirname ))
                call mkdir(fnameescape( g:parent_dir . l:dirname ), "p")
            endif

            if l:dir_setting != ""
                execute "set " . l:dir_setting . "=" . fnameescape(g:parent_dir . l:dirname)
            endif
        else
            echoerr "The current dir " . fnameescape(g:parent_dir . l:dirname) . " could not be created"
        endif
    endfor

    let l:persistent_settings = "viminfo"
    if has("nvim")
        let l:persistent_settings = "shada"
    endif

    " Remember things between sessions
    " !        + When included, save and restore global variables that start
    "            with an uppercase letter, and don't contain a lowercase letter.
    " 'n       + Marks will be remembered for the last 'n' files you edited.
    " <n       + Contents of registers (up to 'n' lines each) will be remembered.
    " sn       + Items with contents occupying more then 'n' KiB are skipped.
    " :n       + Save 'n' Command-line history entries
    " n/info   + The name of the file to use is "/info".
    " no /     + Since '/' is not specified, the default will be used, that is,
    "            save all of the search history, and also the previous search and
    "            substitute patterns.
    " no %     + The buffer list will not be saved nor read back.
    " h        + 'hlsearch' highlighting will not be restored.
    execute "set " . l:persistent_settings . "=!,'100,<500,:500,s100,h"
    execute "set " . l:persistent_settings . "+=n" . fnameescape(g:parent_dir . l:persistent_settings)
endfunction " }}} END Vim's InitConfig

" Initialize plugins {{{

call s:SetIgnorePatterns()
call s:InitConfigs()

let mapleader="\<Space>"

call plug#begin(g:base_path.'plugged')

" ####### Colorschemes {{{

Plug 'morhetz/gruvbox'
Plug 'sickill/vim-monokai'
Plug 'nanotech/jellybeans.vim'
Plug 'whatyouhide/vim-gotham'
Plug 'joshdick/onedark.vim'

" }}} END Colorschemes

" ####### Syntax {{{

Plug 'ekalinin/Dockerfile.vim'
Plug 'elzr/vim-json'
Plug 'tbastos/vim-lua'
Plug 'octol/vim-cpp-enhanced-highlight'
Plug 'peterhoeg/vim-qml'
Plug 'plasticboy/vim-markdown'
Plug 'bjoernd/vim-syntax-simics'

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
if ( has("python") || has("python3") ) " Python base completions {{{

    if has("nvim") || ( v:version >= 800 ) || ( v:version >= 704 )
        " Only works with JDK8!!!
        Plug 'artur-shaik/vim-javacomplete2'
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

    elseif (has("unix") || ((has("win32") || has("win64")) && executable("msbuild"))) &&
        \  (has("nvim") || (v:version >= 800) || (v:version == 704 && has("patch143")) )

        function! BuildYCM(info)
            if a:info.status == 'installed' || a:info.force
                " !./install.py --all
                " !./install.py --gocode-completer --tern-completer --clang-completer --omnisharp-completer
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

        " Install ycm if Neovim/vim 8/Vim 7.143 is running on unix or
        " If it is running on windows with Neovim/Vim 8/Vim 7.143 and ms C compiler
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }

        " C/C++ project generator
        Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
        let b:ycm_installed = 1
    elseif ( v:version >= 800 ) || has("nvim")
        " Test new completion Async framework that require python and vim 8 or
        " Neovim (without python3)
        Plug 'maralla/completor.vim'
        let b:completor = 1
    endif


    if b:ycm_installed==0 && b:deoplete_installed==0 && b:completor==0
        " Completion for python without engines
        Plug 'davidhalter/jedi-vim'
    endif

endif " }}} END Python base completions

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
    Plug 'fatih/vim-go'
endif

if has("python") || has("python3")
    Plug 'python-mode/python-mode'
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

" Handy stuff to navigate
Plug 'tpope/vim-unimpaired'

" Visualize undo tree
if has("python") || has("python3")
    Plug 'sjl/gundo.vim'
endif

" Unix commands
if has("unix")
    Plug 'tpope/vim-eunuch'
endif

" Better defaults for Vim
if !has("nvim")
    Plug 'tpope/vim-sensible'
endif

" }}} END Misc

" Initialize plugin system
call plug#end()

filetype plugin indent on

" }}} END Initialize plugins

" Load general configurations (key mappings and autocommands)
" execute 'source '.fnameescape(g:base_path.'global.vim')
"
" Load plugins configurations
" execute 'source '.fnameescape(g:base_path.'plugins.vim')

" Load special host configurations
" if filereadable(expand(fnameescape(g:base_path.'extras.vim')))
"     execute 'source '.fnameescape(g:base_path.'extras.vim')
" endif

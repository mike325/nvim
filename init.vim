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

" Windows wrapper
function! WINDOWS()
    return (has('win16') || has('win32') || has('win64'))
endfunction

" Check an specific version of python (empty==2)
function! PYTHON(version)
    if a:version ==# 'any' || a:version ==# ''
        return (has('python') || has('python3'))
    elseif a:version ==# '3'
        return has('python3')
    elseif a:version ==# '2'
        return has('python')
    endif
endfunction

" Check whether or not we have async support
function! ASYNC()
    return (has('nvim') || ((v:version >= 800 && has('patch-8.0.0027')) ||
                         \  (v:version ==# 704 && has('patch1689')) &&
                         \ (has('job') && has('timers') && has('channel')))) ? 1 : 0
endfunction

function! GUI()
    return (has('nvim') && exists('g:GuiLoaded')) || (!has('nvim') && has('gui_running'))
endfunction

if WINDOWS()
    set shell=cmd.exe " sets shell to correct path for cmd.exe
    " Better compatibility with Unix paths in DOS systems
    if exists('+shellslash')
        set shellslash
    endif
endif

" Set the default work dir
let g:base_path = ''
let g:home = ''
if has('nvim')
    if WINDOWS()
        let g:base_path = substitute( expand($USERPROFILE), '\', '/', 'g' ) . '/AppData/Local/nvim/'
        let g:home = substitute( expand($USERPROFILE), '\', '/', 'g' )
    else
        " TODO: Check $XDG_DATA_HOME
        let g:base_path = expand($HOME) . '/.config/nvim/'
        let g:home = expand($HOME)
    endif
elseif WINDOWS()
    " if $USERPROFILE and ~ expansions are different, then gVim may be running as portable
    let g:home = substitute( expand($USERPROFILE), '\', '/', 'g' )
    if  substitute( expand($USERPROFILE), '\', '/', 'g' ) ==# substitute( expand('~'), '\', '/', 'g' )
        let g:base_path =  substitute( expand($USERPROFILE), '\', '/', 'g' ) . '/vimfiles/'
    else
        let g:base_path =  substitute( expand('~'), '\', '/', 'g' ) . '/vimfiles/'
    endif
else
    let g:base_path = expand($HOME) . '/.vim/'
    let g:home = expand($HOME)
endif

" }}} END Improve compatibility between Unix and DOS platfomrs

function! s:SetIgnorePatterns() " Create Ignore rules {{{
    " Files and dirs we want to ignore in searches and plugins
    " The *.  and */patter/* will be add after

    let g:ignore_patterns = {
                \   'git' : '',
                \   'ag' : '',
                \   'find' : '',
                \   'grep' : '',
                \   'dir' : '',
                \   'findstr' : '',
                \}

    let g:ignores = {
                \   'bin': [ 'exe', 'dat',],
                \   'vcs': [ 'hg', 'svn', 'git',],
                \   'compile' : ['obj', 'class', 'pyc', 'o', 'dll', 'a', 'moc',],
                \   'tmp_dirs': [ 'trash', 'tmp', '__pycache__', 'ropeproject'],
                \   'vim_dirs': [ 'backup', 'swap', 'sessions', 'cache', 'undos',],
                \   'tmp_file' : ['swp', 'bk',],
                \   'docs': ['docx', 'doc', 'xls', 'xlsx', 'odt', 'ppt', 'pptx', 'pdf',],
                \   'image': ['jpg', 'jpeg', 'png', 'gif', 'raw'],
                \   'video': ['mp4', 'mpeg', 'avi', 'mkv', '3gp'],
                \   'logs': ['log',],
                \   'compress': ['zip', 'tar', 'rar', '7z',],
                \   'full_name_files': ['tags', 'cscope', 'shada', 'viminfo', 'COMMIT_EDITMSG'],
                \}

    if filereadable(g:home . '/.config/git/ignore')
        let g:ignore_patterns.grep .= ' --exclude-from=' . g:home . '/.config/git/ignore'
        let g:ignore_patterns.ag .= ' --path-to-ignore ' . g:home . '/.config/git/ignore'
    endif

    for  l:element in g:ignores.vcs
        let g:ignore_patterns.grep .= ' --exclude-dir="*.' . l:element . '" '
    endfor

    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore logs here
        if l:ignore_type ==# 'logs' || l:ignore_type ==# 'bin'
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ''

            if l:ignore_type ==# 'vcs'
                let l:ignore_pattern = '.' . l:item . '/*'
            elseif l:ignore_type =~? '_dirs'
                let l:ignore_pattern = l:item . '/*'
            elseif l:ignore_type !=# 'full_name_files'
                let l:ignore_pattern = '*.' . l:item
            else
                let l:ignore_pattern = l:item
            endif

            " let g:ignore_patterns.findstr .= ' /c:' . substitute(l:ignore_pattern, "\(\/\|\*\)", "" ,"g") . ' '

            if l:ignore_type ==# 'vcs' || l:ignore_type =~? '_dirs'
                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
            else
                let g:ignore_patterns.find  .= ' ! -iname "' . l:ignore_pattern . '" '
            endif
            " TODO: Make this crap work in Windows
            " let g:ignore_patterns.dir  .= ' '

            " Add both versions, normal and hidden versions
            if l:ignore_type =~? '_dirs'
                let l:ignore_pattern = '.' . l:item . '/*'

                let g:ignore_patterns.find  .= ' ! -path "*/' . l:ignore_pattern . '" '
                " TODO: Make this crap work in Windows
                " let g:ignore_patterns.findstr .= ' /c: "' . l:ignore_pattern . '" '
                " let g:ignore_patterns.dir  .= ' '
            endif
        endfor
    endfor

    " Clean settings before assign the ignore stuff, just lazy stuff
    execute 'set wildignore='
    execute 'set backupskip='
    " set suffixes=.bak,~,.swp,.o,.info,.aux,.log,.dvi,.bbl,.blg,.brf,.cb,.ind,.idx,.ilg,.inx,.out,.toc,.png,.jpg

    " Set system ignores and skips
    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore vcs here
        if l:ignore_type ==# 'vcs'
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = ''

            if l:ignore_type =~? '_dirs'
                " Add both versions, normal and hidden
                let l:ignore_pattern = '*/' . l:item . '/*,*/.' . l:item . '/*'
            elseif l:ignore_type !=# 'full_name_files'
                let l:ignore_pattern = '*.' . l:item
            else
                let l:ignore_pattern = l:item
            endif

            " I don't want to ignore logs or sessions files but I don't want
            " to backup them
            if l:ignore_type !=# 'logs' && l:item !=# 'sessions'
                execute 'set wildignore+=' . fnameescape(l:ignore_pattern)
            endif

            execute 'set backupskip+=' . fnameescape(l:ignore_pattern)
        endfor
    endfor

endfunction " }}} END Create Ignore rules

function! s:InitConfigs() " Vim's InitConfig {{{
    " Hidden path in `g:base_path` with all generated files
    if !exists('g:parent_dir')
        let g:parent_dir = g:base_path . '.resources/'
    endif

    if !exists('g:dirpaths')
        let g:dirpaths = {
                    \   'backup' : 'backupdir',
                    \   'swap' : 'directory',
                    \   'undo' : 'undodir',
                    \   'cache' : '',
                    \   'sessions' : '',
                    \}
    endif

    " Better backup, swap and undos storage
    set backup   " make backup files
    if exists('+undofile')
        set undofile " persistent undos - undo after you re-open the file
    endif

    " Config all
    for [l:dirname, l:dir_setting] in items(g:dirpaths)
        if exists('*mkdir')
            if !isdirectory(fnameescape( g:parent_dir . l:dirname ))
                call mkdir(fnameescape( g:parent_dir . l:dirname ), 'p')
            endif

            if l:dir_setting !=# '' && exists('+' . l:dir_setting)
                execute 'set ' . l:dir_setting . '=' . fnameescape(g:parent_dir . l:dirname)
            endif
        else
            " echoerr "The current dir " . fnameescape(g:parent_dir . l:dirname) . " could not be created"
            " TODO: Display errors/status in the start screen
            " Just a placeholder
        endif
    endfor

    let l:persistent_settings = (has('nvim')) ? 'shada' : 'viminfo'

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
    execute 'set ' . l:persistent_settings . "=!,'100,<500,:500,s100,h"
    execute 'set ' . l:persistent_settings . '+=n' . fnameescape(g:parent_dir . l:persistent_settings)
endfunction " }}} END Vim's InitConfig


if ASYNC()
    function! s:python_setup(python)
        let l:major = a:python[0]
        let l:minor = a:python[1]
        " let l:patch = l:python[2]
        if WINDOWS()
            let l:candidates = [
                        \ 'c:/python'.l:major.l:minor,
                        \ 'c:/python/'.l:major.l:minor,
                        \ 'c:/python/python'.l:major.l:minor,
                        \ 'c:/python_'.l:major.l:minor,
                        \ 'c:/python/python_'.l:major.l:minor,
                        \]
            for pydir in l:candidates
                if isdirectory(fnameescape(pydir))
                    return pydir
                endif
            endfor
        elseif executable('python'.l:major.'.'.l:minor)
            return 'python'.l:major.'.'.l:minor
        endif
        return ''
    endfunction

    let s:python = ['2', '7']
    if s:python_setup(s:python) !=# ''
        if exists('g:loaded_python_provider')
            unlet g:loaded_python_provider
        endif
        let g:python_host_prog = s:python_setup(s:python)
        if WINDOWS()
            let g:python_host_prog .=  '/python'
        endif
    endif

    for s:minor in ['8', '7', '6', '5', '4']
        let s:python = ['3', s:minor]
        if s:python_setup(s:python) !=# ''
            if exists('g:loaded_python3_provider')
                unlet g:loaded_python3_provider
            endif
            let g:python3_host_prog = s:python_setup(s:python)
            if WINDOWS()
                let g:python3_host_prog .=  '/python'
            endif
            break
        endif
    endfor

endif


" Initialize plugins {{{

try
    call s:SetIgnorePatterns()
    call s:InitConfigs()
catch E117
    " TODO:
endtry

let mapleader="\<Space>"

" If there are no plugins available and we don't have git
" fallback to minimal mode
if !executable('git') && !isdirectory(fnameescape(g:base_path.'plugged'))
    let g:minimal = 1
endif

" TODO: Should minimal include lightweight tpope's plugins ?
" TODO: Check for $TERM before load some configurations
if !exists('g:minimal')

    try
        call plug#begin(g:base_path.'plugged')
    catch
        " Fallback if we fail to init Plug
        if !has('nvim') && v:version >= 800
            packadd! matchit
        elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
            runtime! macros/matchit.vim
        endif
        filetype plugin indent on
        finish
    endtry

    if isdirectory(fnameescape(g:base_path.'config'))
        Plug fnameescape(g:base_path.'config')
    endif

    if isdirectory(fnameescape(g:base_path.'host'))
        Plug fnameescape(g:base_path.'host')
    endif

    " ####### Colorschemes {{{

    Plug 'morhetz/gruvbox'
    Plug 'sickill/vim-monokai'
    Plug 'nanotech/jellybeans.vim'
    Plug 'whatyouhide/vim-gotham'
    Plug 'joshdick/onedark.vim'
    Plug 'ayu-theme/ayu-vim'

    " }}} END Colorschemes

    " ####### Syntax {{{

    Plug 'ekalinin/Dockerfile.vim', {'for': 'dockerfile'}
    Plug 'elzr/vim-json', {'for': 'json'}
    Plug 'tbastos/vim-lua', {'for': 'lua'}
    Plug 'octol/vim-cpp-enhanced-highlight', {'for': 'cpp'}
    Plug 'peterhoeg/vim-qml', {'for': 'qml'}
    " Plug 'plasticboy/vim-markdown', {'for': 'markdown'}
    Plug 'tpope/vim-markdown', {'for': 'markdown'}
    Plug 'bjoernd/vim-syntax-simics', {'for': 'simics'}
    Plug 'kurayama/systemd-vim-syntax', {'for': 'systemd'}
    Plug 'mhinz/vim-nginx', {'for': 'nginx'}

    " }}} END Syntax

    " ####### Project base {{{

    Plug 'tpope/vim-projectionist'

    Plug 'mhinz/vim-grepper', { 'on': ['Grepper', '<plug>(GrepperOperator)'] }

    Plug 'xolox/vim-misc'
    Plug 'xolox/vim-session', {'on': ['OpenSession', 'SaveSession', 'DeleteSession']}


    " Project standardize file settings
    " Plug 'editorconfig/editorconfig-vim'

    " Easy alignment
    " Plug 'godlygeek/tabular'

    " Easy alignment with motions and text objects
    Plug 'tommcdo/vim-lion'

    " Have some problmes with vinager in windows
    if !WINDOWS()
        Plug 'tpope/vim-vinegar'
    " else
    "     Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTree', 'NERDTreeToggle' ] }
    "     " Plug 'Xuyuanp/nerdtree-git-plugin', { 'on': [ 'NERDTreeToggle' ] }
    endif

    " if executable('ctags')
    "     " Simple view of Tags using ctags
    "     Plug 'majutsushi/tagbar', {'on': ['Tagbar', 'TagbarToggle', 'TagbarOpen']}
    " endif

    " if executable('gtags") && has("cscope')
    "     " Great tag management
    "     Plug 'jsfaint/gen_tags.vim'
    " endif

    " Syntax check
    if PYTHON('any')
        if ASYNC()
            Plug 'neomake/neomake'
        else
            Plug 'vim-syntastic/syntastic'
        endif
    endif

    Plug 'ctrlpvim/ctrlp.vim'
    if has('unix') && executable('git')
        Plug 'jasoncodes/ctrlp-modified.vim'
    endif

    if PYTHON('any')
        " Fast and 'easy' to compile C CtrlP matcher
        if (executable('gcc') || executable('clang')) && empty($NO_PYTHON_DEV) && !WINDOWS()
            " Windows must have msbuild compiler to work, temporally disabled
            function! BuildCtrlPMatcher(info)
                if a:info.status ==# 'installed' || a:info.force
                    if WINDOWS()
                        !./install_windows.bat
                    else
                        !./install.sh
                    endif
                endif
            endfunction

            Plug 'JazzCore/ctrlp-cmatcher', { 'do': function('BuildCtrlPMatcher')}
        else
            " Fast matcher for ctrlp
            Plug 'FelikZ/ctrlp-py-matcher'
        endif

        " The fastes matcher (as far as I know) but way more complicated to setup
        " Plug 'nixprime/cpsm'

    endif

    " }}} END Project base

    " ####### Git integration {{{

    " Plug 'airblade/vim-gitgutter'
    Plug 'mhinz/vim-signify'

    if executable('git')
        Plug 'tpope/vim-fugitive'
        Plug 'rhysd/committia.vim'
        Plug 'gregsexton/gitv', {'on': ['Gitv']}
    endif
    " }}} END Git integration

    " ####### Status bar {{{

    " Vim airline is available for >= Vim 7.4
    if v:version > 703 || has('nvim')
        " TODO: Airline seems to take 2/3 of the startuptime
        "       May look to lighter alternatives
        Plug 'vim-airline/vim-airline'
        Plug 'vim-airline/vim-airline-themes'
        " Plug 'enricobacis/vim-airline-clock'
    endif

    " }}} END Status bar

    " ####### Completions {{{

    Plug 'Raimondi/delimitMate'
    Plug 'tpope/vim-abolish'
    Plug 'honza/vim-snippets'

    if PYTHON('any') && (has('nvim') || (v:version >= 704))
        Plug 'SirVer/ultisnips'
    else
        Plug 'MarcWeber/vim-addon-mw-utils'
        Plug 'tomtom/tlib_vim'
        Plug 'garbas/vim-snipmate'
    endif

    let s:ycm_installed = 0
    let s:deoplete_installed = 0
    let s:completor = 0

    " This env var allow us to know if the python version has the dev libs
    if empty($NO_PYTHON_DEV)
        if PYTHON('any') " Python base completions {{{

            " function! BuildOmniSharp(info)
            "     if a:info.status == 'installed' || a:info.force
            "         if WINDOWS()
            "             !cd server && msbuild
            "         else
            "             !cd server && xbuild
            "         endif
            "     endif
            " endfunction

            " Plug 'OmniSharp/omnisharp-vim', { 'do': function('BuildOmniSharp') }

            " Awesome Async completion engine for Neovim
            " if ASYNC() && PYTHON('3')
            if has('nvim') && PYTHON('3') && empty($YCM)

                " " TODO: There's no package check
                " if !has('nvim')
                "     Plug 'roxma/nvim-yarp'
                "     Plug 'roxma/vim-hug-neovim-rpc'
                "     set pyxversion=3
                " endif

                function! DeopletePostSetup(info)
                    if has('nvim')
                        UpdateRemotePlugins
                    endif
                endfunction

                Plug 'Shougo/deoplete.nvim', { 'do': function('DeopletePostSetup')}

                " Python completion
                Plug 'zchee/deoplete-jedi'
                Plug 'Shougo/neco-vim'

                " C/C++ completion base on clang compiler
                if executable('clang')
                    if WINDOWS()
                        " A bit faster C/C++ completion
                        Plug 'tweekmonster/deoplete-clang2'
                    else
                        " NOTE: Doesn't support windows
                        Plug 'zchee/deoplete-clang'
                        " Plug 'Shougo/neoinclude.vim'
                    endif
                endif

                " Go completion
                " TODO: Check Go completion in Windows
                if executable('go') && executable('make')

                    function! GoCompletion(info)
                        if !executable('gocode')
                            if WINDOWS()
                                !go get -u -ldflags -H=windowsgui github.com/nsf/gocode
                            else
                                !go get -u github.com/nsf/gocode
                            endif
                        endif
                        make
                    endfunction

                    Plug 'zchee/deoplete-go', { 'do':function('GoCompletion')}
                endif

                " if executable('php')
                "     Plug 'padawan-php/deoplete-padawan', { 'do': 'composer install' }
                " endif

                " JavaScript completion
                if executable('ternjs')
                    Plug 'carlitux/deoplete-ternjs'
                endif

                let s:deoplete_installed = 1

            elseif ASYNC() && executable('cmake') && (( has('unix') && ( executable('gcc')  || executable('clang') )) ||
                        \ (WINDOWS() && executable('msbuild') && executable('7z')))

                function! BuildYCM(info)
                    if a:info.status ==# 'installed' || a:info.force
                        " !./install.py --all

                        " Since YCM download libclang there's no need to have clang install
                        " FIX: ArchLinux users should run this first
                        "  ~# sudo ln -s /lib64/libtinfo.so.6.0 /lib64/libtinfo.so.5
                        "       or use --system-clang
                        " https://github.com/Valloric/YouCompleteMe/issues/778#issuecomment-211452969
                        let l:code_completion = ' --clang-completer'

                        if executable('go') && (!empty($GOROOT))
                            let l:code_completion .= ' --gocode-completer'
                        endif

                        if executable('mono')
                            let l:code_completion .= ' --omnisharp-completer'
                        endif

                        if executable('racer') && executable('cargo')
                            let l:code_completion .= ' --rust-completer'
                        endif

                        if executable('npm') && executable('node')
                            let l:code_completion .= ' --js-completer'
                        endif

                        " TODO: Can't test in windows
                        if !WINDOWS() && executable('java')
                            " JDK8 must be installed
                            let l:java = system('java -version')
                            if l:java =~# '^java.*"1\.8.*"'
                                let l:code_completion .= ' --java-completer'
                            endif
                        endif

                        if WINDOWS()
                            execute '!python ./install.py ' . l:code_completion
                        elseif executable('python3')
                            ' Force python3
                            execute '!python3 ./install.py ' . l:code_completion
                        else
                            execute '!./install.py ' . l:code_completion
                        endif

                    endif
                endfunction

                if WINDOWS()
                    " Don't fucking update YCM in Windows
                    Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') , 'frozen' : 1,}
                else
                    Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
                endif

                " C/C++ project generator
                Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
                let s:ycm_installed = 1
            elseif ASYNC()
                " Test new completion Async framework that require python and vim 8 or
                " Neovim (without python3)
                Plug 'maralla/completor.vim'
                let s:completor = 1
            endif

            " if ( has('nvim') || ( v:version >= 800 ) || ( v:version >= 704 ) ) &&
            "             \ ( s:ycm_installed==1 || s:deoplete_installed==1 )
            "     " Only works with JDK8!!!
            "     Plug 'artur-shaik/vim-javacomplete2'
            " endif

            if s:ycm_installed==0 && s:deoplete_installed==0
                " Completion for python without engines
                Plug 'davidhalter/jedi-vim'

                " Plug 'Rip-Rip/clang_complete'
            endif

        endif " }}} END Python base completions
    endif

    " Vim clang does not require python
    if executable('clang') && s:ycm_installed==0 && s:deoplete_installed==0
        Plug 'justmao945/vim-clang'
    endif

    " completion without python completion engines ( ycm, deoplete or completer )
    if s:ycm_installed==0 && s:deoplete_installed==0 && s:completor==0
        " Neovim does not support Lua plugins yet
        if has('lua') && !has('nvim') && (v:version >= 704)
            Plug 'Shougo/neocomplete.vim'
        elseif (v:version >= 703) || has('nvim')
            " Plug 'Shougo/neocomplcache.vim'
            Plug 'roxma/SimpleAutoComplPop'

            " Supertab install issue
            " https://github.com/ervandew/supertab/issues/185
            if !has('nvim') && (v:version < 800)
                Plug 'ervandew/supertab'
            endif
        endif
    endif

    " }}} END Completions

    " ####### Languages {{{

    Plug 'tpope/vim-endwise'
    " Plug 'fidian/hexmode'

    if executable('go') && ASYNC()
        Plug 'fatih/vim-go'
    endif

    " if executable('luac") || executable("lualint')
    Plug 'xolox/vim-lua-ftplugin'
    " endif

    " Easy comments
    " TODO check other comment plugins with motions
    Plug 'tomtom/tcomment_vim'
    " Plug 'scrooloose/nerdcommenter'

    " if (has('nvim') || (v:version >= 704))
    "     Plug 'lervag/vimtex'
    " endif

    " }}} END Languages

    " ####### Text objects, Motions and Text manipulation {{{

    if (has('nvim') || (v:version >= 704))
        " Plug 'sickill/vim-pasta'

        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-line'
        Plug 'glts/vim-textobj-comment'
        Plug 'michaeljsmith/vim-indent-object'
        " Plug 'jceb/vim-textobj-uri'
        " Plug 'whatyouhide/vim-textobj-xmlattr'

        " NOTE: cool text object BUT my fat fingers keep presing 'w' instead of 'e'
        "       useful with formatprg
        Plug 'kana/vim-textobj-entire'

        " TODO: Solve conflict with comment plugin
        " Plug 'coderifous/textobj-word-column.vim'
    endif

    " JSON text objects
    Plug 'tpope/vim-jdaddy'

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

    " Override default [i,]i,[I,]I,[d,]d,[D,]D to load the results in the quickfix
    Plug 'romainl/vim-qlist'

    " Move with indentation
    " NOTE: Deprecated in favor of unimpaired plugin
    " Plug 'matze/vim-move'

    " Easy change text
    " Plug 'AndrewRadev/switch.vim'

    " Simple Join/Split operators
    " Plug 'AndrewRadev/splitjoin.vim'

    " Expand visual regions
    " Plug 'terryma/vim-expand-region'

    " Display indention
    Plug 'Yggdroot/indentLine'

    " Change buffer position in the current layout
    Plug 'wesQ3/vim-windowswap'

    " Handy stuff to navigate
    Plug 'tpope/vim-unimpaired'

    " Show parameters of the current function
    Plug 'Shougo/echodoc.vim'

    " TODO: check characters display
    " Plug 'dodie/vim-disapprove-deep-indentation'

    " Better defaults for Vim
    Plug 'tpope/vim-sensible'

    " Improve Path searching
    Plug 'tpope/vim-apathy'

    " Automatically clears search highlight when cursor is moved
    Plug 'junegunn/vim-slash'

    " Print the number of the available buffer matches
    Plug 'henrik/vim-indexed-search'

    " Database management
    Plug 'tpope/vim-dadbod'

    " Useful to get the console output in Vim (since :terminal is not enable yet)
    if !ASYNC() && !exists('+terminal')
        Plug 'tpope/vim-dispatch'
    endif

    " " Visualize undo tree
    " if PYTHON('any')
    "     Plug 'sjl/gundo.vim', {'on': ['GundoShow', 'GundoToggle']}
    " endif

    " Unix commands
    if has('unix')
        Plug 'tpope/vim-eunuch'
    endif

    if has('nvim')
        Plug 'vigemus/iron.nvim', { 'do': ':UpdateRemotePlugins' }
    endif

    " }}} END Misc

    " Initialize plugin system
    call plug#end()

else
    if !has('nvim') && v:version >= 800
        packadd! matchit
    elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
        runtime! macros/matchit.vim
    endif
endif

filetype plugin indent on

" }}} END Initialize plugins

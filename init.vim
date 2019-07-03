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

let g:mapleader="\<Space>"

if os#name('windows')

    " I'm tired of trying to setup powershell as windows shell, so just gonna
    " leave this for a while
    set shell=cmd.exe

    " Better compatibility with Unix paths in DOS systems
    if exists('+shellslash')
        set shellslash
    endif

    let &runtimepath = tr(&runtimepath, '\', '/')

endif

" }}} END Improve compatibility between Unix and DOS platfomrs

" Initialize plugins {{{

" If there are no plugins available and we don't have git
" fallback to minimal mode
if (!executable('git') && !isdirectory(fnameescape(vars#basedir().'/plugged'))) || v:progname ==# 'vi'
    let g:minimal = 1
endif

" TODO: Should minimal include lightweight tpope's plugins ?
call set#initconfigs()

if !exists('g:minimal') || g:minimal == 0

    try
        if exists('*execute')
            call execute('set runtimepath+=' . expand(vars#basedir() . '/plug/'))
        else
            execute 'set runtimepath+=' . expand(vars#basedir() . '/plug/')
        endif
        call plug#begin(vars#basedir().'/plugged')
    catch /E\(117\|492\)/
        " Fallback if we fail to init Plug
        if !has('nvim') && v:version >= 800
            packadd! matchit
        elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
            runtime! macros/matchit.vim
        endif
        filetype plugin indent on
        if exists('+syntax')
            syntax on      " Switch on syntax highlighting
        endif
        finish
    endtry

    " ####### Colorschemes {{{

    " Plug 'morhetz/gruvbox'
    " Plug 'sickill/vim-monokai'
    " Plug 'nanotech/jellybeans.vim'
    " Plug 'whatyouhide/vim-gotham'
    Plug 'joshdick/onedark.vim'
    Plug 'ayu-theme/ayu-vim'

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

    " ####### GUI settings {{{

    " ####### Project base {{{

    Plug 'tpope/vim-projectionist'

    " Plug 'xolox/vim-misc'
    " Plug 'xolox/vim-session', {'on': ['OpenSession', 'SaveSession', 'DeleteSession']}


    " Project standardize file settings
    " Plug 'editorconfig/editorconfig-vim'

    " Easy alignment
    " Plug 'godlygeek/tabular'

    " Easy alignment with motions and text objects
    Plug 'tommcdo/vim-lion'

    " Have some problmes with vinager in windows
    if !os#name('windows')
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
        " These are the only VCS I care, if none is installed, then
        " skip this plugin
        Plug 'mhinz/vim-signify'
    endif

    if executable('git')
        Plug 'tpope/vim-fugitive'
        if executable('hub')
            Plug 'tpope/vim-rhubarb'
        endif
        " Plug 'jreybert/vimagit', {'on': ['Magit', 'MagitOnly']}
        " Plug 'sodapopcan/vim-twiggy', {'on': ['Twiggy']}
        " Plug 'gregsexton/gitv', {'on': ['Gitv']}
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
        " Plug 'enricobacis/vim-airline-clock'
    endif

    " }}} END Status bar

    " ####### Completions {{{

    Plug 'Raimondi/delimitMate'
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

    let s:ycm_installed = 0
    let s:deoplete_installed = 0
    let s:completor = 0

    " This env var allow us to know if the python version has the dev libs
    if empty($NO_PYTHON_DEV) && has#python() " Python base completions {{{

        " Plug 'OmniSharp/omnisharp-vim', { 'do': function('plugin#omnisharp') }

        " Awesome has#async completion engine for Neovim
        " if has#async() && has#python('3')
        if !empty($YCM) && has#async() && executable('cmake') && (( has('unix') && ( executable('gcc')  || executable('clang') )) ||
                    \ (os#name('windows') && executable('msbuild')))

            Plug 'ycm-core/YouCompleteMe', { 'do': function('plugins#youcompleteme#install') }
            " Plug 'davits/DyeVim'

            " C/C++ project generator
            " Plug 'rdnetto/ycm-generator', { 'branch': 'stable' }
            let s:ycm_installed = 1
        elseif has('nvim-0.2.0') && has#python('3', '4')

            " " TODO: There's no package check
            " if !has('nvim')
            "     Plug 'roxma/nvim-yarp'
            "     Plug 'roxma/vim-hug-neovim-rpc'
            "     set pyxversion=3
            " endif

            if has('nvim-0.3.0') && has#python('3', '6')
                Plug 'Shougo/deoplete.nvim', { 'do': ':silent! UpdateRemotePlugins'}
            else
                Plug 'Shougo/deoplete.nvim', { 'tag': '2.0', 'do': ':silent! UpdateRemotePlugins', 'frozen' : 1}
            endif

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

            " if executable('php')
            "     Plug 'padawan-php/deoplete-padawan', { 'do': 'composer install' }
            " endif

            " JavaScript completion
            if !tools#CheckLanguageServer('javascript') && executable('ternjs')
                Plug 'carlitux/deoplete-ternjs'
            endif

            let s:deoplete_installed = 1
        elseif has#async() && (has('nvim-0.2.0')) || !has('nvim')
            " Test new completion has#async framework that require python and vim 8 or
            " Neovim (without python3)
            if tools#CheckLanguageServer('any')
                Plug 'autozimu/LanguageClient-neovim', {'branch': 'next', 'do': function('plugins#languageclient_neovim#install')}
            endif

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

    " Vim clang does not require python
    if executable('clang') && s:ycm_installed==0 && s:deoplete_installed==0
        Plug 'justmao945/vim-clang'
    endif

    " Completion without python completion engines ( ycm, deoplete or completer )
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

    if executable('go') && has#async()
        Plug 'fatih/vim-go'
    endif

    " Easy comments
    " TODO check other comment plugins with motions
    Plug 'tomtom/tcomment_vim'
    " Plug 'scrooloose/nerdcommenter'

    if (has('nvim') || (v:version >= 704)) && (executable('tex'))
        Plug 'lervag/vimtex'
    endif

    " }}} END Languages

    " ####### Text objects, Motions and Text manipulation {{{

    if (has('nvim') || (v:version >= 704))
        " Plug 'sickill/vim-pasta'

        Plug 'kana/vim-textobj-user'
        Plug 'kana/vim-textobj-line'
        Plug 'glts/vim-textobj-comment'
        Plug 'michaeljsmith/vim-indent-object'
        Plug 'kana/vim-textobj-entire'
        " Plug 'jceb/vim-textobj-uri'
        " Plug 'whatyouhide/vim-textobj-xmlattr'

        " NOTE: cool text object BUT my fat fingers keep presing 'w' instead of 'e'
        "       useful with formatprg

        " TODO: Solve conflict with comment plugin
        " Plug 'coderifous/textobj-word-column.vim'
    endif

    " Register text substitution with motions
    " Plug 'vim-scripts/ReplaceWithRegister'

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

    Plug 'tweekmonster/startuptime.vim', {'on': ['StartupTime']}

    " Better buffer deletions
    Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

    " Visual marks
    " Plug 'kshenoy/vim-signature'

    " Override default [i,]i,[I,]I,[d,]d,[D,]D to load the results in the quickfix
    " Plug 'romainl/vim-qlist'

    " Move with indentation
    " NOTE: Deprecated in favor of unimpaired plugin
    " Plug 'matze/vim-move'

    " Easy change text
    " Plug 'AndrewRadev/switch.vim'

    " Simple Join/Split operators
    " Plug 'AndrewRadev/splitjoin.vim'

    " Expand visual regions
    " Plug 'terryma/vim-expand-region'

    if os#name('windows')
        " NOTE: Urls doesn't work in master branch because vimwiki pass the wrong
        "       variable
        Plug 'vimwiki/vimwiki', {'branch': 'dev'}
    else
        Plug 'vimwiki/vimwiki'
    endif

    " Display indention
    Plug 'Yggdroot/indentLine'

    " Change buffer position in the current layout
    " Plug 'wesQ3/vim-windowswap'

    " Handy stuff to navigate
    Plug 'tpope/vim-unimpaired'

    " Show parameters of the current function
    " Plug 'Shougo/echodoc.vim'

    " TODO: check characters display
    " Plug 'dodie/vim-disapprove-deep-indentation'

    " Better defaults for Vim
    " Plug 'tpope/vim-sensible'

    " Improve Path searching
    Plug 'tpope/vim-apathy'

    " Automatically clears search highlight when cursor is moved
    Plug 'junegunn/vim-slash'

    " Print the number of the available buffer matches
    Plug 'henrik/vim-indexed-search'

    " Database management
    Plug 'tpope/vim-dadbod', {'on': ['DB']}

    " Create a new buffer narrowed with the visual selected area
    " Plug 'chrisbra/NrrwRgn', {'on': ['NR', 'NarrowRegion', 'NW', 'NarrowWindow']}

    " Unix commands
    if has('unix')
        Plug 'tpope/vim-eunuch'
    endif

    if has('nvim')
        Plug 'Vigemus/iron.nvim'
    elseif !has('+terminal')
        " Useful to get the console output in Vim (since :terminal is not enable yet)
        Plug 'tpope/vim-dispatch'
    endif

    " " Visualize undo tree
    " if has#python()
    "     Plug 'sjl/gundo.vim', {'on': ['GundoShow', 'GundoToggle']}
    " endif

    " }}} END Misc

    " Initialize plugin system

    unlet s:ycm_installed
    unlet s:deoplete_installed
    unlet s:completor

    call plug#end()

    function s:Convert2settings(name)
        let l:name = (a:name =~? '[\.\-]') ? substitute(a:name, '[\.\-]', '_', 'g') : a:name
        let l:name = substitute(l:name, '.', '\l\0', 'g')
        return l:name
    endfunction

    let s:available_configs = map(glob(vars#basedir() . '/autoload/plugins/*.vim', 0, 1, 0), 'fnamemodify(v:val, ":t:r")')

    try
        for [s:name, s:data] in items(filter(deepcopy(g:plugs), 'index(s:available_configs, s:Convert2settings(v:key), 0) != -1'))
            " available keys
            "   uri: URL of the repo
            "   dir: Install dir
            "   frozen: is it frozen? (0, 1)
            "   branch: cloned branch
            "   do: Post install function
            "   on: CMD to source plugin
            "   for: FT to source plugin
            let s:func_name = s:Convert2settings(s:name)
            call plugins#{s:func_name}#init(s:data)
        endfor
    catch
        echomsg 'Error trying to read config from ' . s:name
    endtry

else
    if !has('nvim') && v:version >= 800
        packadd! matchit
    elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
        runtime! macros/matchit.vim
    endif

    filetype plugin indent on
    if exists('+syntax')
        syntax on      " Switch on syntax highlighting
    endif

endif

" }}} END Initialize plugins

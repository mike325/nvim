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
    let g:bare = 1
endif

if has('nvim')
    lua require('settings')
else
    call set#initconfigs()
endif

if exists('g:bare')

    if !has('nvim') && v:version >= 800
        packadd! matchit
    elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &runtimepath) ==# ''
        runtime! macros/matchit.vim
    endif

    filetype plugin indent on
    if exists('+syntax')
        syntax on      " Switch on syntax highlighting
    endif

else
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
        elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &runtimepath) ==# ''
            runtime! macros/matchit.vim
        endif
        filetype plugin indent on
        if exists('+syntax')
            syntax on      " Switch on syntax highlighting
        endif
        finish
    endtry

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-projectionist'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim', {'on': ['GV']}
    Plug 'Raimondi/delimitMate'
    Plug 'tomtom/tcomment_vim'
    Plug 'tpope/vim-apathy'

    if !exists('g:minimal')
        call plugins#init()
    endif

    call plug#end()

    if has('nvim')
        lua require('plugins')
    else
        call plugins#settings()
    endif

endif

" if filereadable(vars#basedir() . '/local.vim')
"     execute 'source ' . vars#basedir() . '/local.vim'
" endif

" }}} END Initialize plugins

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

" TODO: Should minimal include lightweight tpope's plugins ?
call set#initconfigs()

if exists('g:bare')

    if !has('nvim') && v:version >= 800
        packadd! matchit
    elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
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
        elseif !exists('g:loaded_matchit') && findfile('plugin/matchit.vim', &rtp) ==# ''
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
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim', {'on': ['GV']}
    Plug 'Raimondi/delimitMate'
    Plug 'tomtom/tcomment_vim'
    Plug 'tpope/vim-apathy'

    if !exists('g:minimal')
        call plugins#init()
    endif

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

endif

" }}} END Initialize plugins

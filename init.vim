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

let g:mapleader="\<Space>"

if os#name('windows')

    " I'm tired of trying to setup powershell as windows shell, so just gonna
    " leave this for a while
    set shell=cmd.exe

    " Better compatibility with Unix paths in DOS systems
    " if exists('+shellslash')
    "     set shellslash
    "     let &runtimepath = tr(&runtimepath, '\', '/')
    " endif

endif

" If there are no plugins available and we don't have git fallback to minimal mode
if (!executable('git') && !isdirectory(fnameescape(vars#basedir().'/plugged'))) || v:progname ==# 'vi'
    let g:bare = 1
endif

" ================ PLUGINS ==================== {{{
" " Disable built-in plugins
let g:loaded_2html_plugin      = 1
let g:loaded_gzip              = 1
let g:loaded_rrhelper          = 1
let g:loaded_tarPlugin         = 1
let g:loaded_zipPlugin         = 1
let g:loaded_tutor_mode_plugin = 1
" }}}

if has('nvim')
    lua require('python').setup()
    lua require('tools')
else
    call set#initconfigs()
    call setup#python()
endif

if v:version >= 800
    packadd! cfilter
endif

if v:version >= 704
    packadd! matchit
endif

if exists('g:bare') || !empty($VIM_BARE)

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

    if has('nvim')
        Plug 'Vigemus/iron.nvim'
    endif

    if has('nvim-0.4')
        Plug 'TravonteD/luajob'
    endif

    if !exists('g:minimal') && empty($VIM_MIN)
        call plugins#init()
    elseif has('nvim-0.5')
        Plug 'neovim/nvim-lsp'
        Plug 'lifepillar/vim-mucomplete'
    endif

    call plug#end()

    let g:plug_window = has('nvim-0.4') ? 'lua require("floating").window()' : 'tabnew'

    if has('nvim')
        lua require('plugins')
    else
        call plugins#settings()
    endif

endif

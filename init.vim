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
    set shell=cmd.exe
endif

" If there are no plugins available and we don't have git fallback to minimal mode
if (!executable('git') && !isdirectory(fnameescape(vars#basedir().'/plugged')))
 \ || v:progname ==# 'vi'
 \ || ! empty($VIM_BARE)
    let g:bare = 1
elseif ! empty($VIM_MIN)
    let g:minimal = 1
endif

" Disable built-in plugins
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
    silent! packadd! cfilter
endif

if v:version >= 704 && !has('nvim')
    silent! packadd! matchparen
    silent! packadd! matchit
endif

if exists('g:started_by_firenvim')
    let $NO_COOL_FONTS = 1
endif

if exists('g:bare')
    filetype plugin indent on
    finish
else

    try
        execute 'set runtimepath+=' . expand(vars#basedir() . '/plug/')
        call plug#begin(vars#basedir().'/plugged')
    catch /E\(117\|492\)/
        filetype plugin indent on
        finish
    endtry

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-projectionist'
    Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'tpope/vim-apathy'
    Plug 'junegunn/gv.vim', {'on': ['GV']}
    Plug 'Raimondi/delimitMate'
    Plug 'tomtom/tcomment_vim'

    if has('nvim')
        Plug 'Vigemus/iron.nvim'
    endif

    if has('nvim-0.4')
        Plug 'TravonteD/luajob'
    endif

    if exists('g:minimal') && has('nvim-0.5')
        Plug 'neovim/nvim-lsp'
        Plug 'lifepillar/vim-mucomplete'
    elseif !exists('g:minimal')
        runtime! plugin/plugins.vim
    endif

    call plug#end()

    let g:plug_window = has('nvim-0.4') ? 'lua require("floating").window()' : 'tabnew'

    if has('nvim')
        lua require('plugins')
    else
        call plugins#settings()
    endif

endif

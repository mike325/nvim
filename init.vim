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

let g:mapleader = "\<Space>"

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
let g:loaded_tarPlugin         = 1
let g:loaded_vimballPlugin     = 1

if has('nvim')
    lua require('python').setup()
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

if has#bare()
    filetype plugin indent on

    if has('nvim')
        lua require('plugins')
    endif

    finish
else

    try
        execute 'set runtimepath+=' . expand(vars#basedir() . '/plug/')
        call plug#begin(vars#basedir().'/plugged')
    catch /E\(117\|492\)/
        filetype plugin indent on
        finish
    endtry

    Plug 'tweekmonster/startuptime.vim', {'on': ['StartupTime']}

    Plug 'tpope/vim-repeat'
    Plug 'tpope/vim-surround'
    Plug 'tpope/vim-projectionist'
    " Plug 'tpope/vim-unimpaired'
    Plug 'tpope/vim-apathy'
    Plug 'tpope/vim-dispatch'
    Plug 'tpope/vim-fugitive'
    Plug 'junegunn/gv.vim', {'on': ['GV']}
    " Plug 'lambdalisue/gina.vim' " TODO: keep testing this
    Plug 'Raimondi/delimitMate'
    Plug 'tpope/vim-commentary'
    Plug 'ojroques/vim-oscyank'

    " Syntax files
    Plug 'elzr/vim-json'
    Plug 'peterhoeg/vim-qml'
    Plug 'PProvost/vim-ps1'
    Plug 'cespare/vim-toml'
    Plug 'bjoernd/vim-syntax-simics'
    Plug 'kurayama/systemd-vim-syntax'
    Plug 'mhinz/vim-nginx'
    Plug 'raimon49/requirements.txt.vim'

    Plug 'kyazdani42/nvim-web-devicons'

    if has('nvim')
        Plug 'Vigemus/iron.nvim'
    endif

    if has#minimal() && has('nvim-0.5')

        " TODO: Need to do more test in windows
        if has('nvim-0.5')
            Plug 'nvim-lua/popup.nvim'
            Plug 'nvim-lua/plenary.nvim'
            Plug 'nvim-lua/telescope.nvim'
        endif

        Plug 'nvim-lua/completion-nvim'

        if tools#CheckLanguageServer()
            Plug 'neovim/nvim-lspconfig'
        endif

        if executable('gcc') || executable('clang')
            Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
            " Plug '~/source/nvim-treesitter', {'do': ':TSUpdate'}
            Plug 'nvim-treesitter/nvim-treesitter-refactor'
            " Plug '~/source/nvim-treesitter-refactor'
            Plug 'nvim-treesitter/nvim-treesitter-textobjects'
            " Plug '~/source/nvim-treesitter-textobjects'
            Plug 'nvim-treesitter/completion-treesitter'
            " Plug 'romgrk/nvim-treesitter-context'
        endif

    elseif has#minimal() && v:version >= 704
        Plug 'lifepillar/vim-mucomplete'
    elseif !has#minimal()
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

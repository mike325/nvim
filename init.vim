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
    " if has('nvim-0.5')
    "     set shell=powershell.exe
    "     set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
    "     set shellxquote=
    "     let &shellquote = ''
    "     let &shellpipe  = '| Out-File -Encoding UTF8 %s'
    "     let &shellredir = '| Out-File -Encoding UTF8 %s'
    "     " set shellxquote=(
    " else
    set shell=cmd.exe
    " endif
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
    lua require('tools.globals')
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
    Plug 'tpope/vim-apathy'
    Plug 'tpope/vim-commentary'
    Plug 'ojroques/vim-oscyank'

    if executable('git')
        Plug 'tpope/vim-fugitive'
    endif

    " Syntax files
    Plug 'PProvost/vim-ps1'
    Plug 'kurayama/systemd-vim-syntax'
    Plug 'raimon49/requirements.txt.vim'

    if has#minimal() && exists('g:started_by_firenvim')
        Plug 'glacambre/firenvim', { 'do': { _ -> firenvim#install(0) } }
    endif

    if has('nvim-0.5')
        Plug 'nvim-lua/popup.nvim'
        Plug 'nvim-lua/plenary.nvim'
        Plug 'nvim-telescope/telescope.nvim'
        Plug 'windwp/nvim-autopairs'

        if executable('gcc') || executable('clang')
            " if os#name('windows')
            "     Plug 'nvim-treesitter/completion-treesitter'
            " endif
            Plug 'nvim-treesitter/nvim-treesitter', {'do': ':TSUpdate'}
            Plug 'nvim-treesitter/nvim-treesitter-refactor'
            Plug 'nvim-treesitter/nvim-treesitter-textobjects'
            Plug 'nvim-treesitter/playground'
            " Plug 'romgrk/nvim-treesitter-context'
        endif
    else
        Plug 'Raimondi/delimitMate'
    endif

    if has#minimal()

        if has('nvim-0.5')
            " if os#name('windows')
            "     Plug 'nvim-lua/completion-nvim'
            " else
                Plug 'hrsh7th/nvim-compe'
            " endif

            if tools#CheckLanguageServer()
                Plug 'neovim/nvim-lspconfig'
                Plug 'glepnir/lspsaga.nvim'
            endif
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

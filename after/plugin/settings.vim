scriptencoding 'utf-8'
" Config default settings
" github.com/mike325/.vim

" We just want to source this file once
if exists('g:settings_loaded')
    finish
endif

let g:settings_loaded = 1

if has('nvim-0.4')
    lua require('settings')
    finish
endif

if exists('+syntax')
    syntax on
endif

" Fucking hate stock vim in MAC
if !os#name('macos')
    " Default should be internal,filler,closeoff
    set diffopt^=vertical

    if has#patch('8.1.0360') || has('nvim')
        set diffopt^=indent-heuristic,algorithm:patience
    endif

    if has#patch('8.1.1361') || has('nvim')
        set diffopt^=hiddenoff
    endif

    if has#patch('8.1.2289') || has('nvim')
        set diffopt^=iwhiteall,iwhiteeol
    else
        set diffopt^=iwhite
    endif
endif


if has#option('winaltkeys')
    set winaltkeys=no
endif

if has#option('renderoptions')
    set renderoptions=type:directx
endif

if os#name('windows')
    behave xterm
endif

" Allow lua omni completion
let g:lua_complete_omni = 1

" Use C for .h headers
let g:c_syntax_for_h = 1

if has#option('scrollback')
    set scrollback=-1
endif

if has#option('termguicolors')
    set termguicolors
endif

if has#option('virtualedit')
    " Allow virtual editing in Visual block mode.
    set virtualedit=block
endif

if has#option('infercase')
    set infercase      " Smart casing when completing
endif

if has#option('langnoremap')
    set langnoremap
endif

set nrformats=hex
set shortmess=filnxtToO

if has#patch('7.4.1065')
    set nrformats+=bin
endif

if has#patch('7.4.1570')
    set shortmess+=F
endif

" Clipboard {{{
" Set the defaults, which we may change depending where we run (Neo)vim

" Disable mouse at all
" This can be re-enable wit MouseToggle cmd
if has('mouse')
    set mouse=
endif
" set nocompatible

set ttyfast
set t_Co=255
set t_vb= " ...disable the visual effect

set autoindent
set autoread
set background=dark
set backspace=indent,eol,start
set cscopeverbose
" set encoding=utf-8     " The encoding displayed.
set nofsync
set hlsearch
set incsearch
set history=10000
set laststatus=2
set ruler
set showcmd
set sidescroll=1
set smarttab
set tabpagemax=50
set tags=./tags;,tags
set ttimeoutlen=50

try
    set fillchars=vert:│,fold:·
catch /.*/
endtry

if has#option('display')
    set display=lastline
endif

if v:version >= 704
    set formatoptions=tcqj
endif

if has#option('belloff')
    set belloff=all " Bells are annoying
endif

if has#patch('8.1.1902')
    set completeopt+=popup
    set completepopup=height:10,width:60,highlight:Pmenu,border:off
endif

" TODO: Something it's changing the settings in vim so recall this
call set#initconfigs()

" Don't use the system's clipboard whenever we run in SSH session or we don't have 'clipboard' option available
" NOTE: Windows terminal doesn't have mouse support, so this wont have effect for vim/neovim TUI
if empty($SSH_CONNECTION) && has('clipboard')
    " We assume that Vim's magic clipboard will work (hopefully, not warranty)
    set clipboard+=unnamedplus,unnamed
    if has('mouse')
        set mouse=a    " We have mouse support, so we use it
        set mousehide  " Hide mouse when typing text
    endif
else
    " let g:clipboard = {}
    set clipboard=
endif

" }}} END Clipboard

" This is adjusted inside autocmd.vim to use git according to the dir changes events
call tools#set_grep(0, 0)

if v:version >= 704
    set formatoptions+=r " Auto insert comment with <Enter>...
    set formatoptions+=o " ...or o/O
    set formatoptions+=l " Do not wrap lines that have been longer when starting insert mode already
    set formatoptions+=n " Recognize numbered lists
    set formatoptions+=j " Delete comment character when joining commented lines
endif

set updatetime=1000

" Remove includes from completions
set complete-=i
" Disable preview window during completions
set completeopt-=preview

if v:version > 704
    set completeopt+=noselect
    set completeopt+=noinsert
endif

set lazyredraw " Don't draw when a macro is being executed
set splitright " Split on the right the current buffer
set splitbelow " Split on the below the current buffer
set showmatch  " Show matching parenthesis

" Improve performance by just highlighting the first 256 chars
" set synmaxcol=256

" Search settings
set ignorecase  " ignore case
set nosmartcase " Use smartcase for typed search

" Indenting stuff
set smartindent
set copyindent

set expandtab
set shiftround
set tabstop=4
set shiftwidth=0
set softtabstop=-1

set shiftround     " Use multiple of shiftwidth when indenting with '<' and '>'

" Allow to send unsaved buffers to the backgroud
set hidden

set autowrite    " Write files when navigating with :next/:previous
set autowriteall " Write files when exit (Neo)vim

if empty($NO_COOL_FONTS)
    " set listchars=tab:\┊\ ,trail:•,extends:❯,precedes:❮
    " I like to have different chars for spaces and tabs (see IndentLine plugin)
    try
        set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
    catch /E474/
        set listchars=tab:>\ ,trail:-,extends:$,precedes:$
    endtry
else
    set listchars=tab:>\ ,trail:-,extends:$,precedes:$
endif

if has('path_extra')
    setglobal tags^=.git/tags
endif

if !&sidescrolloff
    set sidescrolloff=5
endif

if !&scrolloff
    set scrolloff=1
endif

" Enable <TAB> completion in command mode
set wildmenu
set wildmode=full

set backupcopy=yes

set display+=lastline

" Use only 1 space after "." when joining lines, not 2
set nojoinspaces

set visualbell  " Visual bell instead of beeps, but...

set fileformats=unix,dos " File mode unix by default

" Folding settings
" set foldnestmax=10    " deepest fold is 10 levels

set undolevels=10000 " Set the number the undos per file

if has#option('breakindent')
    setglobal breakindent
    " set showbreak=\\\\\
    try
        set showbreak=↪\
    catch /E595/
    endtry
endif

if has#option('relativenumber')
    set relativenumber
endif

if has#option('colorcolumn')
    set colorcolumn=80
endif

if has#option('numberwidth')
    set numberwidth=1
endif

set number
set list
set nowrap
set nofoldenable
set foldmethod=syntax
set foldlevel=99
" set foldcolumn=0
set fileencoding=utf-8

if has#bare() && has#plugin('vim-airline')
    " We already have the statusline, we don't need this
    set noshowmode
endif

if !has#plugin('vim-airline')
    let &statusline = '%< [%f]%=%-5.(%y%r%m%w%q%) %-14.(%l,%c%V%) %P '
endif

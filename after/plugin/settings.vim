scriptencoding 'utf-8'
" Config default settings
" github.com/mike325/.vim

" We just want to source this file once
if exists('g:settings_loaded')
    finish
endif

if has('nvim')
    call nvim#init()
else
    call vim#init()
endif

if has('nvim-0.3.3') || has('patch-8.1.0360')
    set diffopt=internal,filler,vertical,iwhiteall,iwhiteeol,indent-heuristic,algorithm:patience
else
    set diffopt=filler,vertical,iwhite
endif

if has('winaltkeys')
    set winaltkeys=no
endif

if has('directx')
    set renderoptions=type:directx
endif

if os#name('windows')
    behave xterm
endif

" Allow lua omni completion
let g:lua_complete_omni = 1

" Always prefer latex over plain text for *.tex files
let g:tex_flavor = 'latex'

if exists('+scrollback')
    set scrollback=-1
endif

if exists('+numberwidth')
    set numberwidth=1
endif

if exists('+breakindent')
    set breakindent " respect indentation when wrapping
    " set showbreak=\\\\\
    try
        set showbreak=↪\
    catch E595
    endtry
endif

if has('termguicolors')
    " set terminal colors
    set termguicolors
endif

if exists('+virtualedit')
    " Allow virtual editing in Visual block mode.
    set virtualedit=block
endif


" Color columns
if exists('+colorcolumn')
    " NOTE: May reactivate this since big files are consider logs and
    "       automatically deactivate this
    " This works but it tends to slowdown vim with big files
    " let &colorcolumn="80,".join(range(120,999),",")

    " Visual ruler
    set colorcolumn=80
endif

if exists('+relativenumber')
    set relativenumber " Show line numbers in motions friendly way
endif

if exists('+infercase')
    set infercase      " Smart casing when completing
endif

" Clipboard {{{
" Set the defaults, which we may change depending where we run (Neo)vim

" Disable mouse at all
" This can be re-enable wit MouseToggle cmd
if has('mouse')
    set mouse=
endif

" Don't use the system's clipboard whenever we run in SSH session or we don't have 'clipboard' option available
" NOTE: Windows terminal doesn't have mouse support, so this wont have effect for vim/neovim TUI
if empty($SSH_CONNECTION) && has('clipboard')
    if has('nvim')
        " Neovim in unix require external programs to use system's clipboard
        let s:copy = {}
        let s:paste = {}
        if os#name('windows') && executable('win32yank')

            let s:copy['+'] = 'win32yank.exe -i --crlf'
            let s:paste['+'] = 'win32yank.exe -o --lf'
            let s:copy['*'] = s:copy['+']
            let s:paste['*'] = s:paste['+']

            let g:clipboard = {
                        \   'name': 'win32yank',
                        \   'copy': s:copy,
                        \   'paste': s:paste,
                        \   'cache_enabled': 1,
                        \ }
        elseif !os#name('windows') && executable('xclip')
            let s:copy['+'] = 'xclip -quiet -i -selection clipboard'
            let s:paste['+'] = 'xclip -o -selection clipboard'
            let s:copy['*'] = 'xclip -quiet -i -selection primary'
            let s:paste['*'] = 'xclip -o -selection primary'
            let g:clipboard = {
                        \   'name': 'xclip',
                        \   'copy': s:copy,
                        \   'paste': s:paste,
                        \   'cache_enabled': 1,
                        \ }
        elseif !os#name('windows') && executable('pbcopy')
            let s:copy['+'] = 'pbcopy'
            let s:paste['+'] = 'pbpaste'
            let s:copy['*'] = s:copy['+']
            let s:paste['*'] = s:paste['+']
            let g:clipboard = {
                        \   'name': 'pbcopy',
                        \   'copy': s:copy,
                        \   'paste': s:paste,
                        \   'cache_enabled': 1,
                        \ }
        endif
        if exists('g:clipboard')
            set clipboard+=unnamedplus,unnamed
            if has('mouse')
                set mouse=a    " We have mouse support, so we use it
                set mousehide  " Hide mouse when typing text
            endif
        endif
    else
        " We assume that Vim's magic clipboard will work (hopefully, not warranty)
        set clipboard+=unnamedplus,unnamed
        if has('mouse')
            set mouse=a    " We have mouse support, so we use it
            set mousehide  " Hide mouse when typing text
        endif
    endif
else
    " let g:clipboard = {}
    set clipboard=
endif

" }}} END Clipboard

" This is adjusted inside autocmd.vim to use git according to the dir changes events
let &grepprg = tools#select_grep(0)
let &grepformat = tools#select_grep(0, 'grepformat')

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

set lazyredraw " Don't draw when a macro is being executed
set splitright " Split on the right the current buffer
set splitbelow " Split on the below the current buffer
set nowrap     " By default don't wrap the lines
set showmatch  " Show matching parenthesis
set number     " Show line numbers

" Improve performance by just highlighting the first 256 chars
" set synmaxcol=256

" Search settings
set ignorecase    " ignore case
set smartcase     " Use smartcase for typed search

" Indenting stuff
set smartindent
set copyindent

" set softtabstop=4  " makes the spaces feel like real tabs
set tabstop=4      " 1 tab = 4 spaces
set shiftwidth=4   " Same for autoindenting
set softtabstop=-1 " Edit "virtual tabs", negative value makes it use shiftwidth
set expandtab      " Use spaces for indenting, tabs are evil

set shiftround     " Use multiple of shiftwidth when indenting with '<' and '>'

" Allow to send unsaved buffers to the backgroud
set hidden

set autowrite    " Write files when navigating with :next/:previous
set autowriteall " Write files when exit (Neo)vim

" Show invisible characters
set list

if empty($NO_COOL_FONTS)
    " set listchars=tab:\┊\ ,trail:•,extends:❯,precedes:❮
    " I like to have different chars for spaces and tabs (see IndentLine plugin)
    try
        set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
    catch E474
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
set nofoldenable      " don't fold by default
set foldmethod=syntax " fold based on syntax
set foldlevel=99      " Autoclose fold levels greater than 99
set foldcolumn=0
" set foldnestmax=10    " deepest fold is 10 levels

set undolevels=10000 " Set the number the undos per file

if !exists('g:bare') && exists('g:plugs["vim-airline"]')
    " We already have the statusline, we don't need this
    set noshowmode
endif

set sessionoptions=buffers,curdir,folds,globals,localoptions,options,resize,tabpages,winpos,winsize
if os#name('windows')
    let &sessionoptions.=',slash,unix'
endif

if exists('g:plugs["vim-fugitive"]') && !exists('g:plugs["vim-airline"]')
    set statusline=%<%f\ %h%m%r%{fugitive#statusline()}%=%-14.(%l,%c%V%)\ %P
endif

" HEADER {{{
"
"                             Small improvements
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
" }}} END HEADER

" We just want to source this file once
if exists("g:settings_loaded") && g:settings_loaded
    finish
endif

let g:settings_loaded = 1

" Disable some vi compatibility
if has("nvim")
    " Live substitute preview
    set inccommand=split
    " Actually I'm not sure if this exists in Vim7/8
    set numberwidth=1
else
    set ttyfast
    set t_vb= " ...disable the visual effect :)
endif

if has("nvim") || (v:version >= 704)
    set formatoptions+=r " Auto insert comment with <Enter>...
    set formatoptions+=o " ...or o/O
    set formatoptions+=c " Autowrap comments using textwidth
    set formatoptions+=l " Do not wrap lines that have been longer when starting insert mode already
    set formatoptions+=q " Allow formatting of comments with "gq".
    set formatoptions+=t " Auto-wrap text using textwidth
    set formatoptions+=n " Recognize numbered lists
    set formatoptions+=j " Delete comment character when joining commented lines
endi

if has("nvim") || ( v:version > 704 || (v:version == 704 && has('patch338')))
    set breakindent " respect indentation when wrapping
endif

if executable("ag")
    set grepprg=ag\ --nogroup\ --nocolor\ -U
endif

if has("termguicolors")
    " set terminal colors
    set termguicolors
endif

" Clipboard {{{
if has('clipboard')
    if !has("nvim") || ( executable('pbcopy') || executable('xclip') ||
                \ executable('xsel') || executable("lemonade") )
        set clipboard+=unnamedplus,unnamed
    elseif has("nvim") && ( has("win32") || has("win64") )
        " TODO: Need to check for GUI in new neovim-qt
        set clipboard+=unnamedplus,unnamed
        set mouse=a
    endif
elseif has("nvim")
    " If system clipboard is not available, disable the mouse selection
    set mouse=c
endif

set background=dark

set encoding=utf-8     " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.

set titlestring=%t\ (%f)
set title          " Set window title
set laststatus=2   " don't combine status line with command line
set lazyredraw     " Don't draw when a macro is being executed
set splitright     " Split on the right size
set nowrap         " By default don't wrap the lines
set showmatch      " Show matching parenthesis
set number         " Show line numbers
set relativenumber " Show line numbers in motions friendly way
set syntax=on      " add syntax highlighting
set ruler

" Search settings
set hlsearch   " highlight search terms
set incsearch  " show search matches as you type
set ignorecase " ignore case

" Indenting stuff
set autoindent
set smartindent
set copyindent
set softtabstop=4  " makes the spaces feel like real tabs
set tabstop=4      " 1 tab = 4 spaces
set shiftwidth=4   " Same for autoindenting
set expandtab      " Use  spaces for indenting

set smarttab       " Insert tabs on the start of a line according to
                   " shiftwidth, not tabstop

set shiftround     " Use multiple of shiftwidth when indenting with '<' and '>'
set cursorline     " Turn on cursor line by default

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers, Normally I like to keep unsave just the files that
" I'm currently using, this allow me to quit(q!) without worries
" set hidden

" Auto-reload buffers when file changed on disk, Some times I like to keep the
" changes to save them in some registers
" set autoread

" Show invisible characters
" set list

" Indicator chars
" set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
" set showbreak=↪\

" Use only 1 space after "." when joining lines, not 2
set nojoinspaces

" Set path to look recursive in the current dir
set path+=**

" Set vertical diff
set diffopt+=vertical

set visualbell " visual bell instead of beeps, but...

set fileformats=unix,dos " File mode unix by default

" Default omnicomplete func
set omnifunc=syntaxcomplete#Complete

" Folding settings
set foldmethod=indent " fold based on indent
set nofoldenable      " dont fold by default
set foldnestmax=10    " deepest fold is 10 levels
" set foldlevel=1


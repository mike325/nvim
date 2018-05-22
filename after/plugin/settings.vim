" HEADER {{{
"
"                           Config default settings
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

" TODO: Implement a function to activate just the settings that are in the
" current Vim instance

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
    set t_vb= " ...disable the visual effect
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

if has("nvim") && executable("nvr")
    " Add Neovim remote utility, this allow us to open buffers from the :terminal cmd
    let $tnvr = 'nvr --remote-tab-silent'
    let $snvr = 'nvr -cc vsplit --remote-silent'
endif

if exists('+breakindent')
    set breakindent " respect indentation when wrapping
    " set showbreak=\\\\\
    set showbreak=↪\
endif

if executable("ag")
    let &grepprg='ag --nogroup --nocolor -U '.g:ignore_patterns.ag . ' '
elseif executable("grep")
    let &grepprg='grep --with-filename -n -I '.g:ignore_patterns.grep . ' '
endif

if has("termguicolors")
    " set terminal colors
    set termguicolors
endif

" Color columns
if exists('+colorcolumn')
    " NOTE: May reactivate this since big files are consider logs and
    "       automatically deactivate this
    " This works but it tends to slowdown vim with big files
    " let &colorcolumn="80,".join(range(120,999),",")

    " Visual ruler
    let &colorcolumn="80"
endif

" Clipboard {{{
" Set the defaults, which we may change depending where we run (Neo)vim

" Disable mouse at all
if has('mouse')
    set mouse=
endif

" Remove system clipboard
if has('clipboard')
    set clipboard=
endif

" Don't use the system's clipboard whenever we run in SSH session or we don't
" have 'clipboard' option available
if empty($SSH_CONNECTION) && has('clipboard')
    " if we are running gVim or running Neovim from Windows (aka neovim-qt)
    " We reactivate the everything
    if has('gui_running') || (WINDOWS() && has('nvim'))
        set clipboard=unnamedplus,unnamed
        if has('mouse')
            set mouse=a    " We have mouse support, so we use it
            set mousehide  " Hide mouse when typing text
        endif
    elseif has('nvim')
        " Neovim in unix require external programs to use system's clipboard
        " NOTE: we don't dare to run Neovim from window's cmd/powershell
        if ( executable('pbcopy') || executable('xclip') || executable('xsel') || executable("lemonade") )
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
endif

" }}} END Clipboard

set background=dark

set backspace=indent,eol,start " Use full backspace power

set encoding=utf-8     " The encoding displayed.

" This is set in every file in BufReadPre autocmd
" set fileencoding=utf-8 " The encoding written to file.

set titlestring=%t\ (%f)
set title          " Set window title
set laststatus=2   " Always show the status line
set lazyredraw     " Don't draw when a macro is being executed
set splitright     " Split on the right size
set nowrap         " By default don't wrap the lines
set showmatch      " Show matching parenthesis
set number         " Show line numbers
if exists("+relativenumber")
    set relativenumber " Show line numbers in motions friendly way
endif
set ruler

if exists("+syntax")
    syntax enable      " Switch on syntax highlighting
endif

" Improve perfomance by just highlighting the first 200 chars
set synmaxcol=200

" Search settings
set hlsearch       " highlight search terms
set incsearch      " show search matches as you type
set ignorecase     " ignore case
" set gdefault     " Always do global substitutes

if exists("+infercase")
    set infercase      " Smart casing when completing
endif

" Indenting stuff
set autoindent
set smartindent
set copyindent
set softtabstop=4  " makes the spaces feel like real tabs
set tabstop=4      " 1 tab = 4 spaces
set shiftwidth=4   " Same for autoindenting
set expandtab      " Use spaces for indenting, tabs are evil

set smarttab       " Insert tabs on the start of a line according to
                   " shiftwidth, not tabstop

set shiftround     " Use multiple of shiftwidth when indenting with '<' and '>'
set cursorline     " Turn on cursor line by default

" Allow backgrounding buffers without writing them, and remember marks/undo
" for backgrounded buffers, Normally I like to keep unsave just the files that
" I'm currently using, this allow me to quit(q!) without worries
" set hidden

set autoread     " Auto-reload buffers when file changed on disk
set autowrite    " Write files when navigating with :next/:previous
set autowriteall " Write files when exit vim

" Show invisible characters
set list

if empty($NO_COOL_FONTS)
    " set listchars=tab:\┊\ ,trail:•,extends:❯,precedes:❮
    " I like to have different chars for spaces and tabs (see IndentLine plugin)
    set listchars=tab:▸\ ,trail:•,extends:❯,precedes:❮
else
    set listchars=tab:>\ ,trail:•,extends:$,precedes:$
endif

" Enable <TAB> completion in command mode
set wildmenu
set wildmode=full

" Use only 1 space after "." when joining lines, not 2
set nojoinspaces

" Set path to look recursive in the current dir
set path+=**

" Set vertical diff
set diffopt+=vertical

if exists("+belloff")
    set belloff=all " Bells are annoying
endif
set visualbell  " Visual bell instead of beeps, but...

set fileformats=unix,dos " File mode unix by default

" Default omnicomplete func
set omnifunc=syntaxcomplete#Complete

" Folding settings
set nofoldenable      " don't fold by default
set foldmethod=syntax " fold based on syntax
set foldlevel=99      " Autoclose fold levels greater than 99
set foldcolumn=2
" set foldnestmax=10    " deepest fold is 10 levels

set history=1000    " keep 1000 lines of command line history
set undolevels=1000 " Set the number the undos per file

if !exists('g:minimal') && exists('g:plugs["vim-airline"]')
    " We already have the statusline, we don't need this
    set noshowmode
endif

" ############################################################################
"
"                               Small improvements
"
" ############################################################################

set encoding=utf-8     " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.

let mapleader=" "
" nnoremap ; :
" vmap ; :

nnoremap , :
vmap , :

" Similar behavior as C and D
nmap Y y$

" Easy <ESC> insertmode
imap jj <Esc>

if !has("nvim")
    set ttyfast
    set nocompatible
endif

set lazyredraw
set splitright
set nowrap
set ruler
set showmatch      " Show matching parenthesis
set number         " Show line numbers
set relativenumber " Show line numbers in motions friendly way
set syntax=on      " add syntax highlighting

" Search settings
set hlsearch  " highlight search terms
set incsearch " show search matches as you type
set ignorecase

" Indenting stuff
set autoindent
set smartindent
set copyindent
set softtabstop=4   " makes the spaces feel like real tabs
set tabstop=4       " 1 tab = 4 spaces
set shiftwidth=4    " Same for autoindenting
set expandtab       " Use  spaces for indenting
set smarttab        " Insert tabs on the start of a line according to shiftwidth, not tabstop
set shiftround      " Use multiple of shiftwidth when indenting with '<' and '>'
set cursorline      " Turn on cursor line by default

" cd to current file path
" !! Removed to start using Tags file in projects
" autocmd BufEnter * silent! lcd %:p:h

" Set path to look recursive in the current dir
set path+=**

" disable sounds
set visualbell

set fileformat=unix " file mode is unix
" Remove ^M characters from windows format
nnoremap <leader>R :%s/\r\+$//e

" To be improve
function! RemoveTrailingWhitespaces()
    "Save last cursor position
    let savepos = getpos('.')

     %s/\s\+$//e

    call setpos('.', savepos)
endfunction

" Trim whitespaces in selected files
" autocmd FileType * autocmd BufWritePre <buffer> %s/\s\+$//e
autocmd FileType * autocmd BufWritePre <buffer> call RemoveTrailingWhitespaces()

" Specially for html and xml
autocmd FileType xml,html,vim autocmd BufReadPre <buffer> set matchpairs+=<:>

" Default omnicomplete func
set omnifunc=syntaxcomplete#Complete

" Set highlight CursorLine
hi CursorLine term=bold cterm=bold guibg=Grey40

" nnoremap <S-Enter> O<Esc>
" Add lines in normal mode without enter in insert mode
nnoremap <C-o> O<Esc>
nmap Q o<Esc>

" Easy remove line in normal mode
nnoremap <BS> dd

" better backup, swap and undos storage
set backup   " make backup files
set undofile " persistent undos - undo after you re-open the file
if has("win32") || has("win64")
    execute 'set directory='.fnameescape(g:os_editor.'tmp_dirs\swap')
    execute 'set backupdir='.fnameescape(g:os_editor.'tmp_dirs\backup')
    execute 'set undodir='.fnameescape(g:os_editor.'tmp_dirs\undos')
    execute 'set viminfo+=n'.fnameescape(g:os_editor.'tmp_dirs\viminfo')

    let g:yankring_history_dir = g:os_editor.'tmp_dirs\yank'
else
    execute 'set directory='.fnameescape(g:os_editor.'tmp_dirs/swap')
    execute 'set backupdir='.fnameescape(g:os_editor.'tmp_dirs/backup')
    execute 'set undodir='.fnameescape(g:os_editor.'tmp_dirs/undos')
    execute 'set viminfo+=n'.fnameescape(g:os_editor.'tmp_dirs/viminfo')

    let g:yankring_history_dir = g:os_editor.'tmp_dirs/yank'
endif

" create needed directories if they don't exist
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif

if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif

if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" Close buffer/Editor
nnoremap <leader>z ZZ
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

if has("gui_running")
    set guioptions-=m  "no menu
    set guioptions-=T  "no toolbar
    set guioptions-=r  "no scrollbar
    if has("win32") || has("win64")
        set guifont=DejaVu_Sans_Mono_for_Powerline:h11,DejaVu_Sans_Mono:h11
    endif
endif

" ################# Set Neovim settings #################
if (has("nvim"))
    " live preview of Substitute
    set inccommand=split
endif

" ################# visual selection go also to clipboard #################
if has('clipboard')
    if !has("nvim") || ( executable('pbcopy') || executable('xclip') || executable('xsel') || executable("lemonade") )
        set clipboard+=unnamedplus
    endif
elseif has("nvim")
    " Disable mouse to manually select text
    set mouse=c
endif

" ################# Tabs management #################
nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<CR>

nnoremap <leader>N :tabNext<CR>
nnoremap <leader><leader>n :tabnew<CR>
nnoremap <leader>c :tabclose<CR>

" ################# Buffer management #################
" buffer add
" nnoremap <leader>a :badd

" Next buffer
nnoremap <leader>n :bn<CR>

" Prev buffer
nnoremap <leader>p :bp<CR>

"go to last buffer
" nnoremap <leader>l :blast<CR>

" ################# Native Vim Explorer #################
nnoremap E :Explore<CR>
let g:netrw_liststyle=3

" ################# Change current active file split #################
" Easy indentation in normal mode
nnoremap <tab> >>
nnoremap <S-tab> <<

" nnoremap <leader>x <C-w><C-w>
nnoremap <C-x> <C-w><C-w>

" Buffer
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l

if has("nvim")
    " Better splits
    nnoremap <A-s> <C-w>s
    nnoremap <A-v> <C-w>v

    " Better terminal access
    nnoremap <A-t> :terminal<CR>
    tnoremap <Esc> <C-\><C-n>
    tnoremap oo <C-\><C-n>

    " Better terminal movement
    tnoremap <leader-h> <C-\><C-n><C-w>h
    tnoremap <leader-j> <C-\><C-n><C-w>j
    tnoremap <leader-k> <C-\><C-n><C-w>k
    tnoremap <leader-l> <C-\><C-n><C-w>l
endif

" Resize buffer splits
nnoremap <leader>e <C-w>=

" Color columns
if exists('+colorcolumn')
    " let &colorcolumn="80,".join(range(120,999),",")
    let &colorcolumn="80"
endif

" ################# folding settings #################
set foldmethod=indent " fold based on indent
set nofoldenable      " dont fold by default
set foldnestmax=10    " deepest fold is 10 levels
" set foldlevel=1

autocmd BufWinEnter *.c,*.h,*.cpp,*.hpp,*.java,*.go,*.js setlocal foldmethod=syntax

" ################# Easy Save file #################
nnoremap <F2> :update<CR>
vmap <F2> <Esc><F2>gv
imap <F2> <Esc><F2>a

" For systems without F's keys (ex. android)
nmap <leader>w :update<CR>

" ################# Toggles #################
nnoremap tn :set number!<Bar>set number?<CR>
nnoremap tr :set relativenumber!<Bar>set relativenumber?<CR>
nnoremap th :set hlsearch!<Bar>set hlsearch?<CR>
nnoremap ti :set ignorecase!<Bar>set ignorecase?<CR>
nnoremap tw :set wrap!<Bar>set wrap?<CR>
nnoremap tc :set cursorline!<Bar>set cursorline?<CR>

" ################# Terminal colors #################
set background=dark

if (has("nvim"))
    " Neovim colors stuff
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if has("termguicolors")
    " set terminal colors
    set termguicolors
endif

" Set Syntax to *.in files
augroup filetypedetect
    autocmd BufNewFile,BufRead .tmux.conf*,tmux.conf* set filetype=tmux
    autocmd BufNewFile,BufRead .nginx.conf*,nginx.conf* set filetype=nginx
    autocmd BufRead,BufNewFile *.in,*.simics,*.si,*.sle set filetype=conf
    autocmd BufRead,BufNewFile *.bash* set filetype=sh
augroup END

" omnifuncs
augroup omnifuncs
    autocmd!
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType go setlocal omnifunc=go#complete#Complete
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete
    autocmd FileType php setlocal omnifunc=phpcomplete#CompletePHP
    autocmd FileType java setlocal omnifunc=javacomplete#Complete

    autocmd BufNewFile,BufRead,BufEnter *.cpp,*.hpp setlocal omnifunc=omni#cpp#complete#Main
    autocmd BufNewFile,BufRead,BufEnter *.c,*.h setlocal omnifunc=ccomplete#Complete
augroup END

augroup Spells
    autocmd FileType gitcommit setlocal spell
    autocmd FileType markdown setlocal spell
augroup END

execute pathogen#infect()
execute pathogen#helptags()

filetype plugin indent on

set encoding=utf-8     " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.

" ############################################################################
"
"                               Small improvements
"
" ############################################################################

let mapleader=" "
nnoremap ; :
nnoremap , :
vmap ; :
vmap , :

set nocompatible
set splitright
set nowrap
set ruler
set tabstop=4    " 1 tab = 4 spaces
set shiftwidth=4 " Same for autoindenting
set expandtab    " Use  spaces for indenting
set smarttab     " Insert tabs on the start of a line according to shiftwidth, not tabstop
set shiftround   " Use multiple of shiftwidth when indenting with '<' and '>'
set showmatch    " Show matching parenthesis
set number       " Show line numbers
syntax enable    " add syntax highlighting

" cd to current file
autocmd BufEnter * silent! lcd %:p:h

" disable sounds
set visualbell

autocmd FileType c,cpp,java,php,python,shell,vim autocmd BufWritePre <buffer> %s/\s\+$//e

hi CursorLine term=bold cterm=bold guibg=Grey40

" Indenting stuff
set autoindent
set smartindent
set copyindent

set hlsearch      " highlight search terms
set incsearch     " show search matches as you type
set ignorecase

set pastetoggle=<F4>

"nmap <S-Enter> O<Esc>
nmap <c-o> O<Esc>
nmap <CR> o<Esc>

" better backup, swap and undos storage
set directory=~/.vim/tmp_dirs/swap    " directory to place swap files in
set backup                            " make backup files
set backupdir=~/.vim/tmp_dirs/backups " where to put backup files
set undofile                          " persistent undos - undo after you re-open the file
set undodir=~/.vim/tmp_dirs/undos
set viminfo+=n~/.vim/tmp_dirs/viminfo
let g:yankring_history_dir = '~/.vim/tmp_dirs/' " store yankring history file there too

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

nmap <leader>z ZZ


" ################# visual selection go also to clipboard #################
set go+=a

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

nnoremap <leader><leader>n :tabNext<CR>
nnoremap <leader><leader>p :tabprevious<CR>
nnoremap <leader><leader>c :tabclose<CR>

" ################# Buffer management #################
" buffer add
nmap <leader>a :badd

" Next buffer
nmap <leader>n :bn<CR>

" Prev buffer
nmap <leader>p :bp<CR>

" Delete buffer
nmap <leader>d :bdelete<CR>

"go to last buffer
nmap <leader>l :blast<CR>

" Quick buffer change by number
" nnoremap b1 :b 1<CR>
" nnoremap b2 :b 2<CR>
" nnoremap b3 :b 3<CR>
" nnoremap b4 :b 4<CR>
" nnoremap b5 :b 5<CR>
" nnoremap b6 :b 6<CR>
" nnoremap b7 :b 7<CR>
" nnoremap b8 :b 8<CR>
" nnoremap b9 :b 9<CR>

" ################# Native Vim Explorer #################
nnoremap E :Explore<CR>
let g:netrw_liststyle=3

" ################# Change current active file split #################
map <leader>x <c-w><c-w>
nmap <c-x> <c-w><c-w>
imap <c-x> <ESC><c-x>

map <leader>h <C-w>h
map <leader>j <C-w>j
map <leader>k <C-w>k
map <leader>l <C-w>l

map <leader>i <C-w>=
map <leader>- <C-w>-

if exists('+colorcolumn')
    let &colorcolumn="80,".join(range(120,999),",")
endif

" ################# folding settings #################
set foldmethod=indent " fold based on indent
set foldnestmax=10    " deepest fold is 10 levels
set foldlevel=1       " this is just what i use
set nofoldenable      " dont fold by default

" ################# Easy Save file #################
nmap <F2> :update<CR>
vmap <F2> <Esc><F2>gv
imap <F2> <Esc><F2>a

" ############################################################################
"
"                               Plugin configuraitions
"
" ############################################################################

if &runtimepath =~ 'bufferbye'
    " better behave buffer deletion
    nmap <leader>d :Bdelete<CR>
endif

if &runtimepath =~ 'sessions'
    let g:session_autosave = 'yes'
    let g:session_autoload = 'no'

    " nmap <leader>d :DeleteSession
    nmap <leader>o :OpenSession
    nmap <leader>s :SaveSession
    nmap <leader>C :CloseSession<CR>
    nmap <leader><leader>s :SaveSession<CR>
    nmap <leader><leader>d :DeleteSession<CR>
endif

if &runtimepath =~ 'ctrlp'
    nmap <leader>b :CtrlPBuffer<CR>
    nmap <leader>P :CtrlP<CR>
    let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:50'
    let g:ctrlp_map = '<c-p>'
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/]\.(git|hg|svn)$',
      \ 'file': '\v\.(exe|so|dll|pyc|zip|sw|swp)$',
      \ }
endif

if &runtimepath =~ 'nerdcommenter'
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDCompactSexyComs        = 1      " Use compact syntax for prettified multi-line comments
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                              " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                              " of following code indentation
endif

" <leader>f{char} to move to {char}
"map  <leader>f <Plug>(easymotion-bd-f)
nmap <leader>f <Plug>(easymotion-overwin-f)
vmap <leader>f <Plug>(easymotion-overwin-f)

" x{char} to move to {char}
"nmap <leader>x <Plug>(easymotion-s)
"vmap <leader>x <Plug>(easymotion-s)

" Move to line
"map <leader>L <Plug>(easymotion-bd-jk)
nmap <leader>L <Plug>(easymotion-overwin-line)
vmap <leader>L <Plug>(easymotion-overwin-line)

" Move to word
"map  <leader>w <Plug>(easymotion-bd-w)
nmap <leader><leader>w <Plug>(easymotion-overwin-w)
vmap <leader><leader>w <Plug>(easymotion-overwin-w)

" ################# Themes #################
if has('gui_running')
    set background=dark
endif

" colorscheme railscasts
colorscheme Monokai
nmap cm :colorscheme Monokai<CR>
nmap cr :colorscheme railscasts<CR>

if &runtimepath =~ 'airline'
    let g:airline_theme = 'molokai'

    let g:airline#extensions#tabline#enabled           = 1
    let g:airline#extensions#tabline#fnamemod          = ':t'
    let g:airline#extensions#tabline#close_symbol      = '×'
    let g:airline#extensions#tabline#show_tabs         = 1
    let g:airline#extensions#tabline#show_buffers      = 1
    let g:airline#extensions#tabline#show_close_button = 0
    let g:airline#extensions#tabline#show_splits       = 0

    " let g:airline#extensions#tabline#show_tab_nr = 0
    " let g:airline_powerline_fonts = 1
endif

" ################# Snnipets    #################
if has('python')
    let g:UltiSnipsSnippetDirectories=["UltiSnips"]

    if has('python3')
        let g:UltiSnipsUsePythonVersion = 3
    endif

    let g:UltiSnipsJumpBackwardTrigger="<c-z>"
    let g:UltiSnipsJumpForwardTrigger="<c-b>"
    let g:UltiSnipsExpandTrigger="<c-w>"

    if v:version == 704 && has("patch143")
        if &runtimepath =~ 'YouCompleteMe'
            "call youcompleteme#GetErrorCount()
            "call youcompleteme#GetWarningCount()

            nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>

            nnoremap <leader>i :YcmCompleter GoToInclude<CR>
            nnoremap <leader>g :YcmCompleter GoTo<CR>
            nnoremap <leader>r :YcmCompleter GoToReferences<CR>
            nnoremap <leader>F :YcmCompleter FixIt<CR>
            nnoremap <leader>D :YcmCompleter GetDoc<CR>
            " nnoremap <leader>p :YcmCompleter GetParent<CR>
            " nnoremap <leader>d :YcmCompleter GoToDeclaration<CR>
            " nnoremap <leader>t :YcmCompleter GetType<CR>
        endif
    endif
endif

" ################# NERDTree quick open/close #################
if &runtimepath =~ 'nerdtree'
    let NERDTreeShowHidden          = 1
    let NERDTreeDirArrowExpandable  = "+"
    let NERDTreeDirArrowCollapsible = "~"
    let NERDTreeIgnore              = ['\.pyc$', '\~$', '\.sw$', '\.swp$'] "ignore files in NERDTree
endif

" ################ Alignment with Tabularize #################
if &runtimepath =~ 'tabular'
    nmap <leader>t= :Tabularize /=<CR>
    vmap <leader>t= :Tabularize /=<CR>

    nmap <leader>t: :Tabularize /:<CR>
    vmap <leader>t: :Tabularize /:<CR>

    nmap <leader>t" :Tabularize /"<CR>
    vmap <leader>t" :Tabularize /"<CR>

    nmap <leader>t# :Tabularize /#<CR>
    vmap <leader>t# :Tabularize /#<CR>

    nmap <leader>t* :Tabularize /*<CR>
    vmap <leader>t* :Tabularize /*<CR>
endif

" ################# Toggles #################
nmap tn :set number!<CR>
nmap th :set hlsearch!<CR>
nmap ti :set ignorecase!<CR>
nmap tw :set wrap!<CR>
nmap tc :set cursorline!<CR>


if &runtimepath =~ 'gitglutter'
    nmap tg :GitGutterToggle<CR>
    nmap tl :GitGutterLineHighlightsToggle<CR>
endif

if &runtimepath =~ 'signature'
    nmap <leader><leader>g :SignatureListGlobalMarks<CR>
    imap <C-s>g <ESC>:SignatureListGlobalMarks<CR>

    nmap <leader><leader>b :SignatureListBufferMarks<CR>
    imap <C-s>b <ESC>:SignatureListBufferMarks<CR>

    nmap ts :SignatureToggleSigns<CR>
endif

if &runtimepath =~ 'tagbar'
    nmap <F6> :TagbarToggle<CR>
    imap <F6> :TagbarToggle<CR>
    vmap <F6> :TagbarToggle<CR>
    nmap tt :TagbarToggle<CR>
endif

if &runtimepath =~ 'nerdtree-tabs'
    "nmap T :NERDTree<CR>
    nmap T :NERDTreeTabsToggle<CR>
    nmap tm :NERDTreeMirrorToggle<CR>

    nmap <F3> :NERDTreeTabsToggle<CR>
    imap <F3> <Esc><F3>
    vmap <F3> <Esc><F3>
endif

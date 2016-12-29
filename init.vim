" Specify a directory for plugins (for Neovim: ~/.local/share/nvim/plugged)
if has("nvim")
    call plug#begin('~/.config/nvim/plugged')
else
    call plug#begin('~/.vim/plugged')
endif

" Basic settings
Plug 'tpope/vim-sensible'

" Colorschemes for vim
Plug 'flazz/vim-colorschemes'

" Auto Close ' " () [] {}
Plug 'Raimondi/delimitMate'

" File explorer, and
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle', 'NERDTreeTabsToggle' ] }

" Mirror NerdTree in all tabs
Plug 'jistr/vim-nerdtree-tabs', { 'on': [ 'NERDTreeToggle', 'NERDTreeTabsToggle' ] }

" Easy comments
Plug 'scrooloose/nerdcommenter'

" Simulate sublime cursors
Plug 'terryma/vim-multiple-cursors'

" Status bar and some themes
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" Git integrations
Plug 'airblade/vim-gitgutter'
Plug 'tpope/vim-fugitive'
Plug 'rhysd/committia.vim'

" Simple view of Tags using ctags
Plug 'majutsushi/tagbar'

" Easy aligment
Plug 'godlygeek/tabular'

" Better motions
Plug 'easymotion/vim-easymotion'

" Easy surround text objects with ' " () [] {} etc
Plug 'tpope/vim-surround'

" Better buffer deletions
Plug 'moll/vim-bbye'

" Visual marks
Plug 'kshenoy/vim-signature'

" Search files, buffers, etc
Plug 'kien/ctrlp.vim'

" Better sessions management
Plug 'xolox/vim-misc'
Plug 'xolox/vim-session'

" Improve syntax
Plug 'sheerun/vim-polyglot'

" Auto convert bin files
Plug 'fidian/hexmode'

" Collection of snippets
Plug 'honza/vim-snippets'

" Move with identation
Plug 'matze/vim-move'

" Easy edit registers
Plug 'dohsimpson/vim-macroeditor'

let g:ycm_installed = 0

if ( has("python") || has("python3") )
    function! BuildYCM(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            " !./install.py --all
            " !./install.py --gocode-completer --tern-completer
            !./install.py
        endif
    endfunction

" Awesome completion engine
    if has("nvim") || ( v:version >= 800 ) || ( v:version == 704 && has("patch143") )
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
        let g:ycm_installed = 1
    endif

" Snippets engine
    Plug 'SirVer/ultisnips'

    if g:ycm_installed==0
        " completion for python
        Plug 'davidhalter/jedi-vim'
        " Syntaxis check
        Plug 'vim-syntastic/syntastic'
    endif
else
" Snippets without python interface
    Plug 'MarcWeber/vim-addon-mw-utils'
    Plug 'tomtom/tlib_vim'
    Plug 'garbas/vim-snipmate'
endif

" completion without ycm
if g:ycm_installed==0
    if has("nvim")
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
    else
        if has("lua")
            Plug 'Shougo/neocomplete.vim'
        else
            Plug 'ervandew/supertab'
        endif
    endif
endif

" Initialize plugin system
call plug#end()

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

" Trim whitespaces in selected files
autocmd FileType c,cpp,java,php,python,shell,vim,html,css,javascript,go autocmd BufWritePre <buffer> %s/\s\+$//e

hi CursorLine term=bold cterm=bold guibg=Grey40

" Indenting stuff
set autoindent
set smartindent
set copyindent

set hlsearch  " highlight search terms
set incsearch " show search matches as you type
set ignorecase

set pastetoggle=<F4>

"nmap <S-Enter> O<Esc>
" Add lines in normal mode without enter in insert mode
nmap <C-o> O<Esc>
nmap <CR> o<Esc>

" better backup, swap and undos storage
set backup   " make backup files
set undofile " persistent undos - undo after you re-open the file

" Easy remove line in normal mode
nmap <BS> dd
vmap <BS> dd

if has("nvim")
    " nvim stuff
    set directory=~/.config/nvim/tmp_dirs/swap    " directory to place swap files in
    set backupdir=~/.config/nvim/tmp_dirs/backups " where to put backup files
    set undodir=~/.config/nvim/tmp_dirs/undos
    set viminfo+=n~/.config/nvim/tmp_dirs/viminfo
    " store yankring history file there too
    let g:yankring_history_dir = '~/.config/nvim/tmp_dirs/'
else
    " vim stuff
    set directory=~/.vim/tmp_dirs/swap    " directory to place swap files in
    set backupdir=~/.vim/tmp_dirs/backups " where to put backup files
    set undodir=~/.vim/tmp_dirs/undos
    set viminfo+=n~/.vim/tmp_dirs/viminfo
    " store yankring history file there too
    let g:yankring_history_dir = '~/.vim/tmp_dirs/'
endif
" endif

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
nmap <leader>z ZZ
nmap <leader>q :q!<CR>

" easy dump bin files into hex
nmap <leader>x :%!xxd<CR>
" augroup Binary
"     au!
"     au BufReadPre   *.bin,*.exe let &bin=1
"     au BufReadPost  *.bin,*.exe if &bin | silent! %!xxd
"     au BufReadPost  *.bin,*.exe set ft=xxd | endif
"     au BufWritePre  *.bin,*.exe if &bin | %!xxd -r
"     au BufWritePre  *.bin,*.exe endif
"     au BufWritePost *.bin,*.exe if &bin | %!xxd
"     au BufWritePost *.bin,*.exe set nomod | endif
" augroup END

" if ( has("gui_running" ) && has("win32") )
"     set guifont=Lucida_Console:h10
" endif

if !has("gui_running") && !has("nvim")
    " Use shell grep
    nmap gp :!grep --color -nr
endif


" ################# Set Neovim settings #################
if (has("nvim"))
    " live preview of Substitute
    set inccommand=split
endif


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
" nmap <leader>a :badd

" Next buffer
nmap <leader>n :bn<CR>

" Prev buffer
nmap <leader>p :bp<CR>

" Delete buffer
nmap <leader>d :bdelete<CR>
" nmap fd :bdelete<CR>

"go to last buffer
" nmap <leader>l :blast<CR>

" ################# Native Vim Explorer #################
nnoremap E :Explore<CR>
let g:netrw_liststyle=3

" ################# Change current active file split #################
" Easy indentation in normal mode
nmap <tab> >>
nmap <S-tab> <<
vmap <tab> >gv
vmap <S-tab> <gv

" imap <S-tab> <C-p>

" nmap <leader>x <C-w><C-w>
nmap <C-x> <C-w><C-w>
imap <C-x> <ESC><C-x>

" Buffer
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l

if has("nvim")
    " Better splits
    nmap <A-s> <C-w>s
    nmap <A-v> <C-w>v

    " Better terminal access
    nmap <A-t> :terminal<CR>
    tnoremap <Esc> <C-\><C-n>

    " Better terminal movement
    tnoremap <leader-h> <C-\><C-n><C-w>h
    tnoremap <leader-j> <C-\><C-n><C-w>j
    tnoremap <leader-k> <C-\><C-n><C-w>k
    tnoremap <leader-l> <C-\><C-n><C-w>l
endif

" Resize buffer splits
nmap <leader>e <C-w>=
nmap <leader>- <C-w>-

" Color columns
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

" ################# Toggles #################
nmap tn :set number!<Bar>set number?<CR>
nmap th :set hlsearch!<Bar>set hlsearch?<CR>
nmap ti :set ignorecase!<Bar>set ignorecase?<CR>
nmap tw :set wrap!<Bar>set wrap?<CR>
nmap tc :set cursorline!<Bar>set cursorline?<CR>

" ################# Terminal colors #################
if (has("nvim"))
    " Neovim colors stuff
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if (has("termguicolors"))
    " set terminal colors
    set termguicolors
endif

" ############################################################################
"
"                               Plugin configuraitions
"
" ############################################################################

" ################ BufferBye settings #################
" better behave buffer deletion
if &runtimepath =~ "vim-bbye"
    nmap <leader>d :Bdelete<CR>
endif

" ################ Sessions settings #################
" Session management
" Auto save on exit
let g:session_autosave = 'yes'
" Don't ask for load last session
let g:session_autoload = 'no'

if has("nvim")
    let g:session_directory = '~/.config/nvim/sessions'
endif

if &runtimepath =~ "vim-sessions"
	" nmap <leader>d :DeleteSession
	" Quick open session
	nmap <leader>o :OpenSession
	" Save current files in a session
	nmap <leader>s :SaveSession
	" close current session !!!!!!!! use this instead of close the buffers !!!!!!!!
	nmap <leader>C :CloseSession<CR>
	" Quick save current session
	nmap <leader><leader>s :SaveSession<CR>
	" Quick delete session
	nmap <leader><leader>d :DeleteSession<CR>
endif

" ################ CtrlP settings #################
if &runtimepath =~ 'ctrlp.vim'
    nmap <leader>b :CtrlPBuffer<CR>
    nmap <leader>P :CtrlP<CR>
    let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:50'
    let g:ctrlp_map = '<C-p>'
    let g:ctrlp_working_path_mode = 'ra'
    let g:ctrlp_custom_ignore = {
                \ 'dir':  '\v[\/]\.(git|hg|svn)$',
                \ 'file': '\v\.(exe|bin|o|so|dll|pyc|zip|sw|swp)$',
                \ }
endif

" ################ NerdCommenter  #################
if &runtimepath =~ 'nerdcommenter'
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDCompactSexyComs        = 1      " Use compact syntax for prettified multi-line comments
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
    " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
    " of following code indentation
endif

" ################ #################
if &runtimepath =~ 'vim-easymotion'
    " Disable default mappings
    let g:EasyMotion_do_mapping = 0
    " Turn on ignore case
    let g:EasyMotion_smartcase = 1

    " toggle ignore case
    nmap tes :let g:EasyMotion_smartcase=1<CR>
    nmap tec :let g:EasyMotion_smartcase=0<CR>

    " <leader>f{char} to move to {char}
    " search a character in the current buffer
    nmap f <Plug>(easymotion-bd-f)
    vmap f <Plug>(easymotion-bd-f)
    " search a character in the current layout
    nmap F <Plug>(easymotion-overwin-f)
    vmap F <Plug>(easymotion-overwin-f)

    " search a character in the current line
    nmap <leader>f <Plug>(easymotion-sl)
    vmap <leader>f <Plug>(easymotion-sl)

    " Move to line
    " move to a line in the current layout
    nmap <leader>L <Plug>(easymotion-overwin-line)
    vmap <leader>L <Plug>(easymotion-overwin-line)

    " Move to word
    " move to a any word in the current buffer
    nmap <leader><leader>w <Plug>(easymotion-bd-w)
    vmap <leader><leader>w <Plug>(easymotion-bd-w)
    " move to a any word in the current layout
    nmap <leader><leader>W <Plug>(easymotion-overwin-w)
    vmap <leader><leader>W <Plug>(easymotion-overwin-w)

    " repeat the last motion
    nmap <leader>. <Plug>(easymotion-repeat)
    vmap <leader>. <Plug>(easymotion-repeat)
    " repeat the next match of the current last motion
    nmap <leader>, <Plug>(easymotion-next)
    vmap <leader>, <Plug>(easymotion-next)
    " repeat the prev match of the current last motion
    nmap <leader>; <Plug>(easymotion-prev)
    vmap <leader>; <Plug>(easymotion-prev)
endif

" ################# Themes #################

" colorscheme railscasts
if &runtimepath =~ 'vim-colorschemes'
    try
        colorscheme Monokai
    catch
        echo 'Please run :PlugInstall to complete the installation'
    endtry

    nmap cm :colorscheme Monokai<CR>
    nmap co :colorscheme onedark<CR>
    nmap cr :colorscheme railscasts<CR>
endif

" ################ Status bar Airline #################

if &runtimepath =~ 'vim-airline'
    let g:airline#extensions#tabline#enabled           = 1
    let g:airline#extensions#tabline#fnamemod          = ':t'
    let g:airline#extensions#tabline#close_symbol      = '×'
    let g:airline#extensions#tabline#show_tabs         = 1
    let g:airline#extensions#tabline#show_buffers      = 1
    let g:airline#extensions#tabline#show_close_button = 0
    let g:airline#extensions#tabline#show_splits       = 0

    " let g:airline#extensions#tabline#show_tab_nr = 0
    " Powerline fonts, check https://github.com/powerline/fonts.git for more
    " info
    let g:airline_powerline_fonts = 1
endif

if &runtimepath =~ 'vim-airline-themes'
    let g:airline_theme = 'molokai'
endif

" ################# Snnipets and completion #################

if ( has('python') || has('python3') )
" ################ UltiSnips #################
    if &runtimepath =~ 'ultisnips'
        let g:UltiSnipsSnippetDirectories=["UltiSnips"]

        if has('python3')
            let g:UltiSnipsUsePythonVersion = 3
        endif
    endif

" ################ Jedi complete #################
    if ( &runtimepath =~ 'jedi-vim' || &runtimepath =~ 'jedi'  )
        let g:jedi#popup_on_dot = 1
        let g:jedi#popup_select_first = 1
        let g:jedi#completions_command = "<C-c>"
        let g:jedi#goto_command = "<leader>g"
        let g:jedi#goto_assignments_command = "<leader>a"
        let g:jedi#goto_definitions_command = "<leader>D"
        let g:jedi#documentation_command = "K"
        let g:jedi#usages_command = "<leader>u"
        let g:jedi#rename_command = "<leader>r"
    endif

    " if ( v:version == 704 && has("patch143") )
    if &runtimepath =~ 'YouCompleteMe'
        let g:jedi#popup_on_dot = 0
        let g:jedi#popup_select_first = 0

        let g:UltiSnipsExpandTrigger="<C-x>"
        let g:UltiSnipsJumpForwardTrigger="<C-a>"
        let g:UltiSnipsJumpBackwardTrigger="<C-z>"

        " nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
        " nnoremap <leader>g :YcmCompleter GoTo<CR>
        " nnoremap <leader>r :YcmCompleter GoToReferences<CR>
        " nnoremap <leader>F :YcmCompleter FixIt<CR>
        " nnoremap <leader>D :YcmCompleter GetDoc<CR>
        " nnoremap <leader>p :YcmCompleter GetParent<CR>
        " nnoremap <leader>i :YcmCompleter GoToInclude<CR>
        " nnoremap <leader>d :YcmCompleter GoToDeclaration<CR>
        " nnoremap <leader>t :YcmCompleter GetType<CR>
    endif
    " endif
endif

" ################# Syntax check #################
if &runtimepath =~ "syntastic"
    " set sessionoptions-=blank

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    nmap ts :SyntasticToggleMode<CR>

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0

    let g:syntastic_python_checkers = ['flake8']

    imap <F5> <ESC>:SyntasticCheck<CR>a
    nmap <F5> :SyntasticCheck<CR>

    imap <F6> <ESC>:SyntasticInfo<CR>a
    nmap <F6> :SyntasticInfo<CR>

    imap <F7> <ESC>:Errors<CR>a
    nmap <F7> :Errors<CR>

    imap <F8> <ESC>:lclose<CR>a
    nmap <F8> :lclose<CR>
endif

" ################# NERDTree quick open/close #################
" Lazy load must be out of if
" Ignore files in NERDTree
let NERDTreeIgnore              = ['\.pyc$', '\~$', '\.sw$', '\.swp$']
let NERDTreeShowHidden          = 1
" If you don't have unicode, uncomment the following lines
" let NERDTreeDirArrowExpandable  = '+'
" let NERDTreeDirArrowCollapsible = '~'

"nmap T :NERDTree<CR>
nmap T :NERDTreeTabsToggle<CR>
nmap <F3> :NERDTreeTabsToggle<CR>
imap <F3> <Esc><F3>
vmap <F3> <Esc><F3>

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

" ################ Git integration #################
" ################ Fugitive #################
if &runtimepath =~ 'vim-fugitive'
    nmap gs :Gstatus<CR>
    nmap gc :Gcommit<CR>
    nmap gb :Gblame<CR>
    nmap gl :Git log<CR>
    nmap gll :Git log --oneline<CR>
    nmap go :Git checkout
    nmap gom :Git checkout master<CR>
    nmap gps :Git push
    nmap gpo :Git push origin
    nmap gpl :Git pull
    nmap gplo :Git pull origin<CR>
    nmap gpom :Git push origin master<CR>
    nmap gsa :Git stash apply
    nmap gsp :Git stash pop<CR>
endif

" ################ GitGutter #################
if &runtimepath =~ 'vim-gitgutter'
    nmap tg :GitGutterToggle<CR>
    nmap tl :GitGutterLineHighlightsToggle<CR>
endif

" ################ Signature #################
if &runtimepath =~ 'vim-signature'
    nmap <leader><leader>g :SignatureListGlobalMarks<CR>
    imap <C-s>g <ESC>:SignatureListGlobalMarks<CR>

    nmap <leader><leader>b :SignatureListBufferMarks<CR>
    imap <C-s>b <ESC>:SignatureListBufferMarks<CR>

    nmap tS :SignatureToggleSigns<CR>
endif

" ################ TagsBar #################
if &runtimepath =~ 'tagbar'
    nmap tt :TagbarToggle<CR>
    nmap <F1> :TagbarToggle<CR>
    imap <F1> :TagbarToggle<CR>
    vmap <F1> :TagbarToggle<CR>gv
endif

" ################ Move #################
if &runtimepath =~ 'vim-move'
    let g:move_key_modifier = 'C'
endif

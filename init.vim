" ############################################################################
"
"
"                               Plugin installation
"
" ############################################################################

" Specify a directory for plugins
if has("nvim")
    if has("win32") || has("win64")
        call plug#begin('~\AppData\Local\nvim\plugged')
    else
        call plug#begin('~/.config/nvim/plugged')
    endif
elseif has("win32") || has("win64")
    call plug#begin('~\vimfiles\autoload')
else
    call plug#begin('~/.vim/plugged')
endif

" Colorschemes for vim
Plug 'flazz/vim-colorschemes'

" Auto Close ' " () [] {}
Plug 'Raimondi/delimitMate'

" File explorer, and
Plug 'scrooloose/nerdtree', { 'on': [ 'NERDTreeToggle' ] }

" Easy comments
Plug 'scrooloose/nerdcommenter'

" Simulate sublime cursors
Plug 'terryma/vim-multiple-cursors'

" Status bar and some themes
Plug 'vim-airline/vim-airline' | Plug 'vim-airline/vim-airline-themes'

" Git integrations
Plug 'airblade/vim-gitgutter' | Plug 'tpope/vim-fugitive' | Plug 'rhysd/committia.vim'

" Easy aligment
Plug 'godlygeek/tabular'

" Better motions
Plug 'easymotion/vim-easymotion'

" Easy surround text objects with ' " () [] {} etc
Plug 'tpope/vim-surround'

" Better buffer deletions
Plug 'moll/vim-bbye', { 'on': [ 'Bdelete' ] }

" Visual marks
Plug 'kshenoy/vim-signature'

" Search files, buffers, etc
Plug 'kien/ctrlp.vim', { 'on': [ 'CtrlPBuffer', 'CtrlP' ] }

" Better sessions management
Plug 'xolox/vim-misc' | Plug 'xolox/vim-session'

" Improve syntax
Plug 'sheerun/vim-polyglot'

" Auto convert bin files
Plug 'fidian/hexmode'

" Collection of snippets
Plug 'honza/vim-snippets'

" Move with identation
Plug 'matze/vim-move'

" Easy edit registers
Plug 'dohsimpson/vim-macroeditor', { 'on': [ 'MacroEdit' ] }

" Better sustition, improve aibbreviations and coercion
Plug 'tpope/vim-abolish'

" Map repeat key . for plugins
Plug 'tpope/vim-repeat'

" Display indention
Plug 'Yggdroot/indentLine'

" Auto indention put command
Plug 'sickill/vim-pasta'

" Code Format tool
Plug 'chiel92/vim-autoformat'

" Easy change text
Plug 'AndrewRadev/switch.vim'

if !has("nvim")
    " Basic settings
    Plug 'tpope/vim-sensible'
endif

if executable("ctags")
    " Simple view of Tags using ctags
    Plug 'majutsushi/tagbar'
endif

let b:neomake_installed = 0
if has("nvim") || ( v:version >= 800 )
    " Async Syntaxis check
    Plug 'neomake/neomake'
    let b:neomake_installed = 1
endif

let b:ycm_installed = 0
if ( has("python") || has("python3") )
    " Snippets engine
    Plug 'SirVer/ultisnips'

    function! BuildYCM(info)
        " info is a dictionary with 3 fields
        " - name:   name of the plugin
        " - status: 'installed', 'updated', or 'unchanged'
        " - force:  set on PlugInstall! or PlugUpdate!
        if a:info.status == 'installed' || a:info.force
            " !./install.py --all
            " !./install.py --gocode-completer --tern-completer
            if executable('go')
                !./install.py --gocode-completer
            else
                !./install.py
            endif
        endif
    endfunction

" Awesome completion engine, comment the following if to deactivate ycm
    if has("nvim") || ( v:version >= 800 ) || ( v:version == 704 && has("patch143") )
        Plug 'Valloric/YouCompleteMe', { 'do': function('BuildYCM') }
        let b:ycm_installed = 1
    endif

    if b:ycm_installed==0
        " completion for python
        Plug 'davidhalter/jedi-vim'
    endif

    if b:neomake_installed==0
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
if b:ycm_installed==0
    if ( has("nvim") && has("python3") )
        Plug 'Shougo/deoplete.nvim', { 'do': ':UpdateRemotePlugins' }
        " Todo test personalize settings of deoplete
    else
        Plug 'ervandew/supertab'
        if has("lua")
            Plug 'Shougo/neocomplete.vim'
        endif
    endif
endif

" Initialize plugin system
call plug#end()

" ############################################################################
"
"                               Small improvements
"
" ############################################################################
"
filetype plugin indent on

set encoding=utf-8     " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.

let mapleader=" "
nnoremap ; :
nnoremap , :
vmap ; :
vmap , :

" Easy <ESC> insertmode
imap jj <Esc>

if !has("nvim")
    set nocompatible
endif

set splitright
set nowrap
set ruler
set showmatch    " Show matching parenthesis
set number       " Show line numbers
syntax enable    " add syntax highlighting

" cd to current file path
autocmd BufEnter * silent! lcd %:p:h

" disable sounds
set visualbell

" Trim whitespaces in selected files
autocmd FileType c,cpp,java,php,go autocmd BufWritePre <buffer> %s/\s\+$//e
autocmd FileType ruby,python,shell,vim autocmd BufWritePre <buffer> %s/\s\+$//e
autocmd FileType html,css,javascript autocmd BufWritePre <buffer> %s/\s\+$//e

" Set Syntax to *.in files
autocmd BufRead,BufNewFile *.in set filetype=conf
" Set Syntax to *.bash* and *.zsh* files
" autocmd BufRead,BufNewFile *.bash*,*.zsh* set filetype=shell
" autocmd BufReadPost *.bash*,*.zsh* set syntax=shell

" Set highlight CursorLine
hi CursorLine term=bold cterm=bold guibg=Grey40

" Indenting stuff
set autoindent
set smartindent
set copyindent
set tabstop=4       " 1 tab = 4 spaces
set shiftwidth=4    " Same for autoindenting
set expandtab       " Use  spaces for indenting
set smarttab        " Insert tabs on the start of a line according to shiftwidth, not tabstop
set shiftround      " Use multiple of shiftwidth when indenting with '<' and '>'
set magic           " change the way backslashes are used in search patterns

" Specially for html and xml
autocmd FileType xml,html,vim autocmd BufReadPre <buffer> set matchpairs+=<:>

set fileformat=unix      " file mode is unix
" Remove ^M characters from windows format
nmap <leader>R :%s/\r\+$//e

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
    if has("win32") || has("win64")
        set directory=~\AppData\Local\nvim\tmp_dirs\swap    " directory to place swap files in
        set backupdir=~\AppData\Local\nvim\tmp_dirs\backups " where to put backup files
        set undodir=~\AppData\Local\nvim\tmp_dirs\undos
        set viminfo+=n~\AppData\Local\nvim\tmp_dirs\viminfo
        " store yankring history file there too
        let g:yankring_history_dir = '~\AppData\Local\nvim\tmp_dirs'
    else
        set directory=~/.config/nvim/tmp_dirs/swap    " directory to place swap files in
        set backupdir=~/.config/nvim/tmp_dirs/backups " where to put backup files
        set undodir=~/.config/nvim/tmp_dirs/undos
        set viminfo+=n~/.config/nvim/tmp_dirs/viminfo
        " store yankring history file there too
        let g:yankring_history_dir = '~/.config/nvim/tmp_dirs/'
    endif
else
    if has("win32") || has("win64")
        set directory=~\vimfiles\tmp_dirs\swap    " directory to place swap files in
        set backupdir=~\vimfiles\tmp_dirs\backups " where to put backup files
        set undodir=~\vimfiles\tmp_dirs\undos
        set viminfo+=n~\vimfiles\tmp_dirs\viminfo
        " store yankring history file there too
        let g:yankring_history_dir = '~\vimfiles\tmp_dirs'
    else
        " vim stuff
        set directory=~/.vim/tmp_dirs/swap    " directory to place swap files in
        set backupdir=~/.vim/tmp_dirs/backups " where to put backup files
        set undodir=~/.vim/tmp_dirs/undos
        set viminfo+=n~/.vim/tmp_dirs/viminfo
        " store yankring history file there too
        let g:yankring_history_dir = '~/.vim/tmp_dirs/'
    endif
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
if has('clipboard')
    if !has("nvim") || (executable('pbcopy') || executable('xclip') || executable('xsel'))
        set clipboard=unnamed
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
set nofoldenable      " dont fold by default
set foldnestmax=10    " deepest fold is 10 levels
" set foldlevel=1       " this is just what i use

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
nmap <leader>d :Bdelete<CR>

" ################ Sessions settings #################
" Session management
" Auto save on exit
let g:session_autosave = 'yes'
" Don't ask for load last session
let g:session_autoload = 'no'

if has("nvim")
    if has("win32") || has("win64")
        let g:session_directory = '~\AppData\Local\nvim\sessions'
    else
        let g:session_directory = '~/.config/nvim/sessions'
    endif
elseif has("win32") || has("win64")
    let g:session_directory = '~\vimfiles\sessions'
endif

if &runtimepath =~ 'vim-session'
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
nmap <leader>b :CtrlPBuffer<CR>
nmap <leader>P :CtrlP<CR>
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:50'
let g:ctrlp_map = '<C-p>'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$',
            \ 'file': '\v\.(exe|bin|o|so|dll|pyc|zip|sw|swp)$',
            \ }

" ################ NerdCommenter  #################
if &runtimepath =~ 'nerdcommenter'
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDCompactSexyComs        = 1      " Use compact syntax for prettified multi-line comments
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                              " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                              " of following code indentation
    let g:NERDCustomDelimiters = {
        \ 'dosini': { 'left': '#', 'leftAlt': ';' }
        \ }
endif

" ################ EasyMotions Settings #################
if &runtimepath =~ 'vim-easymotion'
    " Disable default mappings
    let g:EasyMotion_do_mapping = 0
    " Turn on ignore case
    let g:EasyMotion_smartcase = 1

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
        echo 'Please run :PlugInstall to complete the installation or remove "colorscheme Monokai"'
    endtry

    nmap csm :colorscheme Monokai<CR>
    nmap cso :colorscheme onedark<CR>
    nmap csr :colorscheme railscasts<CR>
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

" ################ UltiSnips #################
if &runtimepath =~ 'ultisnips'
    let g:UltiSnipsSnippetDirectories=["UltiSnips"]

    if has('python3')
        let g:UltiSnipsUsePythonVersion = 3
    endif
endif

if &runtimepath =~ 'switch.vim'
    nnoremap + :call switch#Switch(g:variable_style_switch_definitions)<cr>
    nnoremap - :Switch<cr>

    autocmd FileType c,cpp let b:switch_custom_definitions =
        \ [
        \   {
        \       '^\(\k\+\)\.': '\1->',
        \       '^\(\k\+\)\->': '\1.',
        \   },
        \ ]

    autocmd FileType python let b:switch_custom_definitions =
        \ [
        \   {
        \       '^\(.*\)True': '\1False',
        \   },
        \ ]
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

if &runtimepath =~ 'neocomplete.vim'
    "Note: This option must set it in .vimrc(_vimrc).  NOT IN .gvimrc(_gvimrc)!
    " Disable AutoComplPop.
    let g:acp_enableAtStartup = 1
    " Use neocomplete.
    let g:neocomplete#enable_at_startup = 1
    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 3
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    " Define dictionary.
    " let g:neocomplete#sources#dictionary#dictionaries = {
    "     \ 'default' : '',
    "     \ 'vimshell' : $HOME.'/.vimshell_hist',
    "     \ 'scheme' : $HOME.'/.gosh_completions'
    "         \ }

    " Define keyword.
    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif
    let g:neocomplete#keyword_patterns['default'] = '\h\w*'

    " Plugin key-mappings.
    inoremap <expr><C-g>     neocomplete#undo_completion()
    inoremap <expr><C-l>     neocomplete#complete_common_string()

    " Recommended key-mappings.
    " <CR>: close popup and save indent.
    inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return neocomplete#close_popup() . "\<CR>"
        " For no inserting <CR> key.
        "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
    endfunction

    " <TAB>: completion.
    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    " <C-h>, <BS>: close popup and delete backword char.
    inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()

    " Close popup by <Space>.
    " inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

    " For cursor moving in insert mode(Not recommended)
    "inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
    "inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
    "inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
    "inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
    " Or set this.
    "let g:neocomplete#enable_cursor_hold_i = 1
    " Or set this.
    "let g:neocomplete#enable_insert_char_pre = 1

    " AutoComplPop like behavior.
    " let g:neocomplete#enable_auto_select = 1

    " Shell like behavior(not recommended).
    "set completeopt+=longest
    "let g:neocomplete#enable_auto_select = 1
    "let g:neocomplete#disable_auto_complete = 1
    "inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

    " Enable omni completion.
    autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType cs setlocal omnifunc=OmniSharp#Complete

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
        let g:neocomplete#sources#omni#input_patterns = {}
    endif
endif

if &runtimepath =~ 'YouCompleteMe'
    let g:UltiSnipsExpandTrigger       = "<C-w>"
    let g:UltiSnipsJumpForwardTrigger  = "<C-f>"
    let g:UltiSnipsJumpBackwardTrigger = "<C-b>"

    let g:ycm_complete_in_comments                      = 1
    let g:ycm_seed_identifiers_with_syntax              = 1
    let g:ycm_add_preview_to_completeopt                = 1
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion  = 1
    let g:ycm_key_detailed_diagnostics                  = '<leader>D'

    if executable("ctags")
        let g:ycm_collect_identifiers_from_tags_files = 1
    endif

    nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
    inoremap <F5> :YcmForceCompileAndDiagnostics<CR>

    nnoremap <leader>F :YcmCompleter FixIt<CR>
    nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
    nnoremap <leader>gg :YcmCompleter GoTo<CR>
    nnoremap <leader>gp :YcmCompleter GetParent<CR>
    nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
    nnoremap <leader>gt :YcmCompleter GetType<CR>

    " In case there are other completion plugins
    " let g:ycm_filetype_blacklist = {
    "       \ 'tagbar' : 1,
    "       \}
    "
    " In case there are other completion plugins
    " let g:ycm_filetype_specific_completion_to_disable = {
    "       \ 'gitcommit': 1
    "       \}
endif

" ################# Syntax check #################
if &runtimepath =~ "neomake"
    autocmd BufWrite * :Neomake

    nmap <F6> :Neomake<CR>
    imap <F6> <ESC>:Neomake<CR>a

    nmap <F7> :lopen<CR>
    imap <F7> <ESC>:lopen<CR>

    nmap <F8> :lclose<CR>
    imap <F8> <ESC>:lclose<CR>a
endif

if &runtimepath =~ "syntastic"
    " set sessionoptions-=blank
    " Set passive mode by default, can be changed with ts map
    let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": ["python", "shell"],
        \ "passive_filetypes": ["puppet"]
        \ }

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    nmap ts :SyntasticToggleMode<CR>

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0

    let g:syntastic_python_checkers = ['flake8']

    " Check Syntax in the current file
    imap <F5> <ESC>:SyntasticCheck<CR>a
    nmap <F5> :SyntasticCheck<CR>

    " Give information about current checkers
    imap <F6> <ESC>:SyntasticInfo<CR>a
    nmap <F6> :SyntasticInfo<CR>

    " Show the list of errors
    imap <F7> <ESC>:Errors<CR>a
    nmap <F7> :Errors<CR>

    " Hide the list of errors
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
nmap T :NERDTreeToggle<CR>
nmap <F3> :NERDTreeToggle<CR>
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

" ################ indentLine #################
if &runtimepath =~ 'indentLine'
    " Toggle display indent
    nmap tdi :IndentLinesToggle<CR>
    let g:indentLine_enabled = 0
    let g:indentLine_char = '┆'
endif


" ################ AutoFormat #################
if &runtimepath =~ 'vim-autoformat'
    noremap <F9> :Autoformat<CR>
    vnoremap <F9> :Autoformat<CR>gv
    autocmd FileType vim,tex,python,make,asm,conf let b:autoformat_autoindent=0
endif

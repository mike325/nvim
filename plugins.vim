" ############################################################################
"
"                               Plugin configuraitions
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
"                   `++:.                           `-/+/
"                   .`                                 `/
" ############################################################################

" ################ BufferBye settings #################
" better behave buffer deletion
nnoremap <leader>d :Bdelete!<CR>

" ################ EasyMotions Settings #################
" Temporally removed
"
" if &runtimepath =~ 'vim-easymotion'
"     " Disable default mappings
"     let g:EasyMotion_do_mapping = 0
"     " Turn on ignore case
"     let g:EasyMotion_smartcase = 1
"
"     " z{char} to move to {char}
"     " search a character in the current buffer
"     nmap \ <Plug>(easymotion-bd-f)
"     vmap \ <Plug>(easymotion-bd-f)
"     " search a character in the current layout
"     nmap <leader>\ <Plug>(easymotion-overwin-f)
"     vmap <leader>\ <Plug>(easymotion-overwin-f)
"
"     " repeat the last motion
"     nmap <leader>. <Plug>(easymotion-repeat)
"     vmap <leader>. <Plug>(easymotion-repeat)
"     " repeat the next match of the current last motion
"     nmap <leader>, <Plug>(easymotion-next)
"     vmap <leader>, <Plug>(easymotion-next)
"     " repeat the prev match of the current last motion
"     nmap <leader>; <Plug>(easymotion-prev)
"     vmap <leader>; <Plug>(easymotion-prev)
" endif

" ################ Sessions settings #################
" Session management
" Auto save on exit
let g:session_autosave = 'no'
" Don't ask for load last session
let g:session_autoload = 'no'

let g:session_directory = g:os_editor.'sessions'

if &runtimepath =~ 'vim-session'
    " nnoremap <leader>d :DeleteSession
    " Quick open session
    nnoremap <leader>o :OpenSession
    " Save current files in a session
    nnoremap <leader>s :SaveSession
    " Save the current session before close it, useful for neovim terminals
    nnoremap <leader><leader>c :SaveSession<CR>:CloseSession!<CR>
    " Quick save current session
    nnoremap <leader><leader>s :SaveSession<CR>
    " Quick delete session
    nnoremap <leader><leader>d :DeleteSession<CR>
endif

" ################ CtrlP settings #################
nnoremap <C-b> :CtrlPBuffer<CR>
nnoremap <C-p> :CtrlP<CR>
let g:ctrlp_match_window = 'bottom,order:ttb,min:1,max:30,results:50'
let g:ctrlp_map = '<C-p>'
let g:ctrlp_working_path_mode = 'ra'
let g:ctrlp_custom_ignore = {
            \ 'dir':  '\v[\/]\.(git|hg|svn)$',
            \ 'file': '\v\.(exe|bin|o|so|dll|pyc|zip|sw|swp)$',
            \ }

if &runtimepath =~ 'vim-grepper'
    " let g:grepper.tools = ['ag', 'ack', 'git', 'grep', 'findstr' ]
    " let g:grepper.highlight = 1

    " Motions for grepper command
    nmap gs  <plug>(GrepperOperator)
    xmap gs  <plug>(GrepperOperator)
endif

" ################ NerdCommenter  #################
if &runtimepath =~ 'nerdcommenter'
    let g:NERDCompactSexyComs        = 0      " Use compact syntax for prettified multi-line comments
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                              " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                              " of following code indentation
    let g:NERDCustomDelimiters = {
        \ 'dosini': { 'left': '#', 'leftAlt': ';' },
        \ 'python': { 'left': '#', 'leftAlt': '"""', 'rightAlt': '"""' }
        \ }
endif

" ################# Themes #################

if &runtimepath =~ 'gruvbox'
    try
        colorscheme gruvbox
    catch
        echo 'Please run :PlugInstall to complete the installation or remove "colorscheme gruvbox"'
    endtry

    let g:gruvbox_contrast_dark = 'hard'
    nnoremap csg :colorscheme gruvbox<CR>:AirlineTheme gruvbox<CR>
endif

if &runtimepath =~ 'vim-monokai'
    nnoremap csm :colorscheme monokai<CR>:AirlineTheme molokai<CR>
endif

if &runtimepath =~ 'jellybeans.vim'
    nnoremap csj :colorscheme jellybeans<CR>:AirlineTheme solarized<CR>
endif

if &runtimepath =~ 'onedark'
    nnoremap cso :colorscheme onedark<CR>:AirlineTheme solarized<CR>
endif

if &runtimepath =~ 'vim-gotham'
    " b for batman
    nnoremap csb :colorscheme gotham<CR>:AirlineTheme gotham<CR>
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
    " let g:airline_theme = 'molokai'
    " let g:airline_theme = 'solarized'
    let g:airline_theme = 'gruvbox'
endif

" ################# Snnipets and completion #################

" ################ SnipMate #################
if &runtimepath =~ 'vim-snipmate'
    imap <C-k> <Plug>snipMateNextOrTrigger
    smap <C-k> <Plug>snipMateNextOrTrigger
endif

" ################ UltiSnips #################
if &runtimepath =~ 'ultisnips'
    let g:UltiSnipsSnippetDirectories=["UltiSnips"]

    if has('python3')
        let g:UltiSnipsUsePythonVersion = 3
    endif

    let g:UltiSnipsExpandTrigger       = "<C-k>"
    let g:UltiSnipsJumpForwardTrigger  = "<C-f>"
    let g:UltiSnipsJumpBackwardTrigger = "<C-b>"
endif

" ################ Jedi complete #################
if  &runtimepath =~ 'jedi-vim'
    autocmd FileType python let b:jedi#popup_on_dot = 1
    autocmd FileType python let b:jedi#popup_select_first = 1
    autocmd FileType python let b:jedi#completions_command = "<C-c>"
    autocmd FileType python let b:jedi#goto_command = "<leader>g"
    autocmd FileType python let b:jedi#goto_assignments_command = "<leader>a"
    autocmd FileType python let b:jedi#goto_definitions_command = "<leader>D"
    autocmd FileType python let b:jedi#documentation_command = "K"
    autocmd FileType python let b:jedi#usages_command = "<leader>u"
    autocmd FileType python let b:jedi#rename_command = "<leader>r"
endif

" TODO path completion should be improve
if &runtimepath =~ 'SimpleAutoComplPop'
    autocmd FileType * call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
        \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd FileType go call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$'   , 'feedkeys': "\<C-x>\<C-n>"} ,
        \ { '=~': '\.$'              , 'feedkeys': "\<C-x>\<C-o>"  , "ignoreCompletionMode":1} ,
        \ { '=~': '/'                , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
    \ ]})

      " This is because if python is active jedi will provide completion
    if ( has("python") || has("python3") )
        autocmd FileType python call sacp#enableForThisBuffer({ "matches": [
            \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
            \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
        \ ]})
    else
        autocmd FileType python call sacp#enableForThisBuffer({ "matches": [
            \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
            \ { '=~': '\.$'            , 'feedkeys': "\<C-x>\<C-o>"  , "ignoreCompletionMode":1} ,
            \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
        \ ]})
    endif

    autocmd FileType javascript,java call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<C-x>\<C-o>"  , "ignoreCompletionMode":1} ,
        \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd BufNewFile,BufRead,BufEnter *.cpp,*.hpp call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<C-x>\<C-o>"  , "ignoreCompletionMode":1} ,
        \ { '=~': '::$'            , 'feedkeys': "\<C-x>\<C-o>"} ,
        \ { '=~': '->$'            , 'feedkeys': "\<C-x>\<C-o>"} ,
        \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
    \ ]})

    autocmd BufNewFile,BufRead,BufEnter *.c,*.h call sacp#enableForThisBuffer({ "matches": [
        \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-n>"} ,
        \ { '=~': '\.$'            , 'feedkeys': "\<C-x>\<C-o>"  , "ignoreCompletionMode":1} ,
        \ { '=~': '->$'            , 'feedkeys': "\<C-x>\<C-o>"} ,
        \ { '=~': '/'              , 'feedkeys': "\<C-x>\<C-f>"  , "ignoreCompletionMode":1} ,
    \ ]})
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
    inoremap <expr><C-y>  neocomplete#close_popup()
    inoremap <expr><C-e>  neocomplete#cancel_popup()

    " Close popup by <Space>.
    " inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

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

    " Enable heavy omni completion.
    if !exists('g:neocomplete#sources#omni#input_patterns')
        let g:neocomplete#sources#omni#input_patterns = {}
    endif
endif

if &runtimepath =~ 'deoplete.nvim'
    let g:deoplete#enable_at_startup = 1

    " Use smartcase.
    let g:deoplete#enable_smart_case = 1
    let g:deoplete#enable_refresh_always = 1

    " Set minimum syntax keyword length.
    let g:deoplete#sources#syntax#min_keyword_length = 1
    let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

    imap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
    function! s:my_cr_function()
        return (pumvisible() ? "\<C-y>" : "" ) . "\<CR>"
    endfunction

    inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
    inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
    inoremap <expr><C-y>  deoplete#mappings#smart_close_popup()
    inoremap <expr><C-e>  deoplete#cancel_popup()

    let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})

    let g:deoplete#omni#input_patterns.java = [
                \'[^. \t0-9]\.\w*',
                \]

    let g:deoplete#omni#input_patterns.c = [
                \'[^. \t0-9]\.\w*',
                \'[^. \t0-9]\->\w*',
                \'[^. \t0-9]\::\w*',
                \]

    let g:deoplete#omni#input_patterns.cpp = [
                \'[^. \t0-9]\.\w*',
                \'[^. \t0-9]\->\w*',
                \'[^. \t0-9]\::\w*',
                \]

    let g:deoplete#omni#input_patterns.python = [
                \'[^. \t0-9]\.\w*',
                \]

    let g:deoplete#omni#input_patterns.go = [
                \'[^. \t0-9]\.\w*',
                \]

    " let g:deoplete#sources._ = ['buffer']
    " let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tags', 'ultisnips']

    " if !exists('g:deoplete#omni#input_patterns')
    "     let g:deoplete#omni#input_patterns = {}
    " endif

    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    call deoplete#custom#set('ultisnips', 'matchers', ['matcher_full_fuzzy'])
endif

if &runtimepath =~ 'vim-javacomplete2'
    nnoremap <leader>si <Plug>(JavaComplete-Imports-AddSmart)
    nnoremap <leader>mi <Plug>(JavaComplete-Imports-AddMissing)
endif

if &runtimepath =~ 'deoplete-jedi'
    let g:deoplete#sources#jedi#enable_cache   = 1
    let g:deoplete#sources#jedi#show_docstring = 1
endif

if &runtimepath =~ 'deoplete-clang'
    " Set posible locations in linux
    " /usr/lib/libclang.so
    " /usr/lib/clang
    let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
    let g:deoplete#sources#clang#clang_header  = '/usr/lib/clang'
endif

if &runtimepath =~ 'deoplete-go'
    let g:deoplete#sources#go             = 'vim-go'
    let g:deoplete#sources#go#sort_class  = ['package', 'func', 'type', 'var', 'const']
    let g:deoplete#sources#go#use_cache   = 1
    let g:deoplete#sources#go#package_dot = 1
endif

if &runtimepath =~ 'YouCompleteMe'
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


if &runtimepath =~ 'completor.vim'
    inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<Tab>"
    inoremap <expr> <S-Tab> pumvisible() ? "\<C-p>" : "\<S-Tab>"
    inoremap <expr> <cr> pumvisible() ? "\<C-y>\<cr>" : "\<cr>"
endif

" ################# Syntax check #################
if &runtimepath =~ "neomake"
    autocmd! BufWritePost * Neomake

    let g:neomake_warning_sign = {
        \ 'text': 'W',
        \ 'texthl': 'WarningMsg',
        \ }

    let g:neomake_error_sign = {
        \ 'text': 'E',
        \ 'texthl': 'ErrorMsg',
        \ }

    nnoremap <F6> :Neomake<CR>
    imap <F6> <ESC>:Neomake<CR>a

    nnoremap <F7> :lopen<CR>
    imap <F7> <ESC>:lopen<CR>

    nnoremap <F8> :lclose<CR>
    imap <F8> <ESC>:lclose<CR>a
endif

if &runtimepath =~ "syntastic"
    " set sessionoptions-=blank
    " Set passive mode by default, can be changed with ts map
    let g:syntastic_mode_map = {
        \ "mode": "passive",
        \ "active_filetypes": ["python", "sh"],
        \ "passive_filetypes": ["puppet"]
        \ }

    set statusline+=%#warningmsg#
    set statusline+=%{SyntasticStatuslineFlag()}
    set statusline+=%*

    nnoremap ts :SyntasticToggleMode<CR>

    let g:syntastic_always_populate_loc_list = 1
    let g:syntastic_auto_loc_list = 1
    let g:syntastic_check_on_open = 0
    let g:syntastic_check_on_wq = 0

    let g:syntastic_python_checkers = ['flake8']

    " Check Syntax in the current file
    imap <F5> <ESC>:SyntasticCheck<CR>a
    nnoremap <F5> :SyntasticCheck<CR>

    " Give information about current checkers
    imap <F6> <ESC>:SyntasticInfo<CR>a
    nnoremap <F6> :SyntasticInfo<CR>

    " Show the list of errors
    imap <F7> <ESC>:Errors<CR>a
    nnoremap <F7> :Errors<CR>

    " Hide the list of errors
    imap <F8> <ESC>:lclose<CR>a
    nnoremap <F8> :lclose<CR>
endif

" ################# NERDTree quick open/close #################
" Lazy load must be out of if
" Ignore files in NERDTree
let NERDTreeIgnore              = ['\.pyc$', '\~$', '\.sw$', '\.swp$']
let NERDTreeShowBookmarks       = 1
" let NERDTreeShowHidden          = 1

" If you don't have unicode, uncomment the following lines
" let NERDTreeDirArrowExpandable  = '+'
" let NERDTreeDirArrowCollapsible = '~'

nnoremap T :NERDTreeToggle<CR>
nnoremap <F3> :NERDTreeToggle<CR>
imap <F3> <Esc><F3>
vmap <F3> <Esc><F3>

" ################ Alignment with Tabularize #################
if &runtimepath =~ 'tabular'
    nnoremap <leader>t= :Tabularize /=<CR>
    vmap <leader>t= :Tabularize /=<CR>

    nnoremap <leader>t: :Tabularize /:<CR>
    vmap <leader>t: :Tabularize /:<CR>

    nnoremap <leader>t" :Tabularize /"<CR>
    vmap <leader>t" :Tabularize /"<CR>

    nnoremap <leader>t# :Tabularize /#<CR>
    vmap <leader>t# :Tabularize /#<CR>

    nnoremap <leader>t* :Tabularize /*<CR>
    vmap <leader>t* :Tabularize /*<CR>
endif

" ################ Fugitive #################
if &runtimepath =~ 'vim-fugitive'
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gd :Gdiff<CR>
    nnoremap <leader>gw :Gwrite<CR>
endif

" ################ GitGutter #################
if &runtimepath =~ 'vim-gitgutter'
    nnoremap tg :GitGutterToggle<CR>
    nnoremap tl :GitGutterLineHighlightsToggle<CR>
    let g:gitgutter_map_keys = 0

    nmap [h <Plug>GitGutterPrevHunk
    nmap ]h <Plug>GitGutterNextHunk

    nmap <leader>ghs <Plug>GitGutterStageHunk
    nmap <leader>ghu <Plug>GitGutterUndoHunk

    omap ih <Plug>GitGutterTextObjectInnerPending
    omap ah <Plug>GitGutterTextObjectOuterPending
    xmap ih <Plug>GitGutterTextObjectInnerVisual
    xmap ah <Plug>GitGutterTextObjectOuterVisual
endif

" ################ Signature #################
if &runtimepath =~ 'vim-signature'
    nnoremap <leader><leader>g :SignatureListGlobalMarks<CR>
    imap <C-s>g <ESC>:SignatureListGlobalMarks<CR>

    nnoremap <leader><leader>b :SignatureListBufferMarks<CR>
    imap <C-s>b <ESC>:SignatureListBufferMarks<CR>

    nnoremap tS :SignatureToggleSigns<CR>
endif

" ################ TagsBar #################
if &runtimepath =~ 'tagbar'
    nnoremap tt :TagbarToggle<CR>
    nnoremap <F1> :TagbarToggle<CR>
    imap <F1> :TagbarToggle<CR>
    vmap <F1> :TagbarToggle<CR>gv
endif

" ################ Move #################
if &runtimepath =~ 'vim-move'
    " Set Ctrl key as default. Commands <C-j> and <C-k>
    let g:move_key_modifier = 'C'
endif

" ################ indentLine #################
if &runtimepath =~ 'indentLine'
    " Show indentation lines
    nnoremap tdi :IndentLinesToggle<CR>
    let g:indentLine_enabled = 1
    let g:indentLine_char    = '┊'

    " augroup VisualIndent
    "     autocmd!
    "     autocmd FileType text autocmd BufReadPre IndentLinesDisable
    "     autocmd FileType * autocmd BufReadPre IndentLinesEnable
    " augroup END

endif

" ################ AutoFormat #################
if &runtimepath =~ 'vim-autoformat'
    noremap <F9> :Autoformat<CR>
    vnoremap <F9> :Autoformat<CR>gv
    autocmd! BufWritePost * Autoformat
    autocmd FileType markdown,vim,tex,python,make,asm,conf let b:autoformat_autoindent=0
endif

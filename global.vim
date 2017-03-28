" ############################################################################
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
"                   `++:.                           `-/+/
"                   .`                                 `/
" ############################################################################

" BasicImprovements {{{

set encoding=utf-8     " The encoding displayed.
set fileencoding=utf-8 " The encoding written to file.

let mapleader=" "

nnoremap , :
vnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual select the <CR> character
vnoremap $ $h

" Easy <ESC> insert mode
imap jj <Esc>

" Disable some vi compatibility
if !has("nvim")
    set ttyfast
    set nocompatible
endif

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

if (has("nvim"))
    " Live substitute preview
    set inccommand=split
endif

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

if v:version > 704 || v:version == 704 && has('patch338') || has("nvim")
    set breakindent " respect indentation when wrapping
endif

set shiftround     " Use multiple of shiftwidth when indenting with '<' and '>'
set cursorline     " Turn on cursor line by default

"" Text formating
set formatoptions+=r " auto insert comment with <Enter>...
set formatoptions+=o " ...or o/O
set formatoptions+=n " Recognize numbered lists

if v:version > 703 || v:version == 703 && has('patch541') || has("nvim")
   set formatoptions+=j " Delete comment when joining commented lines
endif

" Set path to look recursive in the current dir
set path+=**

" Set vertical diff
set diffopt+=vertical

" Disable sounds
set visualbell " visual bell instead of beeps, but...
if !has('nvim')
   set t_vb= " ...disable the visual effect :)
endif

set fileformats=unix,dos " File mode unix by default

hi CursorLine term=bold cterm=bold guibg=Grey40

" Folding settings
set foldmethod=indent " fold based on indent
set nofoldenable      " dont fold by default
set foldnestmax=10    " deepest fold is 10 levels
" set foldlevel=1

" TODO make a funtion to save the state of the toggles
augroup Numbers
    autocmd!
    autocmd BufEnter * setlocal relativenumber
    autocmd BufEnter * setlocal number
    autocmd BufLeave * setlocal norelativenumber
    autocmd InsertEnter * setlocal norelativenumber
    autocmd InsertEnter * setlocal number
    autocmd InsertLeave * setlocal relativenumber
    autocmd InsertLeave * setlocal number
    autocmd FileType help setlocal number
    autocmd FileType help setlocal relativenumber
augroup end

if has("nvim")
    " Set modifiable to use easymotions
    " autocmd TermOpen * setlocal modifiable

    " I like to see the numbers in the terminal
    autocmd TermOpen * setlocal relativenumber
    autocmd TermOpen * setlocal number

    " Better splits
    nnoremap <A-s> <C-w>s
    nnoremap <A-v> <C-w>v

    " Better terminal access
    nnoremap <A-t> :terminal<CR>

    " Use ESC to exit terminal mode
    tnoremap <Esc> <C-\><C-n>
endif

" }}} EndBasicImprovements

" VimFiles {{{

" Better backup, swap and undos storage
set backup   " make backup files
set undofile " persistent undos - undo after you re-open the file

if has("win32") || has("win64")
    execute 'set directory='.fnameescape(g:os_editor.'tmp_dirs\swap')
    execute 'set backupdir='.fnameescape(g:os_editor.'tmp_dirs\backup')
    execute 'set undodir='.fnameescape(g:os_editor.'tmp_dirs\undos')
    " execute 'set viminfo+=n'.fnameescape(g:os_editor.'tmp_dirs\viminfo')

    " TODO make the windows method works as the Unix one
    if has("nvim")
        set viminfo+=n$USERPROFILE\\AppData\\Local\\nvim\\tmp_dirs\\viminfo
    else
        set viminfo+=n$USERPROFILE\\vimfiles\\tmp_dirs\\viminfo
    endif

    let g:yankring_history_dir = g:os_editor.'tmp_dirs\yank'
else
    execute 'set directory='.fnameescape(g:os_editor.'tmp_dirs/swap')
    execute 'set backupdir='.fnameescape(g:os_editor.'tmp_dirs/backup')
    execute 'set undodir='.fnameescape(g:os_editor.'tmp_dirs/undos')
    execute 'set viminfo+=n'.fnameescape(g:os_editor.'tmp_dirs/viminfo')

    let g:yankring_history_dir = g:os_editor.'tmp_dirs/yank'
endif

" If the dirs does't exists, create them
if !isdirectory(&backupdir)
    call mkdir(&backupdir, "p")
endif

if !isdirectory(&directory)
    call mkdir(&directory, "p")
endif

if !isdirectory(&undodir)
    call mkdir(&undodir, "p")
endif

" }}} EndVimFiles

" GUISettings {{{

if has("gui_running")
    set guioptions-=m  "no menu
    set guioptions-=T  "no toolbar
    set guioptions-=L  "remove left-hand scroll bar in vsplit
    set guioptions-=l  "remove left-hand scroll bar
    set guioptions-=r  "remove right-hand scroll bar
    set guioptions-=R  "remove right-hand scroll bar vsplit
    set guioptions-=b  "remove bottom scroll bar

    " Windoes gVim fonts
    if has("win32") || has("win64")
        set guifont=DejaVu_Sans_Mono_for_Powerline:h11,DejaVu_Sans_Mono:h11
    endif
endif

" }}} EndGUISettings


" JustSomeStuff {{{

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" TODO To be improve
function! RemoveTrailingWhitespaces()
    "Save last cursor position
    let savepos = getpos('.')
    %s/\s\+$//e
    call setpos('.', savepos)
endfunction

" Trim whitespaces in selected files
" autocmd FileType * autocmd BufWritePre <buffer> %s/\s\+$//e
autocmd FileType * autocmd BufWritePre <buffer> call RemoveTrailingWhitespaces()

" Specially helpful for html and xml
autocmd FileType xml,html,vim autocmd BufReadPre <buffer> set matchpairs+=<:>

" Add lines in normal mode without enter in insert mode
nnoremap <C-o> O<Esc>
nmap Q o<Esc>

" Remove stuff in normal/visul mode without change any register
nnoremap <BS> "_
vnoremap <BS> "_

" Easy indentation in normal mode
nnoremap <tab> >>
nnoremap <S-tab> <<

vnoremap <tab> >gv
vnoremap <S-tab> <gv

nnoremap <F2> :update<CR>
vmap <F2> <Esc><F2>gv
imap <F2> <Esc><F2>a

" For systems without F's keys (ex. android)
nmap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" Native explorer
nnoremap E :Explore<CR>
let g:netrw_liststyle=3

" Color columns
if exists('+colorcolumn')
    " let &colorcolumn="80,".join(range(120,999),",")
    " Visual ruler
    let &colorcolumn="80"
endif

" }}} EndJustSomeStuff

" Clipboard {{{
if has('clipboard')
    if !has("nvim") || ( executable('pbcopy') || executable('xclip') ||
                \ executable('xsel') || executable("lemonade") )
        set clipboard+=unnamedplus,unnamed
    endif
elseif has("nvim")
    " If system clipboard is not available, disable the mouse selection
    set mouse=c
endif

" }}} EndClipboard

" Next and previous {{{
" Took from https://github.com/tpope/vim-unimpaired
" TODO may fork and remove stuff
"
"  The following maps all correspond to normal mode commands.  If a count is
"  given, it becomes an argument to the command.  A mnemonic for the 'a' commands
"  is 'args' and for the 'q' commands is 'quickfix'.
"
"  *[a*     |:previous|
"  *]a*     |:next|
"  *[A*     |:first|
"  *]A*     |:last|
"  *[b*     |:bprevious|
"  *]b*     |:bnext|
"  *[B*     |:bfirst|
"  *]B*     |:blast|
"  *[l*     |:lprevious|
"  *]l*     |:lnext|
"  *[L*     |:lfirst|
"  *]L*     |:llast|
"  *[<C-L>* |:lpfile|
"  *]<C-L>* |:lnfile|
"  *[q*     |:cprevious|
"  *]q*     |:cnext|
"  *[Q*     |:cfirst|
"  *]Q*     |:clast|
"  *[<C-Q>* |:cpfile| (Note that <C-Q> only works in a terminal if you disable
"  *]<C-Q>* |:cnfile| flow control: stty -ixon)
"  *[t*     |:tprevious|
"  *]t*     |:tnext|
"  *[T*     |:tfirst|
"  *]T*     |:tlast|

function! s:MapNextFamily(map,cmd)
    let map = '<Plug>unimpaired'.toupper(a:map)
    let cmd = '".(v:count ? v:count : "")."'.a:cmd
    let end = '"<CR>'.(a:cmd == 'l' || a:cmd == 'c' ? 'zv' : '')
    execute 'nnoremap <silent> '.map.'Previous :<C-U>exe "'.cmd.'previous'.end
    execute 'nnoremap <silent> '.map.'Next     :<C-U>exe "'.cmd.'next'.end
    execute 'nnoremap <silent> '.map.'First    :<C-U>exe "'.cmd.'first'.end
    execute 'nnoremap <silent> '.map.'Last     :<C-U>exe "'.cmd.'last'.end
    execute 'nmap <silent> ['.        a:map .' '.map.'Previous'
    execute 'nmap <silent> ]'.        a:map .' '.map.'Next'
    execute 'nmap <silent> ['.toupper(a:map).' '.map.'First'
    execute 'nmap <silent> ]'.toupper(a:map).' '.map.'Last'
    if exists(':'.a:cmd.'nfile')
        execute 'nnoremap <silent> '.map.'PFile :<C-U>exe "'.cmd.'pfile'.end
        execute 'nnoremap <silent> '.map.'NFile :<C-U>exe "'.cmd.'nfile'.end
        execute 'nmap <silent> [<C-'.a:map.'> '.map.'PFile'
        execute 'nmap <silent> ]<C-'.a:map.'> '.map.'NFile'
    endif
endfunction

call s:MapNextFamily('a','')
call s:MapNextFamily('b','b')
call s:MapNextFamily('l','l')
call s:MapNextFamily('q','c')
call s:MapNextFamily('t','t')

function! s:entries(path)
    let path = substitute(a:path,'[\\/]$','','')
    let files = split(glob(path."/.*"),"\n")
    let files += split(glob(path."/*"),"\n")
    call map(files,'substitute(v:val,"[\\/]$","","")')
    call filter(files,'v:val !~# "[\\\\/]\\.\\.\\=$"')

    let filter_suffixes = substitute(escape(&suffixes, '~.*$^'), ',', '$\\|', 'g') .'$'
    call filter(files, 'v:val !~# filter_suffixes')

    return files
endfunction

function! s:FileByOffset(num)
    let file = expand('%:p')
    let num = a:num
    while num
        let files = s:entries(fnamemodify(file,':h'))
        if a:num < 0
            call reverse(sort(filter(files,'v:val <# file')))
        else
            call sort(filter(files,'v:val ># file'))
        endif
        let temp = get(files,0,'')
        if temp == ''
            let file = fnamemodify(file,':h')
        else
            let file = temp
            while isdirectory(file)
                let files = s:entries(file)
                if files == []
                    " TODO: walk back up the tree and continue
                    break
                endif
                let file = files[num > 0 ? 0 : -1]
            endwhile
            let num += num > 0 ? -1 : 1
        endif
    endwhile
    return file
endfunction

function! s:fnameescape(file) abort
    if exists('*fnameescape')
        return fnameescape(a:file)
    else
        return escape(a:file," \t\n*?[{`$\\%#'\"|!<")
    endif
endfunction

nnoremap <silent> <Plug>unimpairedDirectoryNext     :<C-U>edit <C-R>=fnamemodify(<SID>fnameescape(<SID>FileByOffset(v:count1)), ':.')<CR><CR>
nnoremap <silent> <Plug>unimpairedDirectoryPrevious :<C-U>edit <C-R>=fnamemodify(<SID>fnameescape(<SID>FileByOffset(-v:count1)), ':.')<CR><CR>
nmap ]f <Plug>unimpairedDirectoryNext
nmap [f <Plug>unimpairedDirectoryPrevious

nmap <silent> <Plug>unimpairedONext     <Plug>unimpairedDirectoryNext:echohl WarningMSG<Bar>echo "]o is deprecated. Use ]f"<Bar>echohl NONE<CR>
nmap <silent> <Plug>unimpairedOPrevious <Plug>unimpairedDirectoryPrevious:echohl WarningMSG<Bar>echo "[o is deprecated. Use [f"<Bar>echohl NONE<CR>
nmap ]o <Plug>unimpairedONext
nmap [o <Plug>unimpairedOPrevious

" }}}1

" Diff {{{
nmap [n <Plug>unimpairedContextPrevious
nmap ]n <Plug>unimpairedContextNext
omap [n <Plug>unimpairedContextPrevious
omap ]n <Plug>unimpairedContextNext

nnoremap <silent> <Plug>unimpairedContextPrevious :call <SID>Context(1)<CR>
nnoremap <silent> <Plug>unimpairedContextNext     :call <SID>Context(0)<CR>
onoremap <silent> <Plug>unimpairedContextPrevious :call <SID>ContextMotion(1)<CR>
onoremap <silent> <Plug>unimpairedContextNext     :call <SID>ContextMotion(0)<CR>

function! s:Context(reverse)
    call search('^\(@@ .* @@\|[<=>|]\{7}[<=>|]\@!\)', a:reverse ? 'bW' : 'W')
endfunction

function! s:ContextMotion(reverse)
    if a:reverse
        -
    endif
    call search('^@@ .* @@\|^diff \|^[<=>|]\{7}[<=>|]\@!', 'bWc')
    if getline('.') =~# '^diff '
        let end = search('^diff ', 'Wn') - 1
        if end < 0
            let end = line('$')
        endif
    elseif getline('.') =~# '^@@ '
        let end = search('^@@ .* @@\|^diff ', 'Wn') - 1
        if end < 0
            let end = line('$')
        endif
    elseif getline('.') =~# '^=\{7\}'
        +
        let end = search('^>\{7}>\@!', 'Wnc')
    elseif getline('.') =~# '^[<=>|]\{7\}'
        let end = search('^[<=>|]\{7}[<=>|]\@!', 'Wn') - 1
    else
        return
    endif
    if end > line('.')
        execute 'normal! V'.(end - line('.')).'j'
    elseif end == line('.')
        normal! V
    endif
endfunction

" }}}1 End of unimpaired

" TabBufferManagement {{{

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

" Next buffer
nnoremap <leader>n :bn<CR>

" Prev buffer
nnoremap <leader>p :bp<CR>

nnoremap <C-x> <C-w><C-w>

" Buffer movement
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l

" Equally resize buffer splits
nnoremap <leader>e <C-w>=

" }}} EndTabBufferManagement

" Toggles {{{
nnoremap tn :set number!<Bar>set number?<CR>
nnoremap tr :set relativenumber!<Bar>set relativenumber?<CR>

nnoremap th :set hlsearch!<Bar>set hlsearch?<CR>
nnoremap ti :set ignorecase!<Bar>set ignorecase?<CR>

nnoremap tw :set wrap!<Bar>set wrap?<CR>

nnoremap tcl :set cursorline!<Bar>set cursorline?<CR>
nnoremap tcc :set cursorcolumn!<Bar>set cursorcolumn?<CR>

nnoremap tss :setlocal spell!<Bar>set spell?<CR>
nnoremap tse :setlocal spelllang=en_us<Bar>set spelllang?<CR>
nnoremap tsm :setlocal spelllang=es_mx<Bar>set spelllang?<CR>

nnoremap td :<C-R>=&diff ? 'diffoff' : 'diffthis'<CR><CR>

" }}} EndToggles

"  TerminalColors {{{
set background=dark

if (has("nvim"))
    " Neovim colors stuff
    let $NVIM_TUI_ENABLE_TRUE_COLOR=1
endif

if has("termguicolors")
    " set terminal colors
    set termguicolors
endif

"  }}} EndTerminalColors

" SetSyntax {{{
augroup filetypedetect
    autocmd BufNewFile,BufRead .tmux.conf*,tmux.conf* set filetype=tmux
    autocmd BufNewFile,BufRead .nginx.conf*,nginx.conf* set filetype=nginx
    autocmd BufRead,BufNewFile *.in,*.simics,*.si,*.sle set filetype=conf
    autocmd BufRead,BufNewFile *.bash* set filetype=sh
augroup end

" }}} EndSetSyntax

" Omnicomplete {{{
" *currently no all functions work

" Default omnicomplete func
set omnifunc=syntaxcomplete#Complete

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
augroup end

" }}} EndOmnicomplete

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType gitcommit setlocal spell
    autocmd FileType markdown setlocal spell
    autocmd FileType tex setlocal spell
    autocmd FileType plaintex setlocal spell
    autocmd FileType text setlocal spell
    autocmd FileType help setlocal nospell
augroup end
" }}} EndSpell

" Skeletons {{{
" TODO: Improve personalization of the templates

function! CMainOrFunc()

    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    if b:extension =~# "^cpp$"
        if b:file_name =~# "^main$"
            exec '0r '.fnameescape(g:os_editor.'skeletons/main.cpp')
        else
            exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.cpp')
        endif
    else
        if b:file_name =~# "^main$"
            exec '0r '.fnameescape(g:os_editor.'skeletons/main.c')
        else
            exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.c')
        endif
    endif

endfunction

function! CHeader()

    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    let b:upper_name = toupper(b:file_name)

    if b:extension =~# "^cpp$"
        exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.h')
        exec '%s/NAME_HPP/'.b:upper_name.'_HPP/g'
    else
        exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.hpp')
        exec '%s/NAME_H/'.b:upper_name.'_H/g'
    endif

endfunction

function! JavaClass()
    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.java')
    exec '%s/NAME/'.b:file_name.'/e'
endfunction

augroup Skeletons
    autocmd!
    autocmd BufNewFile *.css  exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.css')
    autocmd BufNewFile *.html exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.html')
    autocmd BufNewFile *.md   exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.md')
    autocmd BufNewFile *.py   exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.py')
    autocmd BufNewFile *.go   exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.go')
    autocmd BufNewFile *.cs   exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.cs')
    autocmd BufNewFile *.php  exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.php')
    autocmd BufNewFile *.sh   exec '0r '.fnameescape(g:os_editor.'skeletons/skeleton.sh')
    autocmd BufNewFile *.java call JavaClass()
    autocmd BufNewFile *.cpp  call CMainOrFunc()
    autocmd BufNewFile *.hpp  call CHeader()
    autocmd BufNewFile *.c    call CMainOrFunc()
    autocmd BufNewFile *.h    call CHeader()
augroup end

" }}} EndSkeletons

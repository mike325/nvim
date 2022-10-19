" vimrc Settings
" github.com/mike325/.vim

set nocompatible

if v:version >= 800
    silent! packadd! cfilter
endif

if v:version >= 704 && !has('nvim')
    silent! packadd! matchparen
    silent! packadd! matchit
endif

" ------------------------------------------------------------------------------
" Functions
" ------------------------------------------------------------------------------

let s:arrows = -1
let s:gitversion = ''
let s:moderngit = -1

let s:ignores_patterns = {
            \   'bin': [ 'exe', 'dat',],
            \   'vcs': [ 'hg', 'svn', 'git',],
            \   'compile' : ['obj', 'class', 'pyc', 'o', 'dll', 'a', 'moc',],
            \   'tmp_dirs': [ 'trash', 'tmp', '__pycache__', 'ropeproject'],
            \   'vim_dirs': [ 'backup', 'swap', 'sessions', 'cache', 'undos',],
            \   'tmp_file' : ['swp', 'bk',],
            \   'docs': ['docx', 'doc', 'xls', 'xlsx', 'odt', 'ppt', 'pptx', 'pdf',],
            \   'image': ['jpg', 'jpeg', 'png', 'gif', 'raw'],
            \   'video': ['mp4', 'mpeg', 'avi', 'mkv', '3gp'],
            \   'logs': ['log',],
            \   'compress': ['zip', 'tar', 'rar', '7z',],
            \   'full_name_files': ['tags', 'cscope', 'shada', 'viminfo', 'COMMIT_EDITMSG'],
            \}

" Set the default work dir
let s:basedir = ''
let s:homedir = ''
let s:datadir = ''
let s:cache   = ''

function! s:has_patch(patch) abort
    return has('patch-'.a:patch)
endfunction

function! s:has_augroup(augroup) abort
    return exists('#'.a:augroup)
endfunction

function! s:has_autocmd(autocmd) abort
    return exists('##'.a:autocmd)
endfunction

function! s:has_cmd(cmd) abort
    return exists(':'.a:cmd)
endfunction

function! s:has_func(func) abort
    return exists('*'.a:func)
endfunction

function! s:has_option(option) abort
    return exists('+'.a:option)
endfunction

function! s:has_variable(variable) abort
    return exists(a:variable)
endfunction

function! s:has_plugin(plugin) abort
    if exists('g:plugs')
        return has_key(g:plugs, a:plugin)
    endif
    return 0
endfunction

function! s:os_get_type() abort
    let l:name = 'unknown'
    if has('win32unix')
        let l:name = 'cygwin'
    elseif has('wsl')
        let l:name = 'wsl'
    elseif has('win16') || has('win32') || has('win64')
        let l:name = 'windows'
    elseif has('gui_mac') || has('mac') || has('macos') || has('macunix')
        let l:name = 'mac'
    elseif has('unix')
        let l:name = 'unix'
    endif
    return l:name
endfunction

function! s:os_type(os) abort
    let l:is_type = 0
    if a:os ==# 'cygwin' || a:os =~# '^msys\(2\)\?$'
        let l:is_type = (has('win32unix'))
    elseif a:os ==# 'wsl'
        let l:is_type = has('wsl')
    elseif a:os ==# 'windows' || a:os ==# 'win32'
        let l:is_type = (has('win16') || has('win32') || has('win64'))
    elseif a:os ==# 'mac' || a:os ==# 'macos' || a:os ==# 'osx'
        let l:is_type = (has('gui_mac') || has('mac') || has('macos') || has('macunix'))
        " Avoid false negative
        if l:is_type == 0 && executable('uname')
            let l:uname = substitute(system('uname'), '\n', '', '')
            let l:is_type = l:uname ==? 'darwin' || l:uname ==? 'mac'
        endif
    elseif a:os ==# 'linux' || a:os ==# 'unix'
        let l:is_type = (has('unix'))
    endif
    return l:is_type
endfunction

function! s:os_cache() abort
    if has('nvim-0.2')
        return stdpath('cache')
    elseif !empty($XDG_CACHE_HOME)
        return $XDG_CACHE_HOME . '/nvim'
    endif
    " Point vim to nvim cache since some lsp are install here
    return s:vars_home() . '/.cache/nvim'
endfunction

" Windows wrapper
function! s:os_name(...) abort
    return (a:0 > 0) ? s:os_type(a:1) : s:os_get_type()
endfunction

function! s:os_tmpdir() abort
    return  s:os_name('windows') ?  'c:/temp' : '/tmp'
endfunction

function! s:os_tmp(place) abort
    let l:temp = s:os_name('windows') ?  'c:/temp/' : '/tmp/'
    return  l:temp . a:place
endfunction

function! s:setupdirs() abort
    if !empty(s:homedir) && !empty(s:basedir)
        return
    endif

    let s:homedir =  substitute( expand( s:os_name('windows') ? $USERPROFILE : $HOME), '\', '/', 'g' )

    if empty($XDG_DATA_HOME)
        let $XDG_DATA_HOME =  s:os_name('windows') ? $LOCALAPPDATA : s:homedir .'/.local/share'
    endif

    if empty($XDG_CONFIG_HOME)
        let $XDG_CONFIG_HOME =  s:os_name('windows') ? $LOCALAPPDATA : s:homedir .'/.config'
    endif

    if s:has_func('mkdir')
        silent! call mkdir(fnameescape($XDG_DATA_HOME), 'p')
        silent! call mkdir(fnameescape($XDG_CONFIG_HOME), 'p')
    elseif !isdirectory($XDG_CONFIG_HOME) || !isdirectory($XDG_DATA_HOME)
        call s:tools_echoerr('Failed to create data dirs, mkdir is not available')
    endif

    let s:datadir = expand($XDG_DATA_HOME) . (s:os_name('windows') ? '/nvim-data' : '/nvim')

    if has('nvim')
        let s:basedir = substitute(has('nvim-0.2') ? stdpath('config') : $XDG_CONFIG_HOME . '/nvim', '\', '/', 'g' )
    elseif s:os_name('windows')
        " if $USERPROFILE and ~ expansions are different, then gVim may be running as portable
        let l:userprofile = substitute( expand($USERPROFILE), '\', '/', 'g' )
        let l:prog_home = substitute( expand('~'), '\', '/', 'g' )
        let s:basedir =  (l:userprofile ==# l:prog_home) ? l:userprofile : l:prog_home
        let s:basedir =  s:basedir . '/vimfiles'
    else
        let s:basedir = s:homedir . '/.vim'
    endif
endfunction

function! s:vars_ignores_patterns() abort
    return s:ignores_patterns
endfunction

function! s:vars_basedir() abort
    if empty(s:basedir)
        call s:setupdirs()
    endif
    return s:basedir
endfunction

function! s:vars_datadir() abort
    if empty(s:homedir)
        call s:setupdirs()
    endif
    return s:datadir
endfunction

function! s:vars_home() abort
    if empty(s:homedir)
        call s:setupdirs()
    endif
    return s:homedir
endfunction

function! s:tools_echoerr(msg) abort
    echohl ErrorMsg
    echo a:msg
    echohl
endfunction

function! s:tools_get_icon(icon) abort
    return get(s:icons, a:icon, '')
endfunction

function! s:tools_get_separators(sep_type) abort
    let l:separators = {
    \   'circle': {
    \       'left': s:icons['sep_circle_left'],
    \       'right': s:icons['sep_circle_right'],
    \   },
    \   'triangle': {
    \       'left': s:icons['sep_triangle_left'],
    \       'right': s:icons['sep_triangle_right'],
    \   },
    \   'arrow': {
    \       'left': s:icons['sep_arrow_left'],
    \       'right': s:icons['sep_arrow_right'],
    \   },
    \}

    return get(l:separators, a:sep_type, {})
endfunction

" Extracted from tpop's Fugitive plugin
function! s:tools_GitVersion(...) abort
    if !executable('git')
        return 0
    endif

    if empty(s:gitversion)
        let s:gitversion = matchstr(system('git --version'), "\\S\\+\\ze\n")
    endif

    let l:version = s:gitversion

    if !a:0
        return l:version
    endif

    let l:components = split(l:version, '\D\+')

    for l:i in range(len(a:000))
        if a:000[l:i] > +get(l:components, l:i)
            return 0
        elseif a:000[l:i] < +get(l:components, l:i)
            return 1
        endif
    endfor
    return a:000[l:i] ==# get(l:components, l:i)
endfunction


function! s:tools_ignores(tool) abort
    let l:excludes = []

    if has('nvim-0.2') || v:version >= 800 || s:has_patch('7.4.2044')
        let l:excludes = map(split(copy(&backupskip), ','), {key, val -> substitute(val, '.*', "'\\0'", 'g') })
    endif

    let l:ignores = {
                \ 'fd'       : '',
                \ 'find'     : ' -regextype egrep ',
                \ 'ag'       : '',
                \ 'grep'     : '',
                \ }

    if !empty(l:excludes)
        if executable('ag')
            let l:ignores['ag'] .= ' --ignore ' . join(l:excludes, ' --ignore ' ) . ' '
        endif
        if executable('fd')
            if filereadable(s:vars_home() . '/.config/git/ignore')
                let l:ignores['fd'] .= ' --ignore-file '. s:vars_home() .'/.config/git/ignore'
            else
                let l:ignores['fd'] .= ' -E ' . join(l:excludes, ' -E ' ) . ' '
            endif
        endif
        if executable('find')
            let l:ignores['find'] .= ' ! \( -iwholename ' . join(l:excludes, ' -or -iwholename ' ) . ' \) '
        endif
        if executable('grep')
            let l:ignores['grep'] .= ' --exclude=' . join(l:excludes, ' --exclude=' ) . ' '
        endif
    endif

    return has_key(l:ignores, a:tool) ? l:ignores[a:tool] : ''
endfunction

" Small wrap to avoid change code all over the repo
function! s:tools_grep(tool, ...) abort
    if s:moderngit == -1
        let s:moderngit = s:tools_GitVersion(2, 19)
    endif

    let l:greplist = {
                \   'git': {
                \       'grepprg': 'git --no-pager grep '.(s:moderngit == 1 ? '--column' : '').' --no-color -Iin ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
                \    },
                \   'rg' : {
                \       'grepprg':  'rg -S --hidden --color never --no-search-zip --trim --vimgrep ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'ag' : {
                \       'grepprg': 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '.s:tools_ignores('ag'),
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'grep' : {
                \       'grepprg': 'grep -RHiIn --color=never ' . s:tools_ignores('grep') . ' ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'findstr' : {
                \       'grepprg': 'findstr -rspn ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \}

    let l:property = (a:0 > 0) ? a:000[0] : 'grepprg'
    return l:greplist[a:tool][l:property]
endfunction

" Just like GrepTool but for listing files
function! s:tools_filelist(tool) abort
    let l:filelist = {
                \ 'git'  : 'git --no-pager ls-files -co --exclude-standard',
                \ 'fd'   : 'fd ' . s:tools_ignores('fd') . ' --type f --hidden --follow --color never . .',
                \ 'rg'   : 'rg --color never --no-search-zip --hidden --trim --files',
                \ 'ag'   : 'ag -l --follow --nocolor --nogroup --hidden ' . s:tools_ignores('ag'). '-g ""',
                \ 'find' : "find . -type f -iname '*' ".s:tools_ignores('find'),
                \}

    return l:filelist[a:tool]
endfunction

" Small wrap to avoid change code all over the repo
function! s:tools_select_grep(is_git, ...) abort
    let l:grepprg = ''
    let l:property = (a:0 > 0) ? a:000[0] : 'grepprg'
    if executable('git') && a:is_git
        let l:grepprg = s:tools_grep('git', l:property)
    elseif executable('rg')
        let l:grepprg = s:tools_grep('rg', l:property)
    elseif executable('ag')
        let l:grepprg = s:tools_grep('ag', l:property)
    elseif executable('grep')
        let l:grepprg = s:tools_grep('grep', l:property)
    elseif os#name('windows')
        let l:grepprg = s:tools_grep('findstr', l:property)
    endif

    return l:grepprg
endfunction

function! s:tools_set_grep(is_git, is_local) abort
    if a:is_local
        let &l:grepprg = s:tools_select_grep(a:is_git)
    else
        let &grepprg = s:tools_select_grep(a:is_git)
    endif
    let &grepformat = s:tools_select_grep(a:is_git, 'grepformat')
endfunction

function! s:tools_select_filelist(is_git, ...) abort
    let l:filelist = ''
    if executable('git') && a:is_git
        let l:filelist = s:tools_filelist('git')
    elseif executable('fd')
        let l:filelist = s:tools_filelist('fd')
    elseif executable('rg')
        let l:filelist = s:tools_filelist('rg')
    elseif executable('ag')
        let l:filelist = s:tools_filelist('ag')
    elseif os#name('unix')
        let l:filelist = s:tools_filelist('find')
    endif

    return l:filelist
endfunction

function! s:tools_spelllangs(lang) abort
    call s:tools_abolish(a:lang)
    execute 'setlocal spelllang='.a:lang
    execute 'setlocal spelllang?'
endfunction

function! s:tools_oldfiles(arglead, cmdline, cursorpos) abort
    let l:args = split(a:arglead, '\zs')
    let l:pattern = '.*' . join(l:args, '') . '.*'
    return uniq(filter(copy(v:oldfiles), 'v:val =~? "' . l:pattern . '"'))
endfunction

function! s:mappings_general_completion(arglead, cmdline, cursorpos, options) abort
    return filter(a:options, "v:val =~? join(split(a:arglead, '\zs'), '.*')")
endfunction

function! s:mappings_inside_empty_pairs() abort
    let l:rsp = v:false
    let l:pairs = {
        \ '"': '"',
        \ "'": "'",
        \ ')': '(',
        \ '}': '{',
        \ ']': '[',
        \ '>': '<',
        \}
        " \ '(': ')',
        " \ '{': '}',
        " \ '[': ']',
        " \ '<': '>',

    let l:line = nvim_get_current_line()
    let [l:ln, l:col] = nvim_win_get_cursor(0)

    if l:col > 0
        let l:close = l:line[l:col]
        let l:open = l:line[l:col - 1]
        if get(l:pairs, l:close, -1) != -1
            let l:rsp = l:pairs[l:close] == l:open
        endif
    endif

    return l:rsp
endfunction

function! g:MappingsEnter() abort
    if pumvisible()
        return "\<C-y>"
    endif
    return "\<CR>"
endfunction

function! g:MappingsTab() abort
    if pumvisible()
        return "\<C-n>"
    endif
    return "\<TAB>"
endfunction

function! g:MappingsShiftTab() abort
    if pumvisible()
        return "\<C-p>"
    endif
    return ''
endfunction

if has('terminal') || (!has('nvim-0.4') && has('nvim'))
    function! s:mappings_terminal(cmd) abort
        let l:split = (&splitbelow) ? 'botright' : 'topleft'

        if !empty(a:cmd)
            let l:shell = a:cmd
        elseif s:os_name('windows')
            let l:shell = (&shell =~? '^cmd\(\.exe\)\?$') ? 'powershell -noexit -executionpolicy bypass ' : &shell
        else
            let l:shell = fnamemodify(expand($SHELL), ':t')
            if l:shell =~# '\(t\)\?csh'
                let l:shell = (executable('zsh')) ? 'zsh' : (executable('bash')) ? 'bash' : l:shell
            endif
        endif

        if has('nvim')
            execute l:split . ' 20split term://' . l:shell
        else
            call term_start(l:shell . a:cmd, {'term_rows': 20})
        endif

        wincmd J
        setlocal nonumber norelativenumber

        if empty(a:cmd)
            startinsert
        endif

    endfunction
endif

if s:has_option('mouse')
    function! s:mappings_ToggleMouse() abort
        if &mouse ==# ''
            execute 'set mouse=a'
            echo 'mouse'
        else
            execute 'set mouse='
            echo 'nomouse'
        endif
    endfunction
endif

if has('nvim') || v:version >= 704
    function! s:mappings_format(arglead, cmdline, cursorpos) abort
        return s:mappings_general_completion(a:arglead, a:cmdline, a:cursorpos, ['unix', 'dos', 'mac'])
    endfunction

    function! s:mappings_SetFileData(action, type, default) abort
        let l:param = (a:type ==# '') ? a:default : a:type
        execute 'setlocal ' . a:action . '=' . l:param
    endfunction
endif

" Center searches results
" CREDITS: https://amp.reddit.com/r/vim/comments/4jy1mh/slightly_more_subltle_n_and_n_behavior/
function! g:MappingsNiceNext(cmd) abort
    let view = winsaveview()
    execute 'silent! normal! ' . a:cmd
    if view.topline != winsaveview().topline
        silent! normal! zz
    endif
endfunction

function! g:MappingsTrim() abort
    " Since default is to trim, the first call is to deactivate trim
    if b:trim == 0
        let b:trim = 1
        echo ' Trim'
    else
        let b:trim = 0
        echo ' NoTrim'
    endif

    return 0
endfunction

function! s:mappings_cr() abort
    let l:cword = expand('<cword>')
    try
        execute 'tag ' . l:cword
    catch /E4\(2\(6\|9\)\|33\|73\)/
        execute "silent! normal! \<CR>"
    endtry
endfunction

function! s:mappings_spells(arglead, cmdline, cursorpos) abort
    let l:candidates = split(glob(s:vars_basedir() . '/spell/*.utf-8.sug'), '\n')
    let l:candidates = map(l:candidates, {key, val -> split(fnamemodify(val , ':t'), '\.')[0]})
    return s:mappings_general_completion(a:arglead, a:cmdline, a:cursorpos, l:candidates)
endfunction

" CREDITS: https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" Smart indent when entering insert mode with i on empty lines
function! g:MappingsIndentWithI() abort
    if len(getline('.')) == 0 && line('.') != line('$') && &buftype !~? 'terminal'
        return '"_ddO'
    endif
    return 'i'
endfunction

" Remove buffers
"
" BufKill  will wipe all hidden buffers
" BufKill! will wipe all unloaded buffers
"
" CREDITS: https://vimrcfu.com/snippet/154
function! s:mappings_BufKill(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && (!buflisted(l:b) || (a:bang && !bufloaded(l:b)))
            execute 'bwipeout! '.l:b
            let l:count += 1
        endif
    endfor
    echomsg 'Deleted ' . l:count . ' buffers'
endfunction

" Clean buffer list
"
" BufClean  will delete all non active buffers
" BufClean! will wipe all non active buffers
function! s:mappings_BufClean(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && ( (a:bang && !buflisted(l:b)) || (!a:bang && !bufloaded(l:b) && buflisted(l:b)) )
            execute ( (a:bang) ? 'bwipeout! ' : 'bdelete! ' ) . l:b
            let l:count += 1
        endif
    endfor
    echomsg 'Deleted ' . l:count . ' buffers'
endfunction

" Test remap arrow keys
function! s:mappings_ToggleArrows() abort
    let s:arrows = s:arrows * -1
    if s:arrows == 1
        nnoremap <left>  <c-w><
        nnoremap <right> <c-w>>
        nnoremap <up>    <c-w>+
        nnoremap <down>  <c-w>-
    else
        unmap <left>
        unmap <right>
        unmap <up>
        unmap <down>
    endif
endfunction

function! s:mappings_ConncallLevel(level) abort
    let l:level = (!empty(a:level)) ? a:level : (&conceallevel > 0) ? 0 : 2
    let &conceallevel = l:level
endfunction

" ------------------------------------------------------------------------------
" Options
" ------------------------------------------------------------------------------

call s:tools_set_grep(0, 0)

if exists('+syntax')
    syntax on
endif

set diffopt^=vertical

if s:has_patch('8.1.0360') || has('nvim')
    set diffopt^=indent-heuristic,algorithm:patience
endif

if s:has_patch('8.1.1361') || has('nvim')
    set diffopt^=hiddenoff
endif

if s:has_patch('8.1.2289') || has('nvim')
    set diffopt^=iwhiteall,iwhiteeol
else
    set diffopt^=iwhite
endif

if s:has_option('winaltkeys')
    set winaltkeys=no
endif

if s:has_option('renderoptions')
    set renderoptions=type:directx
endif

" Allow lua omni completion
let g:lua_complete_omni = 1

" Use C for .h headers
let g:c_syntax_for_h = 1
let g:c_comment_strings = 1
let g:c_curly_error = 1
let g:c_no_if0 = 0

let g:tex_flavor = 'latex'

if s:has_option('scrollback')
    set scrollback=-1
endif

if s:has_option('termguicolors')
    set termguicolors
endif

if s:has_option('virtualedit')
    " Allow virtual editing in Visual block mode.
    set virtualedit=block
endif

if s:has_option('infercase')
    set infercase      " Smart casing when completing
endif

if s:has_option('langnoremap')
    set langnoremap
endif

set nrformats=hex
set shortmess=filnxtToOac

if s:has_patch('7.4.1065')
    set nrformats+=bin
endif

if s:has_patch('7.4.1570')
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

if s:has_option('display')
    set display=lastline
endif

if v:version >= 704
    set formatoptions=tcqj
endif

if s:has_option('belloff')
    set belloff=all " Bells are annoying
endif

if s:has_patch('8.1.1902')
    set completeopt+=popup
    set completepopup=height:10,width:60,highlight:Pmenu,border:off
endif

if v:version >= 704
    set formatoptions+=r " Auto insert comment with <Enter>...
    set formatoptions+=o " ...or o/O
    set formatoptions+=l " Do not wrap lines that have been longer when starting insert mode already
    set formatoptions+=n " Recognize numbered lists
    set formatoptions+=j " Delete comment character when joining commented lines
endif

set updatetime=100

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

set listchars=tab:>\ ,trail:-,extends:$,precedes:$

if !&sidescrolloff
    set sidescrolloff=5
endif

if !&scrolloff
    set scrolloff=1
endif

set wildmenu             " Enable <TAB> completion in command mode
set wildmode=full
set backupcopy=yes
set display+=lastline
set nojoinspaces         " Use only 1 space after "." when joining lines, not 2
set visualbell           " Visual bell instead of beeps, but...
set fileformats=unix,dos " File mode unix by default
set undolevels=10000     " Set the number the undos per file

if s:has_option('breakindent')
    setglobal breakindent
    " set showbreak=\\\\\
    try
        set showbreak=↪\
    catch /E595/
    endtry
endif

if s:has_option('relativenumber')
    set relativenumber
endif

if s:has_option('colorcolumn')
    set colorcolumn=80
endif

if s:has_option('numberwidth')
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

" set noshowmode
" let &statusline = '%< [%f]%=%-5.(%y%r%m%w%q%) %-14.(%l,%c%V%) %P '

set background=dark
set cursorline

if s:has_option('termguicolors')
    set termguicolors
endif

if !has('nvim')
    set t_Co=256
    let &t_8f = "\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b = "\<Esc>[48;2;%lu;%lu;%lum"
endif

colorscheme torte
set nocursorline

" ------------------------------------------------------------------------------
" Mappings
" ------------------------------------------------------------------------------

let g:mapleader = get(g:, 'mapleader', "\<Space>")
nnoremap , :
xnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual/select the return character
xnoremap $ $h

" Avoid default Ex mode
" Use gQ instead of plain Q, it has tab completion and more cool things
nnoremap Q o<Esc>

" Preserve cursor position when joining lines
nnoremap J m`J``

" Better <ESC> mappings
imap jj <Esc>

nnoremap <silent> <BS> <C-o>

xnoremap <BS> <ESC>

inoremap <silent> <TAB>   <C-R>=g:MappingsTab()<CR>
inoremap <silent> <S-TAB> <C-R>=g:MappingsShiftTab()<CR>
inoremap <silent> <CR>    <C-R>=g:MappingsEnter()<CR>

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
    nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

if !s:has_patch('8.1.2289')
    " Turn diff off when closiong other windows
    nnoremap <silent> <C-w><C-o> :diffoff!<bar>only<cr>
    nnoremap <silent> <C-w>o :diffoff!<bar>only<cr>
endif

" Seems like a good idea, may activate it later
nnoremap <expr> q &diff ? ":diffoff!\<bar>only\<cr>" : "q"

" Move vertically by visual line unless preceded by a count. If a movement is
" greater than 3 then automatically add to the jumplist.
nnoremap <silent><expr> j v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <silent><expr> k v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk'

" Jump to the previous mark, as <TAB>
nnoremap <S-tab> <C-o>

xnoremap > >gv
xnoremap < <gv

" I prefer to jump directly to the file line
" nnoremap gf gF

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>
" nnoremap <leader>c :pclose<CR>

" Very Magic sane regex searches
nnoremap / ms/
nnoremap g/ ms/\v

" TODO
nnoremap <expr> i g:MappingsIndentWithI()

if has('nvim') || v:version >= 704
    " Change word under cursor and dot repeat
    nnoremap c* m`*``cgn
    nnoremap c# m`#``cgN
    nnoremap cg* m`g*``cgn
    nnoremap cg# m`g#``cgN
    xnoremap <silent> c "cy/<C-r>c<CR>Ncgn
endif

nnoremap ¿ `
xnoremap ¿ `
nnoremap ¿¿ ``
xnoremap ¿¿ ``
nnoremap ¡ ^
xnoremap ¡ ^

" Move to previous file
nnoremap <leader>p <C-^>

" For systems without F's keys (ex. Android)
" nnoremap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <silent> <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" TabBufferManagement {{{

" Buffer movement
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l
nnoremap <leader>b <C-w>b
nnoremap <leader>t <C-w>t

" Equally resize buffer splits
nnoremap <leader>e <C-w>=

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
nnoremap <leader><leader>n :tabnew<CR>

xnoremap <leader>1 <ESC>1gt
xnoremap <leader>2 <ESC>2gt
xnoremap <leader>3 <ESC>3gt
xnoremap <leader>4 <ESC>4gt
xnoremap <leader>5 <ESC>5gt
xnoremap <leader>6 <ESC>6gt
xnoremap <leader>7 <ESC>7gt
xnoremap <leader>8 <ESC>8gt
xnoremap <leader>9 <ESC>9gt
xnoremap <leader>0 <ESC>:tablast<CR>

cabbrev W   w
cabbrev Q   q
cabbrev q1  q!
cabbrev w1  w!
cabbrev wA! wa!
cabbrev wa1 wa!
cabbrev QA! qa!
cabbrev QA1 qa!
cabbrev Qa! qa!
cabbrev Qa1 qa!

" Use C-p and C-n to move in command's history
cnoremap <C-n> <down>
cnoremap <C-p> <up>

cnoremap <C-r><C-w> "<C-r>=escape(expand('<cword>'), '#')<CR>"

" Repeat last substitution
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Swap 0 and ^, ^ is them most common line beginning for me
nnoremap 0 ^
nnoremap ^ 0

" select last inserted text
nnoremap gV `[v`]

nnoremap <leader>d :bdelete!<CR>

nnoremap <silent> [Q  :<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz
nnoremap <silent> ]Q  :<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz
nnoremap <silent> [q  :<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz
nnoremap <silent> ]q  :<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz

nnoremap <silent> [L  :<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz
nnoremap <silent> ]L  :<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz
nnoremap <silent> [l  :<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz
nnoremap <silent> ]l  :<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz

nnoremap <silent> [B :<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>
nnoremap <silent> ]B :<C-U>exe "".(v:count ? v:count : "")."blast"<CR>
nnoremap <silent> [b :<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>
nnoremap <silent> ]b :<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>

nnoremap <silent> n :call g:MappingsNiceNext('n')<cr>
nnoremap <silent> N :call g:MappingsNiceNext('N')<cr>

" " TODO: port quick quickfix/loclist toggle to viml
" nnoremap <silent> =q :ERROR<cr>
" nnoremap <silent> =l :ERROR<cr>

" ------------------------------------------------------------------------------
" Commands
" ------------------------------------------------------------------------------

if s:has_option('relativenumber')
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if s:has_option('mouse')
    command! MouseToggle call s:mappings_ToggleMouse()
endif

command! ArrowsToggle call s:mappings_ToggleArrows()
command! -bang BufKill call s:mappings_BufKill(<bang>0)
command! -bang BufClean call s:mappings_BufClean(<bang>0)

command! ModifiableToggle setlocal modifiable! modifiable?
command! CursorLineToggle setlocal cursorline! cursorline?
command! ScrollBindToggle setlocal scrollbind! scrollbind?
command! HlSearchToggle   setlocal hlsearch! hlsearch?
command! NumbersToggle    setlocal number! number?
command! PasteToggle      setlocal paste! paste?
command! SpellToggle      setlocal spell! spell?
command! WrapToggle       setlocal wrap! wrap?
command! VerboseToggle    let &verbose=!&verbose | echo "Verbose " . &verbose

if has('nvim') || v:version >= 704
    command! -nargs=? -complete=filetype FileType call s:mappings_SetFileData('filetype', <q-args>, 'text')
    command! -nargs=? -complete=customlist,s:mappings_format FileFormat call s:mappings_SetFileData('fileformat', <q-args>, 'unix')
endif

command! TrimToggle call g:MappingsTrim()

if has('nvim-0.2') || s:has_patch('7.4.2044')
    command! -nargs=? -complete=customlist,s:mappings_spells SpellLang
                \ let s:spell = (empty(<q-args>)) ?  'en' : expand(<q-args>) |
                \ call s:tools_spelllangs(s:spell) |
                \ unlet s:spell
else
    command! -nargs=? SpellLang
                \ let s:spell = (empty(<q-args>)) ?  'en' : expand(<q-args>) |
                \ call s:tools_spelllangs(s:spell) |
                \ unlet s:spell
endif

command! -nargs=? ConncallLevel  call s:mappings_ConncallLevel(expand(<q-args>))

" Avoid dispatch command conflict
" QuickfixOpen
command! -nargs=? Qopen execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)

command! -bang -nargs=1 -complete=file Move
    \ let s:name = expand(<q-args>) |
    \ let s:current = expand('%:p') |
    \ if (rename(s:current, s:name)) |
    \   execute 'edit ' . s:name |
    \   execute 'bwipeout! '.s:current |
    \ endif |
    \ unlet s:name |
    \ unlet s:current

command! -bang -nargs=1 -complete=file Rename
    \ let s:name = expand('%:p:h') . '/' . expand(<q-args>) |
    \ let s:current = expand('%:p') |
    \ if (rename(s:current, s:name)) |
    \   execute 'edit ' . s:name |
    \   execute 'bwipeout! '.s:current |
    \ endif |
    \ unlet s:name |
    \ unlet s:current

command! -bang -nargs=1 -complete=dir Mkdir
    \ let s:bang = empty(<bang>0) ? 0 : 1 |
    \ let s:dir = expand(<q-args>) |
    \ call mkdir(fnameescape(s:dir), (s:bang) ? "p" : "") |
    \ unlet s:bang |
    \ unlet s:dir

command! -bang -nargs=? -complete=file Remove
    \ let s:bang = empty(<bang>0) ? 0 : 1 |
    \ let s:target = fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p") |
    \ if filereadable(s:target) || bufloaded(s:target) |
    \   if filereadable(s:target) |
    \       if delete(s:target) == -1 |
    \           s:tools_echoerr("Failed to delete the file '" . s:target . "'") |
    \       endif |
    \   endif |
    \   if bufloaded(s:target) |
    \       let s:cmd = (s:bang) ? "bwipeout! " : "bdelete! " |
    \       try |
    \           execute s:cmd . s:target |
    \       catch /E94/ |
    \           s:tools_echoerr("Failed to delete/wipe '" . s:target . "'") |
    \       finally |
    \           unlet s:cmd |
    \       endtry |
    \   endif |
    \ elseif isdirectory(s:target) |
    \   let s:flag = (s:bang) ? "rf" : "d" |
    \   if delete(s:target, s:flag) == -1 |
    \       s:tools_echoerr("Failed to remove '" . s:target . "'") |
    \   endif |
    \   unlet s:flag |
    \ else |
    \   s:tools_echoerr('Non removable target: "'.s:target.'"') |
    \ endif |
    \ unlet s:bang |
    \ unlet s:target

" ------------------------------------------------------------------------------
" Autocmds
" ------------------------------------------------------------------------------

if v:version > 702
    " TODO make a function to save the state of the toggles
    augroup Numbers
        autocmd!
        autocmd WinEnter    * if &buftype !=# 'terminal' | setlocal relativenumber number | endif
        autocmd WinLeave    * if &buftype !=# 'terminal' | setlocal norelativenumber number | endif
        autocmd InsertLeave * if &buftype !=# 'terminal' | setlocal relativenumber number | endif
        autocmd InsertEnter * if &buftype !=# 'terminal' | setlocal norelativenumber number | endif
    augroup end
endif

augroup LastEditPosition
    autocmd!
    autocmd BufReadPost *
                \   if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# "\v(gitcommit|fugitive|git)" |
                \       exe "normal! g'\""                                                                       |
                \   endif
augroup end

" " Trim whitespace in selected files
" augroup CleanFile
"     autocmd!
"     autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
"     if !s:has_plugin('completor.vim')
"         autocmd BufWritePre * call autocmd#CleanFile()
"     endif
" augroup end

augroup QuickQuit
    autocmd!
    autocmd BufEnter,BufReadPost __LanguageClient__ nnoremap <silent> <nowait> <buffer> q :q!<CR>
    autocmd BufEnter,BufWinEnter * if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif
    " if  has('terminal') && s:has_autocmd('TerminalOpen')
    "     autocmd TerminalOpen * nnoremap <silent> <nowait> <buffer> q :q!<CR>
    " endif
augroup end

augroup LocalCR
    autocmd!
    autocmd CmdwinEnter * nnoremap <CR> <CR>
augroup end

augroup CloseMenu
    autocmd!
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
augroup end

filetype plugin indent on

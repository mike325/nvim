" Vars Setttings
" github.com/mike325/.vim

if has('nvim-0.5')
    function! vars#basedir() abort
        return luaeval('require"sys".base')
    endfunction

    function! vars#datadir() abort
        return luaeval('require"sys".data')
    endfunction

    function! vars#home() abort
        return luaeval('require"sys".home')
    endfunction

    function! vars#cache() abort
        return luaeval('require"sys".cache')
    endfunction

    finish
endif

let s:ignore_cmd = {
            \   'git' : '',
            \   'ag' : '',
            \   'rg' : '',
            \   'find' : '',
            \   'grep' : '',
            \   'dir' : '',
            \   'findstr' : '',
            \}

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

function! s:setupdirs() abort
    if !empty(s:homedir) && !empty(s:basedir)
        return
    endif

    if has('nvim')
        let s:homedir  = luaeval("require('sys').home")
        let s:basedir  = luaeval("require('sys').base")
        let s:datadir  = luaeval("require('sys').data")
        let s:cachedir = luaeval("require('sys').cache")
        return
    endif

    let s:homedir =  substitute( expand( os#name('windows') ? $USERPROFILE : $HOME), '\', '/', 'g' )

    if empty($XDG_DATA_HOME)
        let $XDG_DATA_HOME =  os#name('windows') ? $LOCALAPPDATA : s:homedir .'/.local/share'
    endif

    if empty($XDG_CONFIG_HOME)
        let $XDG_CONFIG_HOME =  os#name('windows') ? $LOCALAPPDATA : s:homedir .'/.config'
    endif

    if exists('*mkdir')
        silent! call mkdir(fnameescape($XDG_DATA_HOME), 'p')
        silent! call mkdir(fnameescape($XDG_CONFIG_HOME), 'p')
    elseif !isdirectory($XDG_CONFIG_HOME) || !isdirectory($XDG_DATA_HOME)
        echohl ErrorMsg
        echo 'Failed to create data dirs, mkdir is not available'
        echohl
    endif

    let s:datadir = expand($XDG_DATA_HOME) . (os#name('windows') ? '/nvim-data' : '/nvim')

    if has('nvim')
        let s:basedir = substitute(has('nvim-0.2') ? stdpath('config') : $XDG_CONFIG_HOME . '/nvim', '\', '/', 'g' )
    elseif os#name('windows')
        " if $USERPROFILE and ~ expansions are different, then gVim may be running as portable
        let l:userprofile = substitute( expand($USERPROFILE), '\', '/', 'g' )
        let l:prog_home = substitute( expand('~'), '\', '/', 'g' )
        let s:basedir =  (l:userprofile ==# l:prog_home) ? l:userprofile : l:prog_home
        let s:basedir =  s:basedir . '/vimfiles'
    else
        let s:basedir = s:homedir . '/.vim'
    endif
endfunction

function! vars#ignore_cmd(cmd) abort
    return s:ignore_cmd[a:cmd]
endfunction

function! vars#ignores_patterns() abort
    return s:ignores_patterns
endfunction

function! vars#basedir() abort
    if empty(s:basedir)
        call s:setupdirs()
    endif
    return s:basedir
endfunction

function! vars#datadir() abort
    if empty(s:homedir)
        call s:setupdirs()
    endif
    return s:datadir
endfunction

function! vars#home() abort
    if empty(s:homedir)
        call s:setupdirs()
    endif
    return s:homedir
endfunction

function! vars#libclang() abort
    let l:libclang = ''

    if os#name('windows')
        if filereadable(vars#home() . '/.local/bin/libclang.dll')
            let l:libclang = vars#home() . '/.local/bin/libclang.dll'
        elseif exists('g:plugs["YouCompleteMe"]')
            let l:libclang = vars#basedir() . '/plugged/YouCompleteMe/third_party/ycmd/libclang.dll'
        elseif filereadable('c:/Program Files/LLVM/bin/libclang.dll')
            let l:libclang = 'c:/Program Files/LLVM/bin/libclang.dll'
        elseif filereadable('c:/Program Files(x86)/LLVM/bin/libclang.dll')
            let l:libclang = 'c:/Program Files(x86)/LLVM/bin/libclang.dll'
        endif
    else
        if filereadable(vars#home() . '/.local/lib/libclang.so')
            let l:libclang = vars#home() . '/.local/lib/libclang.so'
        elseif exists('g:plugs["YouCompleteMe"]')
            for s:version in ['7', '6', '5', '4', '3']
                if filereadable(vars#basedir() . '/plugged/YouCompleteMe/third_party/ycmd/libclang.so.' . s:version)
                    let l:libclang = vars#basedir() . '/plugged/YouCompleteMe/third_party/ycmd/libclang.so.' . s:version
                    break
                endif
            endfor
            silent! unlet s:version
        endif
        let l:libclang = !empty(l:libclang) ? l:libclang : filereadable('/usr/lib/libclang.so') ? '/usr/lib/libclang.so' : ''
    endif

    return l:libclang
endfunction

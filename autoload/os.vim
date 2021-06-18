" OS Settings
" github.com/mike325/.vim

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

function! os#cache() abort
    return stdpath('cache')
endfunction

" Windows wrapper
function! os#name(...) abort
    return (a:0 > 0) ? s:os_type(a:1) : s:os_get_type()
endfunction

function! os#tmpdir() abort
    return  os#name('windows') ?  'c:/temp' : '/tmp'
endfunction

function! os#tmp(place) abort
    let l:temp = os#name('windows') ?  'c:/temp/' : '/tmp/'
    return  l:temp . a:place
endfunction

" ############################################################################
"
"                               os Setttings
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
" ############################################################################

function! s:os_get_type() abort
    let l:name = 'unknown'
    if (has('win16') || has('win32') || has('win64'))
        let l:name = 'windows'
    elseif has('macunix')
        let l:name = 'macos'
    elseif has('unix')
        let l:name = 'unix'
    endif
    return l:name
endfunction

function! s:os_type(os) abort
    let l:is_type = v:false
    if a:os ==# 'windows' || a:os ==# 'win32'
        let l:is_type = (has('win16') || has('win32') || has('win64'))
    elseif a:os ==# 'mac' || a:os ==# 'macos'
        let l:is_type = (has('macos'))
    elseif a:os ==# 'linux' || a:os ==# 'unix'
        let l:is_type = (has('unix'))
    endif
    return l:is_type
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

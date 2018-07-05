" ############################################################################
"
"                               youcompleteme Setttings
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

if !exists('g:plugs["YouCompleteMe"]') || !exists('g:plugs["delimitMate"]')
    finish
endif

function! YcmOnDeleteChar()
    if pumvisible()
        return "\<C-y>"
    endif
    return ""
endfunction

function! s:FixYCMBs()
    imap <BS> <C-R>=YcmOnDeleteChar()<CR><Plug>delimitMateBS
    imap <C-h> <C-R>=YcmOnDeleteChar()<CR><Plug>delimitMateBS
endfunction

" Hack around
" https://github.com/Valloric/YouCompleteMe/issues/2696
if has( 'vim_starting' )
    augroup BsHack
        autocmd!
        autocmd VimEnter * call s:FixYCMBs()
    augroup END
else
    call s:FixYCMBs()
endif


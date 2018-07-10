" ############################################################################
"
"                               log Setttings
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

function! CheckSize()
    " If the size of the file is bigger than ~5MB
    " lets consider it as a log
    return ( getfsize(expand("%")) > 5242880 ) ? 1 : 0
endfunction


autocmd BufNewFile,BufReadPre,BufEnter *.log set filetype=log
autocmd BufNewFile,BufReadPre,BufEnter *.rdl set filetype=log
autocmd BufNewFile,BufReadPre,BufEnter *.txt if ( CheckSize() == 1 ) | set filetype=log | endif


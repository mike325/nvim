" HEADER {{{
"
"                               Autodetect log files
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
" }}} END HEADER

function! s:CheckSize()
    let b:size = getfsize(expand("%"))
    " If the size of the file is bigger than ~50MB
    " lets consider it as a log
    if b:size > 52428800
        return 1
    endif
    return 0
endfunction

augroup LogFiles
    autocmd!
    autocmd BufNewFile,BufReadPre *.log set filetype=log
    autocmd BufNewFile,BufReadPre *.txt if(s:CheckSize()) | set filetype=log | endif
augroup end

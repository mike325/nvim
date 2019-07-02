" ############################################################################
"
"                               windows Setttings
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

let g:sh_defaults = { 'shell':&shell, 'shellcmdflag':&shellcmdflag,
                    \ 'shellquote':&shellquote, 'shellxquote':&shellxquote,
                    \ 'shellpipe':&shellpipe, 'shellredir':&shellredir }

function! windows#toggle_powershell() abort
    if &shell =~# 'powershell\(.exe\)\?'
        let s = g:sh_defaults

        let &shell        = s.shell
        let &shellquote   = s.shellquote
        let &shellpipe    = s.shellpipe
        let &shellredir   = s.shellredir
        let &shellcmdflag = s.shellcmdflag
        let &shellxquote  = s.shellxquote
    else
        set shell=powershell.exe shellquote=\" shellpipe=\| shellredir=>
        set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
        let &shellxquote=' '
        " set shellxquote=
        " " set shellxquote=(
        " let &shellquote = ''
        " let &shellpipe  = has('nvim') ? '| Out-File -Encoding UTF8 %s' : '>'
        " let &shellredir = '| Out-File -Encoding UTF8 %s'
    endif
    echomsg 'Current shell ' . &shell
endfunction

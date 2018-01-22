" ############################################################################
"
"                              DelimitMate settings
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

if !exists('g:plugs["delimitMate"]')
    finish
endif

" function! BetterBackspace()
" endfunction

let g:delimitMate_expand_space = 1

" let delimitMate_matchpairs = "(:),[:],{:},<:>"
" au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

" iunmap <BS>
if exists("*delimitMate#BS")
    imap <silent> <BS> <Plug>delimitMateBS
endif

" let delimitMate_expand_space = 1
" au FileType tcl let b:delimitMate_expand_space = 1

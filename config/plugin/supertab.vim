" ############################################################################
"
"                                SuperTab settings
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

if !exists('g:plugs["supertab"]')
    finish
endif

let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabContextDefaultCompletionType = "<c-p>"
let g:SuperTabCompletionContexts = ['s:ContextText', 's:extDiscover']
let g:SuperTabContextDiscoverDiscovery = ["&omnifunc:<c-x><c-o>"]

if !has("autocmd")
    finish
endif

augroup SuperTabOmni
    autocmd!
    autocmd FileType *
            \ if &omnifunc != '' |
            \    call SuperTabChain(&omnifunc, "<c-p>") |
            \    call SuperTabSetDefaultCompletionType("<c-x><c-o>") |
            \ endif
augroup end

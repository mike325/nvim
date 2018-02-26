" ############################################################################
"
"                               Surround Setttings
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


if !exists('g:plugs["vim-surround"]')
    finish
endif

augroup Surrounders
    autocmd!
    autocmd FileType text let b:surround_63 = '¿ \r ?'
    autocmd FileType text let b:surround_168 = '¿ \r ?'
    autocmd FileType text let b:surround_173 = '¡ \r !'
    autocmd FileType text let b:surround_33 = '¡ \r !'
augroup end


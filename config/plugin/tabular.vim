" ############################################################################
"
"                               Tabular settigns
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

if !exists('g:plugs["tabular"]')
    finish
endif

nnoremap <leader>t= :Tabularize /=<CR>
xnoremap <leader>t= :Tabularize /=<CR>

nnoremap <leader>t: :Tabularize /:<CR>
xnoremap <leader>t: :Tabularize /:<CR>

nnoremap <leader>t" :Tabularize /"<CR>
xnoremap <leader>t" :Tabularize /"<CR>

nnoremap <leader>t# :Tabularize /#<CR>
xnoremap <leader>t# :Tabularize /#<CR>

nnoremap <leader>t* :Tabularize /*<CR>
xnoremap <leader>t* :Tabularize /*<CR>

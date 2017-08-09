" ############################################################################
"
"                            Vim move settings
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

if !exists('g:plugs["vim-move"]')
    finish
endif

" Manual map the functions to overlap any possible conflict
let g:move_key_modifier = 'C'

" let g:move_map_keys = 0
" Set Ctrl key as default. Commands <C-j> and <C-k> to move stuff
" vnoremap <C-j> <Plug>MoveBlockDown
" vnoremap <C-k> <Plug>MoveBlockUp

" nnoremap <C-j> <Plug>MoveLineDown
" nnoremap <C-k> <Plug>MoveLineUp
" nmap <>     <Plug>MoveBlockHalfPageDown

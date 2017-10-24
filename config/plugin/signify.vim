" ############################################################################
"
"                              Signify settings
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

if !exists('g:plugs["vim-signify"]')
    finish
endif

let g:signify_cursorhold_insert     = 1
let g:signify_cursorhold_normal     = 1
let g:signify_update_on_bufenter    = 0


let g:signify_skip_filetype = {
            \    'log': 1,
            \ }

let g:signify_skip_filename_pattern = [
            \   '*.log',
            \ ]

nmap ]h <plug>(signify-next-hunk)
nmap [h <plug>(signify-prev-hunk)
" nmap ]h 9999<leader>gj
" nmap ]h 9999<leader>gk

omap ih <plug>(signify-motion-inner-pending)
xmap ih <plug>(signify-motion-inner-visual)
omap ah <plug>(signify-motion-outer-pending)
xmap ah <plug>(signify-motion-outer-visual)

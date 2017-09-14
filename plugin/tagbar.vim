" ############################################################################
"
"                            Tagbar settings
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

if !exists('g:plugs["tagbar"]')
    finish
endif

" Default is <Space> which conflict with my leader settings
let g:tagbar_map_showproto = "<C-Space>"

let g:tagbar_compact          = 0
let g:tagbar_case_insensitive = 1
let g:tagbar_show_visibility  = 1
let g:tagbar_expand           = 1

let g:tagbar_iconchars = ['▶', '▼']  " (default on Linux and Mac OS X)
" let g:tagbar_iconchars = ['+', '-']   " (default on Windows)

" 0: Don't show any line numbers.
" 1: Show absolute line numbers.
" 2: Show relative line numbers.
" -1: Use the global line number settings.
"
" NOTE: Since I already have a autocmd auto settings numbers
" I will not enable this
" let g:tagbar_show_linenumbers = 2

" nnoremap tt :TagbarToggle<CR>
" nnoremap <F2> :TagbarToggle<CR>
" inoremap <F2> :TagbarToggle<CR>
" vnoremap <F2> :TagbarToggle<CR>gv

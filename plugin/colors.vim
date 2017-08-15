" ############################################################################
"
"                             Colorscheme settings
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
if !exists('g:plugs["gruvbox"]')
    finish
endif

silent! colorscheme gruvbox

let g:gruvbox_contrast_dark = 'hard'
" TODO: improve key mappings

" nnoremap csg :colorscheme gruvbox<CR>:AirlineTheme gruvbox<CR>

" if &runtimepath =~ 'vim-monokai'
"     nnoremap csm :colorscheme monokai<CR>:AirlineTheme molokai<CR>
" endif
"
" if &runtimepath =~ 'jellybeans.vim'
"     nnoremap csj :colorscheme jellybeans<CR>:AirlineTheme solarized<CR>
" endif
"
" if &runtimepath =~ 'onedark'
"     nnoremap cso :colorscheme onedark<CR>:AirlineTheme solarized<CR>
" endif
"
" if &runtimepath =~ 'vim-gotham'
"     " b for batman
"     nnoremap csb :colorscheme gotham<CR>:AirlineTheme gotham<CR>
" endif

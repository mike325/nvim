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

" if !exists('g:plugs["gruvbox"]')
"     finish
" endif

try

    " silent! colorscheme gruvbox
    " colorscheme gruvbox
    " colorscheme monokai
    colorscheme onedark

    let g:gruvbox_contrast_dark        = 'hard'
    let g:gruvbox_contrast_light       = "hard"
    let g:gruvbox_sign_column          = "dark0"
    let g:gruvbox_color_column         = "dark0"
    let g:gruvbox_vert_split           = "dark0"
    let g:gruvbox_bold                 = 1
    let g:gruvbox_underline            = 1
    let g:gruvbox_undercurl            = 1
    let g:gruvbox_termcolors           = 256
    let g:gruvbox_italicize_strings    = 0
    let g:gruvbox_invert_selection     = 0
    let g:gruvbox_invert_signs         = 0
    let g:gruvbox_invert_indent_guides = 1
    let g:gruvbox_invert_tabline       = 0
    let g:gruvbox_improved_warnings    = 1
    let g:gruvbox_improved_strings     = 0

    " let g:gruvbox_italic               = 1
    " let g:gruvbox_italicize_comments   = 1
    " let g:gruvbox_hls_cursor="orange"

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

catch E185
    " We don't have our cool color schemes
    colorscheme desert
endtry

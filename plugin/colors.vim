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

set background=dark

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

try

    " let g:gruvbox_italic               = 1
    " let g:gruvbox_italicize_comments   = 1
    " let g:gruvbox_hls_cursor="orange"

    " silent! colorscheme gruvbox
    " colorscheme gruvbox
    " colorscheme monokai
    " colorscheme onedark
    colorscheme ayu

catch E185
    " We don't have our cool color schemes
    " colorscheme industry
    colorscheme torte

    " Default colorschemes have underlined cursorline, so we deactivate it
    set nocursorline
endtry

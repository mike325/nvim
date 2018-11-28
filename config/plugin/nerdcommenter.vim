" ############################################################################
"
"                            NERDCommenter settings
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

if !exists('g:plugs["nerdcommenter"]')
    finish
endif

let g:NERDCompactSexyComs        = 0      " Use compact syntax for prettified multi-line comments
let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                          " (useful when commenting a region)
let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                          " of following code indentation
let g:NERDCustomDelimiters = {
    \ 'python': { 'left': '#', 'leftAlt': '"""', 'rightAlt': '"""' },
    \ 'c': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' },
    \ 'cpp': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' }
    \ }

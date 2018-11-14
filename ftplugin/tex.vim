" ############################################################################
"
"                               tex Setttings
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

if !exists('g:plugs["vimtex"]')
    " Credits to vimtex plugin
    let &include='\v^\s*\%\s*!?\s*[tT][eE][xX]\s+[rR][oO][oO][tT]\s*\=\s*\zs.*\ze\s*$|\v^\s*%(\v\\%(input|include|subfile)\s*\{|\v\\%(sub)?%(import|%(input|include)from)\*?\{[^\}]*\}\{)\zs[^\}]*\ze\}?'
    " let &includeexpr=''
endif

setlocal wrapmargin=80

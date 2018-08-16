" ############################################################################
"
"                               log Setttings
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

if exists("b:current_syntax")
  finish
endif

syn match LogError      /\(^\([[:blank:]]\+\)\?\zs\([[:alpha:]]*\)\?\cerr\(or\)\?\ze:\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\([[:alpha:]]*\)\?\cerr\(or\)\?\ze[[:blank:]]\?:\)/
syn match LogFail       /\(^\([[:blank:]]\+\)\?\zs\cfail\(ed\)\?\ze:\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cfail\(ed\)\?\ze[[:blank:]]\?:\)/
syn match LogException  /\(^\([[:blank:]]\+\)\?\zs\cexception\ze:\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cexception\ze[[:blank:]]\?:\)/
syn match LogWarn       /\(^\([[:blank:]]\+\)\?\zs\cwarn\(ing\)\?\ze\(:\)\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cwarn\(ing\)\?\ze[[:blank:]]\?:\)/
syn match LogInfo       /\(^\([[:blank:]]\+\)\?\zs\cinfo\(rmation\)\?\ze\(:\)\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cinfo\(rmation\)\?\ze[[:blank:]]\?:\)/
syn match LogDebug      /\(^\([[:blank:]]\+\)\?\zs\cdebug\ze\(:\)\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cdebug\ze[[:blank:]]\?:\)/
syn match LogPass       /\(^\([[:blank:]]\+\)\?\zs\cpass\(ed\)\?\ze:\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\cpass\(ed\)\?\ze[[:blank:]]\?:\)/
syn match LogOk         /\(^\([[:blank:]]\+\)\?\zs\c\(ok\|Ok\|OK\)\ze\([[:blank:]]\)\?\(:\)\?[[:blank:]]\+\)\|\([[:blank:]]\+\zs\c\(ok\|Ok\|OK\)\ze\([[:blank:]]\)\?:\)/
syn match LogHex        /\([[:blank:]]\+\|:\)\zs0x[[:xdigit:]]\+\ze[[:blank:]]\+/
syn match LogBool       /\(\([[:blank:]]\+\|:\)\zs\c\(true\|false\)\ze[[:blank:]]\+\)\|\(\([[:blank:]]\+\|:\)\zs\c\(true\|false\)\ze\([[:blank:]]\+\)\?$\)/ " true/false as value
" syn match LogKeyword /[[:blank:]]\+\(\c\h[a-zA-Z0-9_]\+\)[[:blank:]]\?:[[:blank:]]*/

hi LogError ctermfg=Red    ctermbg=0 guifg=Red    guibg=0
hi LogPass  ctermfg=Green  ctermbg=0 guifg=Green  guibg=0
hi LogWarn  ctermfg=Brown  ctermbg=0 guifg=Brown  guibg=0
hi LogInfo  ctermfg=Yellow ctermbg=0 guifg=Yellow guibg=0
hi LogDebug ctermfg=Cyan   ctermbg=0 guifg=Cyan   guibg=0

hi link LogError LogFail
hi link LogError LogException
hi link LogPass  LogOk

hi LogHex     ctermfg=Magenta      ctermbg=0 guifg=Magenta     guibg=0
hi LogBool    ctermfg=DarkMagenta  ctermbg=0 guifg=DarkMagenta guibg=0
" hi LogKeyword ctermfg=White        ctermbg=0 guifg=White       guibg=0

let b:current_syntax = "log"

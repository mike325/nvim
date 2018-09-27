" ############################################################################
"
"                           chromatica Setttings
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

if !exists('g:plugs["chromatica.nvim"]')
    finish
endif

let g:chromatica#enable_at_startup = 1

if WINDOWS()
    if filereadable('c:/Program Files/LLVM/bin/libclang.dll')
        let g:chromatica#libclang_path = 'c:/Program Files/LLVM/bin/libclang.dll'
    else
        let g:chromatica#libclang_path = 'c:/Program Files(x86)/LLVM/bin/libclang.dll'
    endif
else
    if filereadable(g:home . '/.local/lib/libclang.so')
        let g:chromatica#libclang_path = g:home . '/.local/lib/libclang.so'
    else
        let g:chromatica#libclang_path = '/usr/lib/libclang.so'
    endif
endif

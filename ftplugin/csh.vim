" ############################################################################
"
"                               csh Setttings
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

" CREDITS: https://github.com/demophoon/bash-fold-expr {{{
" LICENSE: MIT
function! GetCshFold()
    let line = getline(v:lnum)

    " End of if statement
    if line =~? '\v^\s*endif\s*$'
        return 's1'
    endif
    " Start of if statement
    if line =~? '\v^\s*if.*(\s*then)?$'
        return 'a1'
    endif

    " " End of while/for statement
    if line =~? '\v^\s*end\s*$'
        return 's1'
    endif

    " " Start of while/foreach statement
    if line =~? '\v^\s*(while|foreach).*'
        return 'a1'
    endif

    " " End of case statement
    " if line =~? '\v^\s*esac\s*$'
    "     return 's1'
    " endif

    " " Start of case statement
    " if line =~? '\v^\s*case.*(\s*in)$'
    "     return 'a1'
    " endif

    " End of function statement
    if line =~? '\v^\s*\}$'
        return 's1'
    endif

    " Start of function statement
    if line =~? '\v^\s*(function\s+)?\S+\(\) \{'
        return 'a1'
    endif

    " Default
    return '='

endfunction

setlocal foldmethod=expr
setlocal foldexpr=GetCshFold()

" }}}

" Since '$' is part of the variables, lets treat it as part of the word
setlocal iskeyword+=$

" ############################################################################
"
"                               zsh Setttings
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

" CREDITS: https://github.com/demophoon/zsh-fold-expr {{{
" LICENSE: MIT
function! GetZshFold()
    let l:line = getline(v:lnum)

    " End of if statement
    if l:line =~? '\v^\s*fi\s*$'
        return 's1'
    endif
    " Start of if statement
    if l:line =~? '\v^\s*if.*(;\s*then)?$'
        return 'a1'
    endif

    " End of while/for statement
    if l:line =~? '\v^\s*done\s*$'
        return 's1'
    endif
    " Start of while/for statement
    if l:line =~? '\v^\s*(while|for).*(;\s*do)?$'
        return 'a1'
    endif

    " End of case statement
    if l:line =~? '\v^\s*esac\s*$'
        return 's1'
    endif
    " Start of case statement
    if l:line =~? '\v^\s*case.*(\s*in)$'
        return 'a1'
    endif

    " End of function statement
    if l:line =~? '\v^\s*\}$'
        return 's1'
    endif
    " Start of function statement
    if l:line =~? '\v^\s*(function\s+)?\S+\(\) \{'
        return 'a1'
    endif

    " Default
    return '='

endfunction

setlocal foldmethod=expr
setlocal foldexpr=GetZshFold()

" }}}

" Since '$' is part of the variables, lets treat it as part of the word
setlocal iskeyword+=$
" let g:is_zsh = 1

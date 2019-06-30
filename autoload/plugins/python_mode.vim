" ############################################################################
"
"                             Python mode settings
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

function! plugins#python_mode#init(data) abort
    if  !exists('g:plugs["python-mode"]')
        return -1
    endif

    let g:pymode_rope                 = 0
    let g:pymode_rope_lookup_project  = 0
    let g:pymode_rope_complete_on_dot = 0
    let g:pymode_lint_on_write        = 0
    let g:pymode_lint_checkers        = ['mypy', 'flake8', 'pep8', 'mccabe']
    let g:ropevim_autoimport_modules  = [
        \   "os.*",
        \   "sys.*",
        \   "traceback",
        \   "django.*",
        \   "xml.etree",
        \ ]
endfunction

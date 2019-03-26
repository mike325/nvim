" ############################################################################
"
"                               abolish Setttings
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

function! plugins#vim_abolish#post() abort
    if !exists('g:plugs["vim-abolish"]') || exists(':Abolish') != 2
        return -1
    endif

    let l:abolish {
        \    'gti': 'git',
        \ }

    for [l:wrong, l:correct] in items(l:abolish)
        execute 'Abolish ' . l:wrong . ' '  . l:correct
    endfor

endfunction

function! plugins#vim_abolish#init(data) abort
    if !exists('g:plugs["vim-abolish"]')
        return -1
    endif

    augroup PostAbolish
        autocmd!
        autocmd VimEnter * call plugins#vim_abolish#post()
    augroup end
endfunction

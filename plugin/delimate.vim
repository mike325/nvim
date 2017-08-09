" ############################################################################
"
"                                YCM settings
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

if !exists('g:plugs["delimitMate"]')
    if !exists('g:plugs["ultisnips"]')
        inoremap <expr><CR> pumvisible() ? "\<C-y>" : "\<CR>"
    endif
    finish
endif

" let delimitMate_matchpairs = "(:),[:],{:},<:>"
" au FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"

" let delimitMate_expand_space = 1
" au FileType tcl let b:delimitMate_expand_space = 1

if !exists('g:plugs["ultisnips"]')
    function! HandleEmptyPairs()
        if pumvisible()
            return "\<C-y>"
        endif

        return delimitMate#ExpandReturn()
    endfunction

    inoremap <silent><CR>  <C-R>=HandleEmptyPairs()<CR>

    finish
endif

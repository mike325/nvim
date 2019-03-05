" ############################################################################
"
"                              DelimitMate settings
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

function! plugins#delimitmate#init(data) abort
    if !exists('g:plugs["delimitMate"]')
        return -1
    endif

    let g:delimitMate_expand_space = 1

    " let delimitMate_matchpairs = "(:),[:],{:},<:>"
    augroup DelimitMaters
        autocmd!
        autocmd FileType vim,html let b:delimitMate_matchpairs = "(:),[:],{:},<:>"
        autocmd FileType text let b:delimitMate_matchpairs = "(:),[:],{:},<:>,¿:?,¡:!"
        autocmd FileType c,cpp,java,perl let b:delimitMate_eol_marker = ";"
    augroup end

    " iunmap <BS>
    if exists("*delimitMate#BS")
        imap <silent> <BS> <Plug>delimitMateBS
    endif

endfunction

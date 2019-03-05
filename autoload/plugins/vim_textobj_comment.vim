" ############################################################################
"
"                               vim_textobj_comment Setttings
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

function! plugins#vim_textobj_comment#post() abort
    if !exists('g:plugs["vim-textobj-comment"]')
        return -1
    endif

    " Restore default comment object 'ic' and 'ac'
    " tcomment_vim overrides it and doesn't work so well
    silent! execute 'TextobjCommentDefaultKeyMappings!'
endfunction

function! plugins#vim_textobj_comment#init(data) abort
    if !exists('g:plugs["vim-textobj-comment"]')
        return -1
    endif

    augroup PostTextObjComments
        autocmd!
        autocmd VimEnter * call plugins#vim_textobj_comment#post()
    augroup end

endfunction

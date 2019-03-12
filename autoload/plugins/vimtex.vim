" ############################################################################
"
"                               vimtex Setttings
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

function! plugins#vimtex#init(data) abort
    if !exists('g:plugs["vimtex"]')
        return -1
    endif

    if executable('latexmk')
        let g:vimtex_compiler_method = 'latexmk'
    elseif executable('latexrun')
        let g:vimtex_compiler_method = 'latexrun'
    elseif executable('arara')
        let g:vimtex_compiler_method = 'arara'
    else
        let g:vimtex_enabled = 0
        finish
    endif

    if !has('nvim') && exists('+clientserver') && empty(v:servername) && exists('*remote_startserver') && !(os#name('windows') || os#name('cygwin')) && empty($SSH_CONNECTION)
        call remote_startserver('VIM')
    elseif has('nvim') && executable('nvr')
        let g:vimtex_compiler_progname = 'nvr'
    endif


    let g:vimtex_enabled = 1
    let g:vimtex_mappings_enabled = 0


    let g:vimtex_fold_enabled     = 1
    let g:vimtex_motion_enabled   = 1
    let g:vimtex_text_obj_enabled = 1
    let g:tex_flavor              = 'latex'
    " let g:vimtex_imaps_leader     = '`'
endfunction

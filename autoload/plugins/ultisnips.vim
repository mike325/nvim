" ############################################################################
"
"                              Ultisnips settings
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

function! plugins#ultisnips#nextsnippetorreturn() abort
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            if exists('g:plugs["YouCompleteMe"]')
                call feedkeys("\<C-y>")
                return ''
            else
                return "\<C-y>"
            endif
        else
            if exists('g:plugs["delimitMate"]') && delimitMate#WithinEmptyPair()
                return delimitMate#ExpandReturn()
            else
                call UltiSnips#JumpForwards()
                if g:ulti_jump_forwards_res == 0
                    return "\<CR>"
                endif
            endif
        endif
    endif
    return ''
endfunction

function! plugins#ultisnips#init(data) abort
    if !exists('g:plugs["ultisnips"]')
        return -1
    endif

    let g:UltiSnipsEditSplit           = 'context'
    let g:UltiSnipsSnippetsDir         = vars#basedir() . '/UltiSnips'
    let g:UltiSnipsSnippetDirectories  = [vars#basedir() . '/UltiSnips']
    let g:UltiSnipsExpandTrigger       = '<C-e>'

    " Remove all select mappigns in expanded snip
    " let g:UltiSnipsRemoveSelectModeMappings = 0

    let g:UltiSnipsUsePythonVersion = has#python('3') ? 3 : 2

    let g:ulti_expand_or_jump_res = 0
    let g:ulti_jump_backwards_res = 0
    let g:ulti_jump_forwards_res  = 0
    let g:ulti_expand_res         = 0


    function! NextSnippet()
        if pumvisible()
            return "\<C-n>"
        endif

        call UltiSnips#JumpForwards()
        if g:ulti_jump_forwards_res == 0
            return "\<TAB>"
        endif

        return ''
    endfunction

    function! PrevSnippetOrNothing()
        if pumvisible()
            return "\<C-p>"
        endif
        call UltiSnips#JumpBackwards()
        return ''
    endfunction

    inoremap <silent><TAB>    <C-R>=NextSnippet()<CR>
    inoremap <silent><S-TAB>  <C-R>=PrevSnippetOrNothing()<CR>
    inoremap <silent><CR>     <C-R>=plugins#ultisnips#nextsnippetorreturn()<CR>
    xnoremap <silent><CR>     :call UltiSnips#SaveLastVisualSelection()<CR>gv"_s
endfunction

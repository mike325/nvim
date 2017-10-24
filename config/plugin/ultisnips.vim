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

if !exists('g:plugs["ultisnips"]')
    finish
endif


let g:UltiSnipsEditSplit          = "context"
let g:UltiSnipsSnippetsDir        = g:base_path . "config/UltiSnips"
let g:UltiSnipsSnippetDirectories = ["UltiSnips"]
let g:UltiSnipsExpandTrigger      = "<C-e>"


if has('python3')
    let g:UltiSnipsUsePythonVersion = 3
endif

let g:ulti_expand_or_jump_res = 0
let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res  = 0
let g:ulti_expand_res         = 0

function! NextSnippetOrReturn()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            if exists('g:plugs["YouCompleteMe"]')
                call feedkeys("\<C-y>")
                return ""
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
    return ""
endfunction

function! NextSnippet()
    if pumvisible()
        return "\<C-n>"
    endif

    call UltiSnips#JumpForwards()
    if g:ulti_jump_forwards_res == 0
        return "\<TAB>"
    endif

    return ""
endfunction

function! PrevSnippetOrNothing()
    if pumvisible()
        return "\<C-p>"
    endif
    call UltiSnips#JumpBackwards()
    return ""
endfunction

" TODO: Improve TAB and S-TAB mappings
" inoremap <silent><TAB>   <C-R>=<SID>ExpandSnippetOrComplete()<CR>
" inoremap <silent><S-TAB> <C-R>=PrevSnippetOrNothing()<CR>
inoremap <silent><TAB>     <C-R>=NextSnippet()<CR>
inoremap <silent><S-TAB>   <C-R>=PrevSnippetOrNothing()<CR>
inoremap <silent><CR>    <C-R>=NextSnippetOrReturn()<CR>
xnoremap <silent><CR>    :call UltiSnips#SaveLastVisualSelection()<CR>gv"_s

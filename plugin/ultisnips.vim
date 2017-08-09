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

if !exists('g:plugs["ultisnips"]')
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""

    finish
endif


let g:UltiSnipsEditSplit          = "context"
let g:UltiSnipsSnippetsDir        = g:base_path . "UltiSnips"
let g:UltiSnipsSnippetDirectories = ["UltiSnips"]

if has('python3')
    let g:UltiSnipsUsePythonVersion = 3
endif

let g:ulti_expand_or_jump_res = 0
let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res  = 0
let g:ulti_expand_res         = 0

function! <SID>ExpandSnippetOrComplete()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-n>"
        else
            call UltiSnips#JumpForwards()
            if g:ulti_jump_forwards_res == 0
                return "\<TAB>"
            endif
        endif
    endif
    return ""
endfunction

function! NextSnippetOrReturn()
    call UltiSnips#ExpandSnippet()
    if g:ulti_expand_res == 0
        if pumvisible()
            return "\<C-y>"
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

function! NextSnippetOrNothing()
    call UltiSnips#JumpForwards()
    return g:ulti_jump_forwards_res
endfunction

function! PrevSnippetOrNothing()
    if pumvisible()
        return "\<C-p>"
    else
        call UltiSnips#JumpBackwards()
        return ""
    endif
endfunction

let g:UltiSnipsExpandTrigger       = "<C-e>"

" TODO: Improve TAB and S-TAB mappings
" inoremap <silent><TAB>   <C-R>=<SID>ExpandSnippetOrComplete()<CR>
" inoremap <silent><S-TAB> <C-R>=PrevSnippetOrNothing()<CR>
inoremap <expr><TAB>     pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB>   pumvisible() ? "\<C-p>" : ""
inoremap <silent><CR>    <C-R>=NextSnippetOrReturn()<CR>


" ############################################################################
"
"                             SnipMate settings
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

function! plugins#vim_snipmate#NextSnipOrReturn()
    if pumvisible()
        if exists('g:plugs["YouCompleteMe"]')
            call feedkeys("\<C-y>")
            return ""
        else
            return "\<C-y>"
        endif
    elseif exists('g:plugs["delimitMate"]') && delimitMate#WithinEmptyPair()
        return delimitMate#ExpandReturn()
    endif
    return "\<CR>"
endfunction

function! plugins#vim_snipmate#init(data) abort
    if !exists('g:plugs["vim-snipmate"]')
        return -1
    endif

    " TODO make SnipMate's mappings behave as UltiSnips ones
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""


    " Best crap so far
    inoremap <CR> <C-r>=snipMate#CanBeTriggered() ? snipMate#TriggerSnippet(1) : plugins#vim_snipmate#NextSnipOrReturn() <CR>
    xmap <CR>     <Plug>snipMateVisual

    " nnoremap <C-k> <Plug>snipMateNextOrTrigger
    imap <C-k> <Plug>snipMateNextOrTrigger
endfunction

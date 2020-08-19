" SnipMate settings
" github.com/mike325/.vim

if !has#plugin('vim-snipmate') || exists('g:config_snipmate')
    finish
endif

let g:config_snipmate = 1

function! plugins#vim_snipmate#NextSnipOrReturn() abort
    if pumvisible()
        if has#plugin('YouCompleteMe')
            call feedkeys("\<C-y>")
            return ''
        else
            return "\<C-y>"
        endif
    elseif has#plugin('delimitMate') && delimitMate#WithinEmptyPair()
        return delimitMate#ExpandReturn()
    endif
    return "\<CR>"
endfunction

" TODO make SnipMate's mappings behave as UltiSnips ones
inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""


" Best crap so far
inoremap <CR> <C-r>=snipMate#CanBeTriggered() ? snipMate#TriggerSnippet(1) : plugins#vim_snipmate#NextSnipOrReturn() <CR>
xmap <CR>     <Plug>snipMateVisual

" nnoremap <C-k> <Plug>snipMateNextOrTrigger
imap <C-k> <Plug>snipMateNextOrTrigger

" Vim_unimpaired Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-unimpaired"]') && exists('g:config_unimpaired')
    finish
endif

let g:config_unimpaired = 1

function! plugins#vim_unimpaired#post() abort
    if !exists('g:plugs["vim-unimpaired"]')
        return -1
    endif

    " Auto indent lines after move them
    nnoremap <silent> <Plug>unimpairedMoveUp            :<C-U>call <SID>Move('--',v:count1,'Up')<CR>
    nnoremap <silent> <Plug>unimpairedMoveDown          :<C-U>call <SID>Move('+',v:count1,'Down')<CR>
    noremap  <silent> <Plug>unimpairedMoveSelectionUp   :<C-U>call <SID>MoveSelectionUp(v:count1)<CR>
    noremap  <silent> <Plug>unimpairedMoveSelectionDown :<C-U>call <SID>MoveSelectionDown(v:count1)<CR>

    nnoremap [Q  :<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz
    nnoremap ]Q  :<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz
    nnoremap [q  :<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz
    nnoremap ]q  :<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz

    nnoremap [L  :<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz
    nnoremap ]L  :<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz
    nnoremap [l  :<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz
    nnoremap ]l  :<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz

endfunction

augroup PostAbolish
    autocmd!
    autocmd VimEnter * call plugins#vim_unimpaired#post()
augroup end

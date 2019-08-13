" Git gutter settings
" github.com/mike325/.vim

function! plugins#vim_gitgutter#init(data) abort
    if !exists('g:plugs["vim-gitgutter"]')
        return -1
    endif

    let g:gitgutter_map_keys = 0

    nnoremap tg :GitGutterToggle<CR>
    nnoremap tl :GitGutterLineHighlightsToggle<CR>

    nmap [h <Plug>GitGutterPrevHunk
    nmap ]h <Plug>GitGutterNextHunk

    nmap <leader>ghs <Plug>GitGutterStageHunk
    nmap <leader>ghu <Plug>GitGutterUndoHunk

    omap ih <Plug>GitGutterTextObjectInnerPending
    omap ah <Plug>GitGutterTextObjectOuterPending
    xmap ih <Plug>GitGutterTextObjectInnerVisual
    xmap ah <Plug>GitGutterTextObjectOuterVisual
endfunction

" Signify settings
" github.com/mike325/.vim

if !has#plugin('vim-signify') || exists('g:config_signify')
    finish
endif

let g:config_signify = 1

let g:signify_cursorhold_insert     = 1
let g:signify_cursorhold_normal     = 1
let g:signify_update_on_focusgained = 1
let g:signify_update_on_bufenter    = 0


let g:signify_skip_filetype = {
            \    'log': 1,
            \ }

let g:signify_skip_filename_pattern = [
            \   '*.log',
            \ ]

nmap ]h <plug>(signify-next-hunk)
nmap [h <plug>(signify-prev-hunk)

omap ih <plug>(signify-motion-inner-pending)
xmap ih <plug>(signify-motion-inner-visual)
omap ah <plug>(signify-motion-outer-pending)
xmap ah <plug>(signify-motion-outer-visual)

nnoremap <silent> =f :SignifyHunkDiff<CR>
nnoremap <silent> =u :SignifyHunkUndo<CR>

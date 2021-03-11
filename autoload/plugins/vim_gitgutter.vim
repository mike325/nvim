" vim_gitgutter Settings
" github.com/mike325/.vim

if !has#plugin('vim-gitgutter') || exists('g:config_gitgutter')
    finish
endif

let g:config_gitgutter = 1

" let g:gitgutter_git_executable = ''

let g:gitgutter_map_keys = 0
let g:gitgutter_sign_allow_clobber = 1
let g:gitgutter_grep = split(tools#select_grep(v:false), ' ')[0]
let g:gitgutter_close_preview_on_escape = 1

nmap ]h <Plug>(GitGutterNextHunk)
nmap [h <Plug>(GitGutterPrevHunk)]

nmap =s <Plug>(GitGutterStageHunk)
xmap <silent> =s :GitGutterStageHunk<CR>
nmap <silent> =f :GitGutterPreviewHunk<CR>


nmap =u <Plug>(GitGutterUndoHunk)

omap ih <Plug>(GitGutterTextObjectInnerPending)
omap ah <Plug>(GitGutterTextObjectOuterPending)
xmap ih <Plug>(GitGutterTextObjectInnerVisual)
xmap ah <Plug>(GitGutterTextObjectOuterVisual)

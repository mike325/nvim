" EasyMotions settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-easymotion"]') || exists('g:config_easymotion')
    finish
endif

let g:config_easymotion = 1

" Disable default mappings
let g:EasyMotion_do_mapping = 0
" Turn on ignore case
let g:EasyMotion_smartcase = 1

" \{char} to move to {char}
" search a character in the current buffer
nmap \ <Plug>(easymotion-bd-f)
vmap \ <Plug>(easymotion-bd-f)

" search a character in the current tab
nmap g\ <Plug>(easymotion-overwin-f)
vmap g\ <Plug>(easymotion-overwin-f)

" '/' search like
nmap  \/ <Plug>(easymotion-sn)
" omap \/ <Plug>(easymotion-tn)

" " repeat the last motion
" nmap <leader>. <Plug>(easymotion-repeat)
" vmap <leader>. <Plug>(easymotion-repeat)
" " repeat the next match of the current last motion
" nmap <leader>, <Plug>(easymotion-next)
" vmap <leader>, <Plug>(easymotion-next)
" " repeat the prev match of the current last motion
" nmap <leader>; <Plug>(easymotion-prev)
" vmap <leader>; <Plug>(easymotion-prev)

" ############################################################################
"
"                             EasyMotions settings
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

if !exists('g:plugs["vim-easymotion"]')
    finish
endif

" Disable default mappings
let g:EasyMotion_do_mapping = 0
" Turn on ignore case
let g:EasyMotion_smartcase = 1

" z{char} to move to {char}
" search a character in the current buffer
nmap \ <Plug>(easymotion-bd-f)
vmap \ <Plug>(easymotion-bd-f)
" search a character in the current layout
nmap <leader>\ <Plug>(easymotion-overwin-f)
vmap <leader>\ <Plug>(easymotion-overwin-f)

" repeat the last motion
nmap <leader>. <Plug>(easymotion-repeat)
vmap <leader>. <Plug>(easymotion-repeat)
" repeat the next match of the current last motion
nmap <leader>, <Plug>(easymotion-next)
vmap <leader>, <Plug>(easymotion-next)
" repeat the prev match of the current last motion
nmap <leader>; <Plug>(easymotion-prev)
vmap <leader>; <Plug>(easymotion-prev)

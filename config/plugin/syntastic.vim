" ############################################################################
"
"                               Syntastic settings
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

" WARNING: I just stopped using Syntastic since none of my dev systems
"          have old versions of Vim ( v:version < 8.0) or Neovim
"          I leave this just for old backward compatibility

if !exists('g:plugs["syntastic"]')
    finish
endif
"
" set sessionoptions-=blank
" Set passive mode by default, can be changed with tsc map
let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": ["python", "sh"],
    \ "passive_filetypes": ["puppet"]
    \ }

set statusline+=%#warningmsg#
set statusline+=%{SyntasticStatuslineFlag()}
set statusline+=%*

nnoremap tsc :SyntasticToggleMode<CR>

let g:syntastic_always_populate_loc_list = 1
let g:syntastic_auto_loc_list = 1
let g:syntastic_check_on_open = 0
let g:syntastic_check_on_wq = 0

let g:syntastic_python_checkers = ['flake8']

" Check Syntax in the current file
" inoremap <F5> <ESC>:SyntasticCheck<CR>a
" nnoremap <F5> :SyntasticCheck<CR>
"
" " Give information about current checkers
" inoremap <F6> <ESC>:SyntasticInfo<CR>a
" nnoremap <F6> :SyntasticInfo<CR>
"
" " Show the list of errors
" inoremap <F7> <ESC>:Errors<CR>a
" nnoremap <F7> :Errors<CR>
"
" " Hide the list of errors
" inoremap <F8> <ESC>:lclose<CR>a
" nnoremap <F8> :lclose<CR>

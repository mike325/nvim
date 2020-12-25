" vim_oscyank Setttings
" github.com/mike325/.vim

" TODO: Improve completor settings
if !has#plugin('vim-oscyank') || exists('g:config_vim_oscyank')
    finish
endif

let g:config_vim_oscyank = 1

if !empty($OSCTERM)
    let g:oscyank_term = $OSCTERM
elseif !empty($TMUX)
    let g:oscyank_term = 'tmux'
elseif os#name('windows')
    let g:oscyank_term = 'alacritty'
    " let g:oscyank_term = 'wt'
else
    let g:oscyank_term = 'kitty'
endif

" command! -nargs=1 -complete=customlist,{ arg, _, __ -> filter(['tmux', 'kitty', 'default'], "v:val =~? join(split(arg, 'zs'), '.*')") } OSCTerm let g:oscyank_term = <q-args>

" vnoremap <leader>c :OSCYank<CR>

augroup OSCYank
  autocmd!
  autocmd TextYankPost *
    \ if v:event.operator is 'y' && (v:event.regname ==? '' || v:event.regname ==? '*' || v:event.regname ==? '+') |
    \   silent call YankOSC52(getreg(v:event.regname)) |
    \ endif
augroup END

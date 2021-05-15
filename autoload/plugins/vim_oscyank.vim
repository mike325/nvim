" vim_oscyank Settings
" github.com/mike325/.vim

if !has#plugin('vim-oscyank') || exists('g:config_vim_oscyank')
    finish
endif

let g:config_vim_oscyank = 1

if !empty($OSCTERM)
    let g:oscyank_term = $OSCTERM
elseif executable('kitty')
    let g:oscyank_term = 'kitty'
elseif !empty($TMUX)
    let g:oscyank_term = 'tmux'
else
    let g:oscyank_term = 'default'
endif

function! plugins#vim_oscyank#terminals(args, _, __) abort
    return filter(['tmux', 'kitty', 'default'], "v:val =~? join(split(a:args, 'zs'), '.*')")
endfunction

command! -nargs=1 -complete=customlist,plugins#vim_oscyank#terminals OSCTerm let g:oscyank_term = <q-args>

" vnoremap <leader>c :OSCYank<CR>

augroup OSCYank
  autocmd!
  autocmd TextYankPost *
    \ if v:event.operator is 'y' && (v:event.regname ==? '' || v:event.regname ==? '*' || v:event.regname ==? '+') |
    \   silent call YankOSC52(getreg(v:event.regname)) |
    \ endif
augroup END

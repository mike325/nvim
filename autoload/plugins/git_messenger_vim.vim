" Git_messenger_vim Setttings
" github.com/mike325/.vim

function! plugins#git_messenger_vim#init(data) abort
    if !exists('g:plugs["git-messenger.vim"]')
        return -1
    endif
    nnoremap <silent><nowait> =m :GitMessenger<CR>
    " let g:git_messenger_preview_mods = ''
endfunction

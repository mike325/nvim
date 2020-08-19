" Git_messenger_vim Setttings
" github.com/mike325/.vim

if !has#plugin('git-messenger.vim') || exists('g:config_git_messenger')
    finish
endif

let g:config_git_messenger = 1

nmap <silent><nowait> =m <Plug>(git-messenger)

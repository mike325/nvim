" Git_messenger_vim Setttings
" github.com/mike325/.vim

if !exists('g:plugs["git-messenger.vim"]') || exists('g:config_git_messenger')
    finish
endif

let g:config_git_messenger = 1

nmap <silent><nowait> =m <Plug>(git-messenger)

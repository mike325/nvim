" Git_messenger_vim Settings
" github.com/mike325/.vim

if !has#plugin('git-messenger.vim') || exists('g:config_git_messenger')
    finish
endif

let g:config_git_messenger = 1

let g:git_messenger_no_default_mappings = 1
nmap <silent><nowait> =m <Plug>(git-messenger)

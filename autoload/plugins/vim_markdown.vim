" Markdown Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-markdown"]') && exists('g:config_markdown')
    finish
endif

let g:config_markdown = 1

let g:markdown_fenced_languages = [
    \ 'c',
    \ 'cpp',
    \ 'vim',
    \ 'sh',
    \ 'bash=sh',
    \ 'ruby',
    \ 'python',
    \ 'yaml',
    \ 'sql',
    \ ]

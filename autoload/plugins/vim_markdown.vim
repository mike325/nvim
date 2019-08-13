" Markdown Setttings
" github.com/mike325/.vim

function! plugins#vim_markdown#init(data) abort
    if !exists('g:plugs["vim-markdown"]')
        return -1
    endif

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
endfunction

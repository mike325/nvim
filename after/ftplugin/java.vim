" Java settings
" github.com/mike325/.vim

" Since we removed the Indent autocmd we need this shit in here
setlocal cindent
setlocal foldmethod=syntax

if has#option('formatprg')
    if executable('clang-format')
        setlocal formatprg=clang-format
    endif
endif

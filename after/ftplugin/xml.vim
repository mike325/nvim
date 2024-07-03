" xml Settings
" github.com/mike325/.vim

setlocal matchpairs+=<:>
setlocal foldmethod=syntax

let g:xml_syntax_folding = 1

if has#option('formatprg')
    if executable('xmllint')
        setlocal formatprg=xmllint\ --format\ -
    endif
endif

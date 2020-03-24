" Vim settings
" github.com/mike325/.vim

" Get help with 'K' key
setlocal foldmethod=indent " May change this for foldmarker
setlocal keywordprg=:help
setlocal matchpairs+=<:>
" setlocal iskeyword+=:

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

nnoremap <buffer> K :topleft help <C-r>=expand('<cword>')<CR><CR>
nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>

if executable('vint')
    setlocal makeprg=vint\ --no-color\ --style-problem\ -f\ \"{file_path}:{line_number}:{column_number}:\ {severity}:\ {description}\ \({policy_name})\ (see\ {reference})\"\ --enable-neovim\ %
    let &l:errorformat='%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c: %tote: %m'

    " TODO: Parse makeprg to use neomake
    " if exists('g:plugs["neomake"]')
    "     call plugins#neomake#makeprg()
    " endif
endif

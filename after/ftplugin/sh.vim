" Sh Settings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

let g:is_bash = 1
" let g:is_sh = 1
" let g:is_posix = 1

nnoremap <silent><buffer> <CR> :call mappings#cr()<CR>

if executable('shellcheck')
    setlocal makeprg=shellcheck\ -f\ gcc\ -e\ 1117,2034\ -x\ -a\ %
    let &l:errorformat='%f:%l:%c: %trror: %m [SC%n],%f:%l:%c: %tarning: %m [SC%n],%f:%l:%c: %tote: %m [SC%n]'
    if has#plugin('neomake')
        call plugins#neomake#makeprg()
    endif
endif

if !has#plugin('nvim-treesitter')
    let g:sh_fold_enabled = 4
    setlocal foldmethod=syntax
endif

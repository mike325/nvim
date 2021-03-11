" neovim Settings
" github.com/mike325/.vim

" This Autocmd file is wrapper around lua functions
" since we cannot pass lua funcref to neovim's internal options like opfunc

if !has('nvim')
    finish
endif

function! neovim#grep(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call luaeval('require"settings.functions".opfun_grep(_A[1], _A[2])', [a:type, l:visual])
endfunction

" neovim Settings
" github.com/mike325/.vim

" This Autocmd file is wrapper around lua functions
" since we cannot pass lua funcref to neovim's internal options like opfunc

if !has('nvim')
    finish
endif

" TODO: remove this
function! neovim#grep(type, ...) abort
    let l:visual = a:0 ? v:true : v:false
    call v:lua.require('utils.opfunc').grep(a:type, l:visual)
endfunction

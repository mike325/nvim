" Surround Setttings
" github.com/mike325/.vim

function! plugins#vim_surround#init(data) abort
    if !exists('g:plugs["vim-surround"]')
        return -1
    endif

    augroup Surrounders
        autocmd!
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_63 = '¿ \r ?'
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_168 = '¿ \r ?'
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_173 = '¡ \r !'
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_33 = '¡ \r !'
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_58 = ': \r :'
        autocmd FileType gitcommit,vimwiki,markdown,latex,tex,text,org let b:surround_59 = ': \r :'
    augroup end

endfunction

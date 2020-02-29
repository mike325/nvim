" SuperTab settings
" github.com/mike325/.vim

if !exists('g:plugs["supertab"]') && exists('g:config_supertab')
    finish
endif

let g:config_supertab = 1

let g:SuperTabDefaultCompletionType = 'context'
let g:SuperTabContextDefaultCompletionType = '<c-p>'
let g:SuperTabCompletionContexts = ['s:ContextText', 's:extDiscover']
let g:SuperTabContextDiscoverDiscovery = ['&omnifunc:<c-x><c-o>']

if !has('autocmd')
    return -1
endif

augroup SuperTabOmni
    autocmd!
    autocmd FileType *
            \ if &omnifunc != '' |
            \    call SuperTabChain(&omnifunc, "<c-p>") |
            \    call SuperTabSetDefaultCompletionType("<c-x><c-o>") |
            \ endif
augroup end

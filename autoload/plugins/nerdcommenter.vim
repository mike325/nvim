" NERDCommenter settings
" github.com/mike325/.vim

function! plugins#nerdcommenter#init(data) abort
    if !exists('g:plugs["nerdcommenter"]')
        return -1
    endif

    let g:NERDCompactSexyComs        = 0      " Use compact syntax for prettified multi-line comments
    let g:NERDSpaceDelims            = 1      " Add spaces after comment delimiters by default
    let g:NERDTrimTrailingWhitespace = 1      " Enable trimming of trailing whitespace when uncommenting
    let g:NERDCommentEmptyLines      = 1      " Allow commenting and inverting empty lines
                                            " (useful when commenting a region)
    let g:NERDDefaultAlign           = 'left' " Align line-wise comment delimiters flush left instead
                                            " of following code indentation
    let g:NERDCustomDelimiters = {
        \ 'python': { 'left': '#', 'leftAlt': '"""', 'rightAlt': '"""' },
        \ 'c': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' },
        \ 'cpp': { 'left': '//', 'leftAlt': '/**', 'rightAlt': '*/' }
        \ }
endfunction

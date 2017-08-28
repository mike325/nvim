" ############################################################################
"
"                            Autoformat settings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

if !exists('g:plugs["vim-autoformat"]')
    finish
endif

nnoremap <F9> :Autoformat<CR>
vnoremap <F9> :Autoformat<CR>

let g:autoformat_autoindent             = 1
let g:autoformat_retab                  = 0
let g:autoformat_remove_trailing_spaces = 0

" let g:formatters_python = []
" if executable("autopep8")
"     let g:formatters_python  += ['autopep8']
"     let g:formatdef_autopep8  = "'autopep8 --experimental --aggressive --max-line-length 100 --range '.a:firstline.' '.a:lastline"
" endif
"
" let g:formatters_python    += ['yapf']
" let g:formatter_yapf_style  = 'pep8'

" let g:formatters_go   = ['gofmt']
" let g:formatdef_gofmt = ''

if !has("autocmd")
    finish
endif

augroup AutoFormat
    autocmd!
    autocmd FileType vim let b:autoformat_autoindent=0

    autocmd FileType vim        autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType css        autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType markdown   autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType html       autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType javascript autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType xml        autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType python     autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType go         autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType cs         autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType php        autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType java       autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType c          autocmd BufWritePre <buffer> silent! Autoformat
    autocmd FileType cpp        autocmd BufWritePre <buffer> silent! Autoformat
augroup end

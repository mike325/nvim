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


function! CheckAutoFormat()
    let b:auto_format = get(b:,'auto_format',1)

    if b:auto_format == 1
       exec "Autoformat"
    endif
endfunction

noremap <F9> :Autoformat<CR>

let g:formatter_yapf_style = 'pep8'
let g:formatters_python = ['yapf']

if !has("autocmd")
    finish
endif

augroup AutoFormat
    autocmd!
    autocmd FileType vim,python let b:autoformat_autoindent=0
    autocmd FileType css        autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType html       autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType markdown   autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType javascript autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType xml        autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType python     autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType go         autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType cs         autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType php        autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType sh         autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType vim        autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType java       autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType cpp        autocmd BufWritePre silent! call CheckAutoFormat()
    autocmd FileType c          autocmd BufWritePre silent! call CheckAutoFormat()
augroup end

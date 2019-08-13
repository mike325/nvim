" Autoformat settings
" github.com/mike325/.vim

function! plugins#vim_autoformat#autoformatfile() abort
    if !exists('g:plugs["vim-autoformat"]') || !has("autocmd")
        return -1
    endif
    let b:auto_format = get(b:,'auto_format',0)
    if b:auto_format == 1
        silent! execute 'Autoformat'
    endif
endfunction

function! plugins#vim_autoformat#init(data) abort
    if !exists('g:plugs["vim-autoformat"]') || !has("autocmd")
        return -1
    endif

    " nnoremap <F9> :Autoformat<CR>
    " vnoremap <F9> :Autoformat<CR>

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

    augroup AutoFormat
        autocmd!
        autocmd FileType vim let b:autoformat_autoindent=0
        autocmd FileType vim        autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType css        autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType markdown   autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType html       autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType javascript autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType xml        autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType python     autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType go         autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType cs         autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType php        autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType java       autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType c          autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
        autocmd FileType cpp        autocmd BufWritePre <buffer> silent! call plugins#vim_autoformat#autoformatfile()
    augroup end
endfunction


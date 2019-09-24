" Vimtex Setttings
" github.com/mike325/.vim

function! plugins#vimtex#init(data) abort
    if !exists('g:plugs["vimtex"]')
        return -1
    endif

    if executable('latexmk')
        let g:vimtex_compiler_method = 'latexmk'
    elseif executable('latexrun')
        let g:vimtex_compiler_method = 'latexrun'
    elseif executable('arara')
        let g:vimtex_compiler_method = 'arara'
    else
        let g:vimtex_enabled = 0
        return -1
    endif

    if os#name('windows')
        let g:vimtex_compiler_latexmk_engines = {
            \ '_'                : '-pdf',
            \ 'pdflatex'         : '-shell-escape -synctex=1 -interaction=nonstopmode',
            \ 'dvipdfex'         : '-pdfdvi',
            \ 'lualatex'         : '-lualatex',
            \ 'xelatex'          : '-xelatex',
            \ 'context (pdftex)' : '-shell-escape -synctex=1 -interaction=nonstopmode',
            \ 'context (luatex)' : '-pdf -pdflatex=context',
            \ 'context (xetex)'  : "-pdf -pdflatex='texexec --xtx'",
            \}
    endif


    if !has('nvim') && exists('+clientserver') && empty(v:servername) && exists('*remote_startserver') && !(os#name('windows') || os#name('cygwin')) && empty($SSH_CONNECTION)
        call remote_startserver('VIM')
    elseif has('nvim') && executable('nvr')
        let g:vimtex_compiler_progname = 'nvr'
    endif


    let g:vimtex_enabled = 1
    let g:vimtex_mappings_enabled = 0

    if os#name('windows') && executable('sumatrapdf')
        let g:latex_viewer = 'SumatraPDF'
        let g:vimtex_view_general_viewer = 'SumatraPDF'
    endif

    let g:vimtex_quickfix_open_on_warning = 0

    let g:vimtex_fold_enabled     = 1
    let g:vimtex_motion_enabled   = 1
    let g:vimtex_text_obj_enabled = 1
    let g:tex_flavor              = 'latex'

    if exists('g:plugs["fzf"]') && exists('g:plugs["fzf.vim"]')
        augroup VimTexFZF
            autocmd!
            autocmd FileType tex command! -buffer Toc call vimtex#fzf#run()
            autocmd FileType tex nnoremap <buffer> <leader>t :call vimtex#fzf#run()<CR>
        augroup end
    endif

    " let g:vimtex_imaps_leader     = '`'
endfunction

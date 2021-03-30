" Vimtex Settings
" github.com/mike325/.vim

if !has#plugin('vimtex') || exists('g:config_vimtex')
    finish
endif

let g:config_vimtex = 1

if executable('latexmk')
    let g:vimtex_compiler_method = 'latexmk'

    let g:vimtex_compiler_latexmk = {
        \   'options': [
        \       '-pdf',
        \       '-shell-escape',
        \       '-verbose',
        \       '-file-line-error',
        \       '-synctex=1',
        \       '-pvc',
        \       '-interaction=nonstopmode',
        \   ]
        \ }

elseif executable('latexrun')
    let g:vimtex_compiler_method = 'latexrun'
elseif executable('arara')
    let g:vimtex_compiler_method = 'arara'
else
    let g:vimtex_enabled = 0
    finish
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


if !has('nvim') && has#option('clientserver') && empty(v:servername) && has#func('remote_startserver') && !(os#name('windows') || os#name('cygwin')) && empty($SSH_CONNECTION)
    call remote_startserver('VIM')
elseif has('nvim') && executable('nvr')
    let g:vimtex_compiler_progname = 'nvr'
endif

let g:vimtex_enabled          = 1
let g:vimtex_mappings_enabled = 0

if os#name('windows')
    if executable('sumatrapdf')
        let g:vimtex_view_general_viewer = 'SumatraPDF'
        let g:vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
        let g:vimtex_view_general_options_latexmk = '-reuse-instance'
    endif
endif

let g:vimtex_latexmk_build_dir           = 'output'
let g:vimtex_latexmk_async               = 1
let g:vimtex_latexmk_preview_continuosly = 1 " -pvc option in latexmk
let g:vimtex_latexmk_continuous          = 1
let g:vimtex_quickfix_open_on_warning    = 0

" let g:vimtex_fold_enabled     = 1
" let g:vimtex_motion_enabled   = 1
" let g:vimtex_text_obj_enabled = 1

" let g:vimtex_imaps_leader     = '`'

if has#plugin('fzf') && has#plugin('fzf.vim')
    augroup VimTexFZF
        autocmd!
        autocmd FileType tex command! -buffer Toc call vimtex#fzf#run()
        autocmd FileType tex nnoremap <buffer> <leader>t :call vimtex#fzf#run()<CR>
    augroup end
endif

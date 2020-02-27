" Ultisnips settings
" github.com/mike325/.vim

function! plugins#ultisnips#init(data) abort
    if !exists('g:plugs["ultisnips"]')
        return -1
    endif

    let g:UltiSnipsEditSplit           = 'context'
    let g:UltiSnipsSnippetsDir         = vars#basedir() . '/UltiSnips'
    let g:UltiSnipsSnippetDirectories  = [vars#basedir() . '/UltiSnips']
    let g:UltiSnipsExpandTrigger       = '<C-e>'

    " Remove all select mappigns in expanded snip
    " let g:UltiSnipsRemoveSelectModeMappings = 0

    let g:UltiSnipsUsePythonVersion = has#python(3, 5) ? 3 : 2

    let g:ulti_expand_or_jump_res = 0
    let g:ulti_jump_backwards_res = 0
    let g:ulti_jump_forwards_res  = 0
    let g:ulti_expand_res         = 0

    xnoremap <silent>       <CR>    :call UltiSnips#SaveLastVisualSelection()<CR>gv"_s

endfunction

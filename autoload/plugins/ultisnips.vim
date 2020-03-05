" Ultisnips settings
" github.com/mike325/.vim

if !exists('g:plugs["ultisnips"]') || exists('g:config_ultisnips')
    finish
endif

let g:config_ultisnips = 1

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

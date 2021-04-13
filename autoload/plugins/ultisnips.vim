" Ultisnips settings
" github.com/mike325/.vim

if !has#plugin('ultisnips') || exists('g:config_ultisnips')
    finish
endif

let g:config_ultisnips = 1

let g:UltiSnipsEditSplit           = 'context'
let g:UltiSnipsExpandTrigger       = '<C-,>'

" Remove all select mappigns in expanded snip
" let g:UltiSnipsRemoveSelectModeMappings = 0

let g:UltiSnipsUsePythonVersion = has#python(3, 5) ? 3 : 2

let g:ulti_expand_or_jump_res = 0
let g:ulti_jump_backwards_res = 0
let g:ulti_jump_forwards_res  = 0
let g:ulti_expand_res         = 0

let g:ultisnips_python_quoting_style = 'single'
let g:ultisnips_python_triple_quoting_style = 'single'
let g:ultisnips_python_style = 'google'

xnoremap <silent> <CR> :call UltiSnips#SaveLastVisualSelection()<CR>gv"_s

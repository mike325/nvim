" Tex Settings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

setlocal spell
setlocal textwidth=85
setlocal complete+=k,kspell " Add spell completion
setlocal iskeyword-=:
" setlocal foldmethod=indent

setlocal wrapmargin=80

let b:vimtex_main      = 'main.tex'
let g:tex_flavor       = 'latex'
let g:tex_conceal      = 'abdmgs'
let g:tex_fold_enabled = 1

if has('nvim-0.4')
    lua require"tools".helpers.abolish(require'nvim'.bo.spelllang)
else
    call tools#abolish(&spelllang)
endif

if !has#plugin('vimtex')
    " Credits to vimtex plugin
    let &include='\v^\s*\%\s*!?\s*[tT][eE][xX]\s+[rR][oO][oO][tT]\s*\=\s*\zs.*\ze\s*$|\v^\s*%(\v\\%(input|include|subfile)\s*\{|\v\\%(sub)?%(import|%(input|include)from)\*?\{[^\}]*\}\{)\zs[^\}]*\ze\}?'
    " let &includeexpr=''
endif

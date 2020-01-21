" Tex Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal tabstop=4
setlocal softtabstop=-1

setlocal spell
setlocal textwidth=80
setlocal complete+=k,kspell " Add spell completion
" setlocal foldmethod=indent

setlocal wrapmargin=80

" Always prefer latex over plain text for *.tex files
let g:tex_flavor = 'latex'
let b:vimtex_main = 'main.tex'


if has('nvim-0.4')
    call luaeval('tools.abolish("'.&l:spelllang.'")')
else
    call tools#abolish(&spelllang)
endif

if !exists('g:plugs["vimtex"]')
    " Credits to vimtex plugin
    let &include='\v^\s*\%\s*!?\s*[tT][eE][xX]\s+[rR][oO][oO][tT]\s*\=\s*\zs.*\ze\s*$|\v^\s*%(\v\\%(input|include|subfile)\s*\{|\v\\%(sub)?%(import|%(input|include)from)\*?\{[^\}]*\}\{)\zs[^\}]*\ze\}?'
    " let &includeexpr=''
endif

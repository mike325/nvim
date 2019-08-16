" Tex Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vimtex"]')
    " Credits to vimtex plugin
    let &include='\v^\s*\%\s*!?\s*[tT][eE][xX]\s+[rR][oO][oO][tT]\s*\=\s*\zs.*\ze\s*$|\v^\s*%(\v\\%(input|include|subfile)\s*\{|\v\\%(sub)?%(import|%(input|include)from)\*?\{[^\}]*\}\{)\zs[^\}]*\ze\}?'
    " let &includeexpr=''
endif

setlocal spell
setlocal textwidth=80
setlocal complete+=k,kspell " Add spell completion
" setlocal foldmethod=indent

setlocal wrapmargin=80

" Python Setttings
" github.com/mike325/.vim

setlocal foldmethod=indent

if exists('+formatprg')
    if executable('yapf')
        setlocal formatprg=yapf\ --style\ pep8
    elseif executable('autopep8')
        setlocal formatprg=autopep8\ --experimental\ --aggressive\ --max-line-length\ 120
    endif
endif

if executable('flake8')
    setlocal makeprg=flake8\ --max-line-length=120\ --ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203\ %
    let &efm='%f:%l:%c: %t%n %m'
elseif executable('pycodestyle')
    setlocal makeprg=pycodestyle\ --max-line-length=120\ --ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203\ %
    let &efm='%f:%l:%c: %t%n %m'
else
    setlocal makeprg=python3\ -c\ \"import\ py_compile,sys;\ sys.stderr=sys.stdout;\ py_compile.compile(r'%')\"
    setlocal efm=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
endif


function! s:PythonReplace(pattern) abort
    execute a:pattern
    call histdel('search', -1)
endfunction

function! s:PythonFix()
    normal! m`

    execute 'retab'

    let l:scout = "'"
    let l:dcout = '"'

    let l:patterns = [
    \   '%s/\s\zs==\ze\(\s\+\)\(None\|True\|False\)/is/g',
    \   '%s/\s\zs!=\ze\(\s\+\)\(None\|True\|False\)/is not/g',
    \   '%s/==\ze\(\s\+\)\(None\|True\|False\)/ is/g',
    \   '%s/!=\ze\(\s\+\)\(None\|True\|False\)/ is not/g',
    \   '%s/^\(\s\+\)\?\zs#\ze\([^ #!]\)/# /e',
    \   '%s/\(except\):/\1 Exception:/e',
    \   '%s/re\.compile(\zs\('.l:scout.'|"\)/r\1/g',
    \]
    " \   '%s/^\([^#][^[:space:]]\+\)(\s\+\([[:alnum:]]\+\)\s\+)/\1(\2)/g',
    " \   '%s/^\(\s*def\)\s\+\([[:alnum:]]\+\)\s*(\(.*\{-}=.*\{-}\)*)\s\+:/\1 \2(\3):/g',
    " \   '%s/^\([^#].*\)\(\s*\)\(if\|for\|while\)\(.*\):\s*\(return\|continue\|break\)$/\1\2\3\4:\r\1    \5/e',
    " \   '%s/[[:alnum:]_' . l:scout . l:dcout . ']\zs\(+\|-\|\/\|<<\|>>\|\(<\|>\|=\|!\|+\|-\|\/\|*\)=\)\ze[[:alnum:]_' . l:scout . l:dcout . ']/ \1 /g',
    " \   '%s/\(if\s\+\)\(not\s\+\)\{0,1}\(.*\)\.has_key(\(.*\))/\1\4 \2in \3',
    " \   '%s/\(print\)\s\+\("\|' . l:scout . '\)\(.*\)\2\(\s*%\s*\(\((.*)\)\|[_[:alnum:]]\+\|\(\("\|' . l:scout . '\).*\8\)\)\|\(\.format(.*)\)\)\?/\1(\2\3\2\4)/e',
    " \   '%s/\(print\)\s\+\([[:alnum:]]\)\(.*\)/\1(\2\3)/e',
    " \   '%s/\(except\s\+[[:alnum:]_.()]\+\)\s*,\s*\([[:alnum:]_]\+:\)/\1 as \2/e',
    " \   '%s/,\([[:alnum:]]\)/, \1/g',

    for l:pattern in l:patterns
        silent! call s:PythonReplace(l:pattern)
    endfor

    " try
    "     while 1
    "         let l:patterns = [
    "         \   '%s/^\s*def\s\+[[:alnum:]_]\+\s*(\zs\(.\{-}\)\s\+=\s\+\(.\{-}\)\(,\?\)\ze/\1=\2\3/g',
    "         \]
    "
    "         for l:pattern in l:patterns
    "             call s:PythonReplace(l:pattern)
    "         endfor
    "     endwhile
    " catch E486
    " endtry

    normal! ``
endfunction

command! -buffer PythonFix call s:PythonFix()

setlocal define=^\\s*\\(def\\\|class\\)\\s\\+

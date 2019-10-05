" Text Setttings
" github.com/mike325/.vim

setlocal nobackup
setlocal noswapfile

function! s:requireSpell(filename)
    if a:filename !~# '\v(.*require(ment)?s|require(ment)?s/.*|constraints)\.(txt|in)$'
        return 1
    endif

    return 0

endfunction

if s:requireSpell(expand('%:p'))
    setlocal spell
    setlocal complete+=k,kspell " Add spell completion
endif

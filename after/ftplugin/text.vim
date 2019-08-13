" Text Setttings
" github.com/mike325/.vim

setlocal nobackup
setlocal noswapfile

function! s:requireSpell()
    let l:file_name = expand('%:t:r')

    if l:file_name !~# '^\(requirements\)$'
        return 1
    endif

    return 0

endfunction

if s:requireSpell()
    setlocal spell
    setlocal complete+=k,kspell " Add spell completion
endif

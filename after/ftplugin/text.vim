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

    if has('nvim-0.4')
        lua require"tools".helpers.abolish(require'nvim'.bo.spelllang)
    else
        call tools#abolish(&l:spelllang)
    endif
endif

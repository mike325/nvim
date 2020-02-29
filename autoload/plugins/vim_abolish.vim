" Abolish Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-abolish"]') && exists('g:config_abolish')
    finish
endif

let g:config_abolish = 1

function! plugins#vim_abolish#post() abort
    if !exists('g:plugs["vim-abolish"]') || exists(':Abolish') != 2
        return -1
    endif

    let l:abolish = {
        \    'gti': 'git',
        \ }

    for [l:wrong, l:correct] in items(l:abolish)
        execute 'Abolish ' . l:wrong . ' '  . l:correct
    endfor

endfunction

augroup PostAbolish
    autocmd!
    autocmd VimEnter * call plugins#vim_abolish#post()
augroup end

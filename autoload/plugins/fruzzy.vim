" Fruzzy Setttings
" github.com/mike325/.vim

function! plugins#fruzzy#install(info) abort
    if !exists('g:plugs["fruzzy"]]')
        return -1
    endif
    if ( a:info.status ==# 'installed' || a:info.force ) && exists('*fruzzy#install()')
        call fruzzy#install()
    endif
endfunction

function! plugins#fruzzy#init(data) abort
    if !exists('g:plugs["fruzzy"]]')
        return -1
    endif
endfunction


" Fruzzy Setttings
" github.com/mike325/.vim

if !exists('g:plugs["fruzzy"]]') && exists('g:config_fruzzy')
    finish
endif

let g:config_fruzzy = 1

function! plugins#fruzzy#install(info) abort
    if !exists('g:plugs["fruzzy"]]')
        return -1
    endif
    if ( a:info.status ==# 'installed' || a:info.force ) && exists('*fruzzy#install()')
        call fruzzy#install()
    endif
endfunction

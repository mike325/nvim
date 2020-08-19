" Fruzzy Setttings
" github.com/mike325/.vim

if !has#plugin('fruzzy') || exists('g:config_fruzzy')
    finish
endif

let g:config_fruzzy = 1

function! plugins#fruzzy#install(info) abort
    if !has#plugin('fruzzy')
        return -1
    endif
    if ( a:info.status ==# 'installed' || a:info.force ) && has#func('fruzzy#install()')
        call fruzzy#install()
    endif
endfunction

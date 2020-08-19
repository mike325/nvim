" firenvim Setttings
" github.com/mike325/.vim

if !exists('g:started_by_firenvim') || !has#plugin('firenvim') || exists('g:config_firenvim')
    finish
endif

let g:config_firenvim = 1

" augroup FirenvimHacks
"     autocmd!
"     autocmd TextChanged * ++nested update
"     autocmd InsertLeave * ++nested update
" augroup end

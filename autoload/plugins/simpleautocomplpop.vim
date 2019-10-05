" SimpleAutoComplPop settings
" github.com/mike325/.vim

function! plugins#simpleautocomplpop#init(data) abort
    if !exists('g:plugs["SimpleAutoComplPop"]') || !has('autocmd')
        return -1
    endif

    " TODO Plugin Temporally disable, is currently unmaintained
    " TODO path completion should be improve
    " augroup SimpleAutoComplPopEvents
    "     autocmd!
    "     autocmd FileType * call sacp#enableForThisBuffer({ "matches": [
    "         \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>" , "ignoreCompletionMode":1} ,
    "         \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>" , "ignoreCompletionMode":1} ,
    "     \ ]})
    "
    "     autocmd FileType python call sacp#enableForThisBuffer({ "matches": [
    "         \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                           , "ignoreCompletionMode":1} ,
    "         \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)" , "ignoreCompletionMode":1} ,
    "         \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>"                           , "ignoreCompletionMode":1} ,
    "     \ ]})
    "
    "     autocmd FileType javascript,java,go call sacp#enableForThisBuffer({ "matches": [
    "         \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                           , "ignoreCompletionMode":1} ,
    "         \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)" , "ignoreCompletionMode":1} ,
    "         \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>"                           , "ignoreCompletionMode":1} ,
    "     \ ]})
    "
    "     autocmd BufNewFile,BufRead,BufEnter *.cpp,*.hpp,*.c,*.h call sacp#enableForThisBuffer({ "matches": [
    "         \ { '=~': '\v[a-zA-Z]{2}$' , 'feedkeys': "\<C-x>\<C-p>"                             , "ignoreCompletionMode":1} ,
    "         \ { '=~': '\.$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
    "         \ { '=~': '->$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
    "         \ { '=~': '::$'            , 'feedkeys': "\<Plug>(sacp_cache_fuzzy_omnicomplete)"   , "ignoreCompletionMode":1} ,
    "         \ { '=~': '/$'             , 'feedkeys': "\<C-x>\<C-f>" , "ignoreCompletionMode":1} ,
    "     \ ]})
    " augroup end
endfunction

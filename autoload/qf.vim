" quickfix Settings
" github.com/mike325/.vim

function! s:qf_first(win) abort
    if a:win
        lfirst
    else
        cfirst
    endif
endfunction

function! s:qf_last(win) abort
    if a:win
        llast
    else
        clast
    endif
endfunction

function! s:qf_open(win, size) abort
    let l:cmd = a:win ? 'lopen' : 'copen'
    if a:win
        call execute(l:cmd . " " . a:size)
    else
        let l:direction = &g:splitbelow ? 'botright' : 'topleft'
        call execute(l:direction . " " . l:cmd . " " . a:size)
    endif
endfunction

function! s:qf_close(win) abort
    if a:win
        lclose
    else
        cclose
    endif
endfunction

function! qf#is_open(win) abort
    if a:win
        return getloclist(win_getid(), { "winid": 0 }).winid != 0
    end
    return getqflist({ "winid": 0 }).winid != 0
endfunction

function! qf#open(win) abort
    if !qf#is_open(a:win)
        call s:qf_open(a:win, 20)
    endif
endfunction

function! qf#close(win) abort
    if qf#is_open(a:win)
        call s:qf_close(a:win)
    endif
endfunction

function! qf#get_list(win, what) abort
endfunction

function! qf#set_list(opts, what) abort
endfunction

function! qf#clear(win) abort
    call s:qf_set_list([], ' ', v:null, a:win)
    call qf#close(a:win)
endfunction


function! qf#dump_files(buffers, opts, win) abort
endfunction

function! qf#to_arglist(buffers, opts, win) abort
endfunction

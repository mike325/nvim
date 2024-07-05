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
        call execute(l:cmd . ' ' . a:size)
    else
        let l:direction = &g:splitbelow ? 'botright' : 'topleft'
        call execute(l:direction . ' ' . l:cmd . ' ' . a:size)
    endif
endfunction

function! s:qf_close(win) abort
    if a:win
        lclose
    else
        cclose
    endif
endfunction

function! s:qf_set_list(items, action, what, win) abort
    let l:items = len(a:items) > 0 ? a:items : []
    if a:win
        let l:win = a:win
        if type(l:win) == type(v:true) || l:win == 0
            let l:win = win_getid()
        endif
        if type(a:what) == type({}) && len(a:what) > 0
            call setloclist(l:win, l:items, a:action, a:what)
        else
            call setloclist(l:win, l:items, a:action)
        endif
    else
        if type(a:what) == type({}) && len(a:what) > 0
            call setqflist(l:items, a:action, a:what)
        else
            call setqflist(l:items, a:action)
        endif
    endif
endfunction

function! s:qf_get_list(what, win) abort
    let l:what = a:what
    let l:win = a:win
    if type(l:what) == type(1)
        if type(l:what) == type(l:win)
            throw 'what and win cannot be the same type'
        endif
        let l:win = l:what
        let l:what = v:null
    endif
    if l:win
        if type(l:win) == type(v:true) || l:win == 0
            let l:win = win_getid()
        endif
        if type(l:what) == type({}) && len(l:what) > 0
            return getloclist(l:win, l:what)
        endif
        return getloclist(l:win)
    endif
    if type(l:what) == type({}) && len(l:what) > 0
        return getqflist(l:what)
    endif
    return getqflist()
endfunction

function! qf#is_open(...) abort
    let l:win = get(a:000, 0, 0)
    if l:win
        return getloclist(win_getid(), { 'winid': 0 }).winid != 0
    endif
    return getqflist({ 'winid': 0 }).winid != 0
endfunction

function! qf#open(...) abort
    let l:win = get(a:000, 0, 0)
    let l:size = get(a:000, 1, 15)
    if !qf#is_open(l:win)
        call s:qf_open(l:win, l:size)
    endif
endfunction

function! qf#close(...) abort
    let l:win = get(a:000, 0, 0)
    if qf#is_open(l:win)
        call s:qf_close(l:win)
    endif
endfunction

function! qf#toggle(...) abort
    let l:win = get(a:000, 0, 0)
    let l:size = get(a:000, 1, 15)
    if qf#is_open(l:win)
        call s:qf_close(l:win)
    else
        call s:qf_open(l:win, l:size)
    endif
endfunction

function! qf#get_list(...) abort
    let l:what = get(a:000, 0, {})
    let l:win = get(a:000, 1, 0)
    return s:qf_get_list(l:what, l:win)
endfunction

function! qf#set_list(...) abort
    let l:opts = get(a:000, 0, {})
    let l:win = get(a:000, 1, 0)

    let l:action = get(l:opts, 'action', ' ')
    let l:items = get(l:opts, 'items', [])
    let l:open = get(l:opts, 'open', v:true)
    let l:jump = get(l:opts, 'jump', v:true)

    for l:key in ['action', 'items', 'open', 'jump']
        if has_key(l:opts, l:key)
            call remove(l:opts, l:key)
        endif
    endfor

    if type(l:items) != type([]) || len(l:items) == 0
        echoerr 'No items to display'
        return
    endif

    if type(l:items[1]) == type({})
        let l:opts['items'] = l:items
    elseif type(l:items[1]) == type('')
        let l:opts['lines'] = l:items
    else
        execute "throw 'Invalid items type: ". string(type(l:items[1])) . "'"
    endif

    let l:efm = get(l:opts, 'efm', &g:efm)
    if type(l:efm) == type([])
        let l:efm = join(l:efm, ',')
    endif
    let l:opts['efm'] = l:efm

    call s:qf_set_list([], l:action, l:opts, l:win)
    if l:open
        call qf#open(l:win)
    endif

    if l:jump
        call s:qf_first(l:win)
    endif
endfunction

function! qf#clear(...) abort
    let l:win = get(a:000, 0, 0)
    call s:qf_set_list([], ' ', v:null, l:win)
    call qf#close(l:win)
endfunction

function! qf#dump_files(buffers, ...) abort
    let l:opts = get(a:000, 0, {})
    let l:win = get(a:000, 1, 0)

    let l:items = []
    for l:buf in a:buffers
        let l:filename = type(l:buf) == type(1) ? bufname(l:buf) : l:buf

        let l:item = { 'valid': v:true, 'lnum': 1, 'col': 1, 'text': l:filename }
        if type(l:buf) == type(1)
            let l:item['bufnr'] = l:buf
        else
            let l:item['filename'] = l:buf
        endif
        let l:items += [l:item]
    endfor

    if len(l:items) > 0
        let l:open = get(l:opts, 'open', v:false)
        let l:jump = get(l:opts, 'jump', v:true)

        call qf#set_list({'items': l:items, 'open': l:open, 'jump': l:jump}, l:win)
    else
        echoerr 'No files to dump'
    endif
endfunction

function! qf#to_arglist(...) abort
    let l:opts = get(a:000, 0, {})
    let l:win = get(a:000, 1, 0)

    let l:clear = get(l:opts, 'clear', ' ')
    for l:key in ['clear']
        if has_key(l:opts, l:key)
            call remove(l:opts, l:key)
        endif
    endfor

    if type(l:win) == type(v:true)
        let l:win = win_getid()
    endif

    let l:items = qf#get_list({ 'items': v:true }, l:win)['items']
    let l:files = []
    for l:item in l:items
        let l:buf = get(l:item, 'bufnr', 0)
        if l:buf && bufexists(l:buf)
            let l:files += [l:buf]
        endif
    endfor
    call arglist#add(l:files, l:clear)
endfunction

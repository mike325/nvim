" ############################################################################
"
"                               vim_unimpaired Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

function! plugins#vim_unimpaired#post()
    if !exists('g:plugs["vim-unimpaired"]')
        return -1
    endif

    " Auto indent lines after move them
    nnoremap <silent> <Plug>unimpairedMoveUp            :<C-U>call <SID>Move('--',v:count1,'Up')<CR>
    nnoremap <silent> <Plug>unimpairedMoveDown          :<C-U>call <SID>Move('+',v:count1,'Down')<CR>
    noremap  <silent> <Plug>unimpairedMoveSelectionUp   :<C-U>call <SID>MoveSelectionUp(v:count1)<CR>
    noremap  <silent> <Plug>unimpairedMoveSelectionDown :<C-U>call <SID>MoveSelectionDown(v:count1)<CR>

    call s:map('n', '[e', '<Plug>unimpairedMoveUp')
    call s:map('n', ']e', '<Plug>unimpairedMoveDown')
    call s:map('x', '[e', '<Plug>unimpairedMoveSelectionUp')
    call s:map('x', ']e', '<Plug>unimpairedMoveSelectionDown')
endfunction

function! plugins#vim_unimpaired#init(data)
    if !exists('g:plugs["vim-unimpaired"]')
        return -1
    endif

    augroup PostAbolish
        autocmd!
        autocmd VimEnter * call plugins#vim_unimpaired#post()
    augroup end
endfunction

function! s:map(mode, lhs, rhs, ...) abort
    let flags = (a:0 ? a:1 : '') . (a:rhs =~# '^<Plug>' ? '' : '<script>')
    exe a:mode . 'map' flags a:lhs a:rhs
endfunction

function! s:ExecMove(cmd) abort
    let old_fdm = &foldmethod
    if old_fdm != 'manual'
        let &foldmethod = 'manual'
    endif
    normal! m`
    silent! exe a:cmd
    norm! ``
    if old_fdm != 'manual'
        let &foldmethod = old_fdm
    endif
endfunction

function! s:Move(cmd, count, map) abort
    call s:ExecMove('move'.a:cmd.a:count)
    silent! normal! ==
    silent! call repeat#set("\<Plug>unimpairedMove".a:map, a:count)
endfunction

function! s:MoveSelectionUp(count) abort
    call s:ExecMove("'<,'>move'<--".a:count)
    silent! normal! gv=
    silent! call repeat#set("\<Plug>unimpairedMoveSelectionUp", a:count)
endfunction

function! s:MoveSelectionDown(count) abort
    call s:ExecMove("'<,'>move'>+".a:count)
    silent! normal! gv=
    silent! call repeat#set("\<Plug>unimpairedMoveSelectionDown", a:count)
endfunction


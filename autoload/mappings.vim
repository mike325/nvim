" ############################################################################
"
"                               mappings Setttings
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

let s:arrows = -1

if has('nvim') || has('terminal')

    function! mappings#UnixShell() abort
        let l:shell = fnamemodify(expand($SHELL), ':t')
        if l:shell =~# '\(t\)\?csh'
            let l:shell = (executable('zsh')) ? 'zsh' : (executable('bash')) ? 'bash' : l:shell
        endif
        return l:shell
    endfunction

    function! mappings#terminal(cmd) abort
        let l:split = (&splitbelow) ? 'botright' : 'topleft'
        if os#name('windows')
            let l:shell = (&shell =~? '^cmd\(\.exe\)\?$') ? 'powershell -noexit -executionpolicy bypass ' : &shell
            if has('nvim')
                execute l:split . ' 20split term://' . l:shell . ' ' . a:cmd
            else
                call term_start(l:shell . a:cmd, {'term_rows': 20})
                wincmd J
            endif
        else
            let l:shell = mappings#UnixShell()
            if has('nvim')
                execute l:split . ' 20split term://' . l:shell . ' ' . a:cmd
            else
                call term_start(l:shell . a:cmd, {'term_rows': 20})
                wincmd J
            endif
        endif
        startinsert
    endfunction
endif

if exists('+mouse')
    function! mappings#ToggleMouse() abort
        if &mouse ==# ''
            execute 'set mouse=a'
            echo 'mouse'
        else
            execute 'set mouse='
            echo 'nomouse'
        endif
    endfunction
endif

if has('nvim') || v:version >= 704
    function! s:Filter(list, arg) abort
        let l:filter = filter(a:list, 'v:val =~ a:arg')
        return map(l:filter, 'fnameescape(v:val)')
    endfunction

    function! s:Formats(ArgLead, CmdLine, CursorPos) abort
        return s:Filter(['unix', 'dos', 'mac'], a:ArgLead)
    endfunction

    function! mappings#SetFileData(action, type, default) abort
        let l:param = (a:type ==# '') ? a:default : a:type
        execute 'setlocal ' . a:action . '=' . l:param
    endfunction
endif

if !exists('g:plugs["iron.nvim"]') && has#python()
    function! mappings#Python(version, args) abort
        let l:version = ( a:version  == 3 ) ? g:python3_host_prog : g:python_host_prog
        let l:split = (&splitbelow) ? 'botright' : 'topleft'

        if has('nvim')
            execute l:split . ' 20split term://'. l:version . ' ' . a:args
        elseif has('terminal')
            call term_start(l:version. ' ' . a:args, {'term_rows': 20})
            wincmd J
        endif

    endfunction
endif


if !exists('g:plugs["ultisnips"]') && !exists('g:plugs["vim-snipmate"]')
    function! mappings#NextSnippetOrReturn() abort
        if pumvisible()
            if exists('g:plugs["YouCompleteMe"]')
                call feedkeys("\<C-y>")
                return ''
            else
                return "\<C-y>"
            endif
        elseif exists('g:plugs["delimitMate"]') && delimitMate#WithinEmptyPair()
            return delimitMate#ExpandReturn()
        endif
        return "\<CR>"
    endfunction
endif

if !exists('g:plugs["vim-indexed-search"]')
    " TODO: Integrate center next into vim-slash
    " Center searches results
    " CREDITS: https://amp.reddit.com/r/vim/comments/4jy1mh/slightly_more_subltle_n_and_n_behavior/
    function! mappings#NiceNext(cmd) abort
        let view = winsaveview()
        execute 'silent! normal! ' . a:cmd
        if view.topline != winsaveview().topline
            silent! normal! zz
        endif
    endfunction
endif


function! mappings#Trim() abort
    " Since default is to trim, the first call is to deactivate trim
    if b:trim == 0
        let b:trim = 1
        echomsg ' Trim'
    else
        let b:trim = 0
        echomsg ' NoTrim'
    endif

    return 0
endfunction

" function! mappings#Spells(ArgLead, CmdLine, CursorPos) abort
"     return ['en', 'es']
" endfunction

" CREDITS: https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" Smart indent when entering insert mode with i on empty lines
function! mappings#IndentWithI() abort
    if len(getline('.')) == 0 && line('.') != line('$') && &buftype !~? 'terminal'
        return '"_ddO'
    else
        return 'i'
    endif
endfunction

" Remove buffers
"
" BufKill  will wipe all hidden buffers
" BufKill! will wipe all unloaded buffers
"
" CREDITS: https://vimrcfu.com/snippet/154
function! mappings#BufKill(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && (!buflisted(l:b) || (a:bang && !bufloaded(l:b)))
            execute 'bwipeout '.l:b
            let l:count += 1
        endif
    endfor
    echo 'Deleted ' . l:count . ' buffers'
endfunction

" Clean buffer list
"
" BufClean  will delete all non active buffers
" BufClean! will wipe all non active buffers
function! mappings#BufClean(bang) abort
    let l:count = 0
    for l:b in range(1, bufnr('$'))
        if bufexists(l:b) && ( (a:bang && !buflisted(l:b)) || (!a:bang && !bufloaded(l:b) && buflisted(l:b)) )
            execute ( (a:bang) ? 'bwipeout ' : 'bdelete! ' ) . l:b
            let l:count += 1
        endif
    endfor
    echo 'Deleted ' . l:count . ' buffers'
endfunction

" Test remap arrow keys
function! mappings#ToggleArrows() abort
    let s:arrows = s:arrows * -1
    if s:arrows == 1
        nnoremap <left>  <c-w><
        nnoremap <right> <c-w>>
        nnoremap <up>    <c-w>+
        nnoremap <down>  <c-w>-
    else
        unmap <left>
        unmap <right>
        unmap <up>
        unmap <down>
    endif
endfunction

function! mappings#ConncallLevel(level) abort
    let l:level = (!empty(a:level)) ? a:level : (&conceallevel > 0) ? 0 : 2
    let &conceallevel = l:level
endfunction

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
    function! mappings#terminal(cmd) abort
        if os#name('windows')
            if has('nvim')
                execute 'botright 20split term://powershell -noexit -executionpolicy bypass ' . a:cmd
            else
                call term_start('powershell -noexit -executionpolicy bypass ' . a:cmd, {'term_rows': 20})
                wincmd J
            endif
        else
            let l:shell = (executable('zsh')) ? 'zsh' : (executable('bash')) ? 'bash' : fnamemodify(expand($SHELL), ':h')
            if has('nvim')
                execute 'botright 20split term://' . l:shell . ' ' . a:cmd
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

        if has('nvim')
            execute 'botright 20split term://'. l:version . ' ' . a:args
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
    for b in range(1, bufnr('$'))
        if bufexists(b) && (!buflisted(b) || (a:bang && !bufloaded(b)))
            execute 'bwipeout '.b
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
    for b in range(1, bufnr('$'))
        if bufexists(b) && ( (a:bang && !buflisted(b)) || (!a:bang && !bufloaded(b) && buflisted(b)) )
            execute ( (a:bang) ? 'bwipeout ' : 'bdelete! ' ) . b
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


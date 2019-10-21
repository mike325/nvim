" FZF_vim Setttings
" github.com/mike325/.vim

" Took from https://www.reddit.com/r/vim/comments/a3e5q7/fzfvim_question_how_to_add_a_jumps_command/
 function! plugins#fzf_vim#GetRegisters() abort
    redir => cout
    silent registers
    redir END
    return split(cout, "\n")[1:]
endfunction

function! plugins#fzf_vim#UseRegister(line) abort
    let l:reg = getreg(a:line[1], 1, 1)
    let l:reg_type = getregtype(a:line[1])
    call setreg('"', l:reg, l:reg_type)
endfunction

function! plugins#fzf_vim#install(info) abort
    if !os#name('windows')
        let l:cmd = ['./install', '--all', '--no-update-rc']
        " if has('nvim')
        "
        "     let l:args = {
        "         \   'detach': 1,
        "         \ }
        "     silent! call jobstart(l:cmd, l:args)
        " else
        silent! call system(join(l:cmd, ' '))
        " endif
    endif
endfunction

function! plugins#fzf_vim#init(data) abort
    if !exists('g:plugs["fzf"]') || !exists('g:plugs["fzf.vim"]')
        return -1
    endif

    " preview function use bash, so windows support
    if os#name('windows') && &shell =~# '\v^cmd(\.exe)'
        let $FZF_DEFAULT_COMMAND = '( '.tools#select_filelist(1).' || '.tools#select_filelist(0).' ) 2> nul'
        let $FZF_CTRL_T_COMMAND = $FZF_DEFAULT_COMMAND
        if executable('fd')
            let $FZF_ALT_C_COMMAND = 'fd -t d . $HOME'
        endif
        let $FZF_DEFAULT_OPTS = '--layout=reverse --border --ansi'
    endif

    " Known fzf/kernel issue
    " https://github.com/junegunn/fzf/issues/1486
    if !os#name('windows') && system('uname -r') !~# '4\.\(4\.0-142\|15.0-44\)'
        command! -bang -nargs=? -complete=dir Files
            \ call fzf#vim#files(<q-args>, fzf#vim#with_preview('right:50%', 'ctrl-p'), <bang>0)
    elseif os#name('windows') && executable('bat')
        let g:fzf_files_options = ['--border', '--ansi', '--preview-window', 'right:50%', '--preview', 'bat --color=always {}']
    endif

    if has('nvim-0.4')
        let g:fzf_layout = { 'window': 'call tools#createFloatingBuffer(&lines - (float2nr(&lines * 0.1)))' }
    endif

    nnoremap <C-p> :Files<CR>
    nnoremap <C-b> :Buffers<CR>
    command! Oldfiles History
    command! Registers call fzf#run(fzf#wrap({
            \ 'source': plugins#fzf_vim#GetRegisters(),
            \ 'sink': function('plugins#fzf_vim#UseRegister')}))

endfunction

" FZF_vim Setttings
" github.com/mike325/.vim

if (!exists('g:plugs["fzf"]') || !exists('g:plugs["fzf.vim"]')) || exists('g:config_fzf')
    finish
endif

let g:config_fzf = 1

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
        silent! call system(join(l:cmd, ' '))
    endif
endfunction

" preview function use bash, so windows support
if (os#name('windows') && &shell =~# '\v^cmd(\.exe)') || empty($FZF_DEFAULT_COMMAND)
    let s:null = os#name('windows') ? 'nul' : '/dev/null'

    let $FZF_DEFAULT_COMMAND = '('.tools#select_filelist(1).' || '.tools#select_filelist(0).' ) 2> '.s:null
    let $FZF_DEFAULT_OPTS = '--layout=reverse --border --ansi ' . (!os#name('windows') ? ' --height 70%' : '')

endif

if empty($FZF_CTRL_T_COMMAND)
    let $FZF_CTRL_T_COMMAND = $FZF_DEFAULT_COMMAND
    if executable('fd')
        let $FZF_ALT_C_COMMAND = 'fd -t d . $HOME'
    endif
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
    let g:fzf_layout = { 'window': 'lua require("floating").window()' }
endif

" An action can be a reference to a function that processes selected lines
function! s:build_quickfix_list(lines) abort
    call setqflist(map(copy(a:lines), '{ "filename": v:val }'))
endfunction

let g:fzf_action = {
\   'ctrl-q': function('s:build_quickfix_list'),
\   'ctrl-t': 'tab split',
\   'ctrl-x': 'split',
\   'ctrl-v': 'vsplit'
\ }

nnoremap <C-p> :Files<CR>
nnoremap <C-b> :Buffers<CR>
command! Oldfiles History
command! Registers call fzf#run(fzf#wrap({
        \ 'source': plugins#fzf_vim#GetRegisters(),
        \ 'sink': function('plugins#fzf_vim#UseRegister')}))

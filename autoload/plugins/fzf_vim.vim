" ############################################################################
"
"                               fzf_vim Setttings
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

function! plugins#fzf_vim#init(data) abort
    if  !exists('g:plugs["fzf"]') || !exists('g:plugs["fzf.vim"]')
        return -1
    endif

    nnoremap <C-p> :Files<CR>
    nnoremap <C-b> :Buffers<CR>

    command! Oldfiles History

    command! Registers call fzf#run(fzf#wrap({
            \ 'source': plugins#fzf_vim#GetRegisters(),
            \ 'sink': function('plugins#fzf_vim#UseRegister')}))

    " preview function use bash, so windows support
    if os#name('windows') && &shell =~# '\v^cmd(\.exe)'
        let $FZF_DEFAULT_COMMAND = '( git --no-pager ls-files -co --exclude-standard || '.tools#select_filelist(0).' ) 2> nul'
        let $FZF_CTRL_T_COMMAND = $FZF_DEFAULT_COMMAND
        if executable('fd')
            let $FZF_ALT_C_COMMAND = 'fd -t d . $HOME'
        endif
        let $FZF_DEFAULT_OPTS = '--layout=reverse --border --ansi'
        if executable('bat')
            let $FZF_DEFAULT_OPTS = $FZF_DEFAULT_OPTS . ' --preview-window "right:60%" --preview "bat --color=always --line-range :300 {}"'
        endif
    endif
endfunction

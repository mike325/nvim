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

function! plugins#fzf_vim#init(data) abort
    if  !exists('g:plugs["fzf"]') || !exists('g:plugs["fzf.vim"]')
        return -1
    endif

    nnoremap <C-p> :Files<CR>
    nnoremap <C-b> :Buffers<CR>

    " preview function use bash, so windows support
    if os#name('windows') && &shell =~# '\v^cmd(\.exe)'
        let $FZF_DEFAULT_COMMAND = '( git ls-tree -r --name-only HEAD || '.tools#select_filelist(0).' ) 2> nul'
        let $FZF_CTRL_T_COMMAND = $FZF_DEFAULT_COMMAND
        if executable('fd')
            let $FZF_ALT_C_COMMAND = 'fd -t d . $HOME'
        endif
        let $FZF_DEFAULT_OPTS = '--layout=reverse --border'
    endif
endfunction

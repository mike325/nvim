" ############################################################################
"
"                               nvim Setttings
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

" let s:load_remotes = 0

" augroup UpdateRemotes
"     autocmd!
"     autocmd VimEnter * if s:load_remotes == 1 | UpdateRemotePlugins | endif
" augroup end

function! nvim#updateremoteplugins(info) abort
    if has('nvim')
        let s:load_remotes = 1
    endif
endfunction

function! nvim#init() abort
    if !has('nvim')
        return -1
    endif
    " Disable some vi compatibility
    if !exists('g:plugs["traces.vim"]')
        " Live substitute preview
        set inccommand=split
    endif

    if executable('nvr')
        " Add Neovim remote utility, this allow us to open buffers from the :terminal cmd
        let $nvr = 'nvr --remote-silent'
        let $tnvr = 'nvr --remote-tab-silent'
        let $vnvr = 'nvr -cc vsplit --remote-silent'
        let $snvr = 'nvr -cc split --remote-silent'
    endif

    let g:terminal_scrollback_buffer_size = 100000

    if has('nvim-0.3.3')
        set diffopt=internal,filler,vertical,iwhiteall,iwhiteeol,indent-heuristic,algorithm:patience
    endif

endfunction

" ############################################################################
"
"                               vimwiki Setttings
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

" if !has#gui() " Terminals can't detect some special key combinations
" endif

nmap <buffer> gww <Plug>VimwikiIndex
nmap <buffer> gws :VimwikiSearchTags<space>
" nmap <buffer> <leader>gt :VimwikiGenerateTags<CR>

if os#name('windows') && !has#gui()
    nmap <buffer> <CR> <Plug>VimwikiFollowLink

    if has('nvim')
        " Windows powershell/cmd uses <C-h> as backspace
        nmap <buffer> <C-h> <Plug>VimwikiGoBackLink
    endif

endif

nmap <buffer> - <Plug>VimwikiToggleListItem
vmap <buffer> - <Plug>VimwikiToggleListItem
nmap <buffer> g- <Plug>VimwikiRemoveSingleCB
vmap <buffer> g- <Plug>VimwikiRemoveSingleCB

nmap <buffer> g<CR> <Plug>VimwikiVSplitLink

nmap <buffer> <C-j> <Plug>VimwikiNextLink
nmap <buffer> <C-k> <Plug>VimwikiPrevLink

nmap <buffer> g= <Plug>VimwikiRemoveHeaderLevel


nnoremap <buffer> gwt :VimwikiTable<CR>
nnoremap <buffer> gwg :VimwikiGoto<space>

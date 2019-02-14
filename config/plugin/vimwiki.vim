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

if !exists('g:plugs["vimwiki"]')
    finish
endif


let s:work_wiki = {
                \   'path': '~/Documents/VimWiki/work',
                \   'syntax': 'markdown',
                \   'ext': '.md',
                \ }

let s:personal_wiki = {
                \   'path': '~/VimWiki/personal',
                \   'syntax': 'markdown',
                \   'ext': '.md',
                \ }


if os#name('windows')
    let g:vimwiki_list = [ s:work_wiki, s:personal_wiki ]
else
    let g:vimwiki_list = [ s:personal_wiki, s:work_wiki ]
endif

unlet s:work_wiki
unlet s:personal_wiki

nmap gww <Plug>VimwikiIndex
nmap gwt <Plug>VimwikiTabIndex
nmap gwd <Plug>VimwikiDiaryIndex
nmap gwn <Plug>VimwikiMakeDiaryNote
nmap gwu <Plug>VimwikiUISelect

" nmap <Leader>dt <Plug>VimwikiTabMakeDiaryNote
" nmap <Leader>dy <Plug>VimwikiMakeYesterdayDiaryNote
" nmap <Leader>dm <Plug>VimwikiMakeTomorrowDiaryNote

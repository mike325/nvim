" ############################################################################
"
"                               vimtex Setttings
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

if !exists('g:plugs["vimtex"]')
    finish
endif

let g:vimtex_mappings_enabled = 0
let g:vimtex_enabled = 1

if executable('latexmk')
    let g:vimtex_compiler_method = 'latexmk'
elseif executable('latexrun')
    let g:vimtex_compiler_method = 'latexrun'
elseif executable('arara')
    let g:vimtex_compiler_method = 'arara'
endif

" inoremap ]] <plug>(vimtex-delim-close)
"
" nnoremap %  <plug>(vimtex-%)
" nnoremap ]] <plug>(vimtex-]])
" nnoremap ][ <plug>(vimtex-][)
" nnoremap [] <plug>(vimtex-[])
" nnoremap [[ <plug>(vimtex-[[)
" nnoremap ]m <plug>(vimtex-]m)
" nnoremap ]M <plug>(vimtex-]M)
" nnoremap [m <plug>(vimtex-[m)
" nnoremap [M <plug>(vimtex-[M)
" nnoremap ]/ <plug>(vimtex-]/
" nnoremap ]* <plug>(vimtex-]star
" nnoremap [/ <plug>(vimtex-[/
" nnoremap [* <plug>(vimtex-[star
" nnoremap K  <plug>(vimtex-doc-package)
"
" vnoremap %  <plug>(vimtex-%)
" vnoremap ]] <plug>(vimtex-]])
" vnoremap ][ <plug>(vimtex-][)
" vnoremap [] <plug>(vimtex-[])
" vnoremap [[ <plug>(vimtex-[[)
" vnoremap ]m <plug>(vimtex-]m)
" vnoremap ]M <plug>(vimtex-]M)
" vnoremap [m <plug>(vimtex-[m)
" vnoremap [M <plug>(vimtex-[M)
" vnoremap ]/ <plug>(vimtex-]/
" vnoremap ]* <plug>(vimtex-]star
" vnoremap [/ <plug>(vimtex-[/
" vnoremap [* <plug>(vimtex-[star
" vnoremap K  <plug>(vimtex-doc-package)

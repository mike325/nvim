" ############################################################################
"
"                                YCM settings
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

if !exists('g:plugs["YouCompleteMe"]')
    finish
endif

let g:ycm_complete_in_comments                      = 1
let g:ycm_seed_identifiers_with_syntax              = 1
let g:ycm_add_preview_to_completeopt                = 1
let g:ycm_autoclose_preview_window_after_completion = 1
let g:ycm_autoclose_preview_window_after_insertion  = 1
let g:ycm_key_detailed_diagnostics                  = '<leader>D'

if executable("ctags")
    let g:ycm_collect_identifiers_from_tags_files = 1
endif

nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>
inoremap <F5> :YcmForceCompileAndDiagnostics<CR>

nnoremap <leader>F :YcmCompleter FixIt<CR>
nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
nnoremap <leader>gg :YcmCompleter GoTo<CR>
nnoremap <leader>gp :YcmCompleter GetParent<CR>
nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
nnoremap <leader>gt :YcmCompleter GetType<CR>

let g:ycm_key_list_select_completion = ['<C-n>', '<Down>']
let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']

" In case there are other completion plugins
" let g:ycm_filetype_blacklist = {
"       \ 'tagbar' : 1,
"       \}

" In case there are other completion plugins
" let g:ycm_filetype_specific_completion_to_disable = {
"       \ 'gitcommit': 1
"       \}

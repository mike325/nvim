" ############################################################################
"
"                                CtrlP settings
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

if !exists('g:plugs["ctrlp.vim"]')
    finish
endif

let g:ctrlp_map = '<C-p>'
let g:ctrlp_cmd = 'CtrlP'

nnoremap <C-b> :CtrlPBuffer<CR>
nnoremap <C-f> :CtrlPMRUFiles<CR>
nnoremap <C-q> :CtrlPQuickfix<CR>

if exists('g:plugs["ctrlp-modified.vim"]')
    nnoremap <C-x> :CtrlPModified<CR>
endif

" :CtrlPRTS
" :CtrlPMixed

let g:ctrlp_extensions = ['quickfix', 'undo', 'line', 'changes', 'mixed']

" Do not clear filenames cache, to improve CtrlP startup
" You can manualy clear it by <F5>

let g:ctrlp_clear_cache_on_exit = 0
let g:ctrlp_by_filename         = 1
let g:ctrlp_follow_symlinks     = 1
let g:ctrlp_mruf_case_sensitive = 1
let g:ctrlp_show_hidden         = 1

" CtrlP's windows settings
let g:ctrlp_match_window        = 'bottom,order:ttb,min:1,max:30,results:50'
" Search files in the current repo or in the file's dir
let g:ctrlp_working_path_mode   = 'rw'
" Opens files in the current windows, whether or not they had been opened in others windows
let g:ctrlp_switch_buffer       = 'et'


let g:ctrlp_funky_multi_buffers = 1
let g:ctrlp_funky_sort_by_mru   = 1

let g:ctrlp_cache_dir = g:parent_dir . 'cache/ctrlp'

if exists('g:plugs["ctrlp-cmatcher"]')
    let g:ctrlp_match_func = {'match' : 'matcher#cmatch' }

    " Set no file limit, we are building a big project
    let g:ctrlp_max_files   = 0
    " let g:ctrlp_lazy_update = 350
elseif exists('g:plugs["ctrlp-py-matcher"]')
    let g:ctrlp_match_func = { 'match': 'pymatcher#PyMatch' }

    " Set no file limit, we are building a big project
    let g:ctrlp_max_files   = 0
    " let g:ctrlp_lazy_update = 350
endif

let g:ctrlp_user_command = {
    \   'types': {
    \       1: ['.git', 'cd %s && git ls-files -co --exclude-standard' . g:ignore_patterns.git ]
    \   },
    \   'fallback': 'find %s -type f -iname "*" ' . g:ignore_patterns.find ,
    \ }

if executable("ag")
    " Since we have Ag and Git we can clean cache on exit
    let g:ctrlp_clear_cache_on_exit = 1
    let g:ctrlp_user_command.fallback = 'ag %s -U -S -l --nocolor --nogroup --hidden '. g:ignore_patterns.ag . '-g ""'
elseif has("win32") || has("win64")
    " Actually I don't use Windows that much, so if someone comes with
    " something better I will definitely use it
    let g:ctrlp_user_command.fallback =  'dir %s /-n /b /s /a-d'
endif

" NOTE: This only works if g:ctrlp_user_command is not set
" let g:ctrlp_custom_ignore = {
"             \ 'file': '\v\.(',
"             \ 'dir':  '\v[\/](',
"             \ }
"
" for [ ignore_type, ignore_list ] in items(g:ignores)
"
"     " I don't want to ignore logs from CtrlP list
"     if ignore_type == "logs"
"         continue
"     endif
"
"     for item in ignore_list
"         if ignore_type == "vcs"
"             let g:ctrlp_custom_ignore.dir  .= "\\." . item . "|"
"         elseif ignore_type == "tmp_dir"
"             " Add both versions, normal and hidden
"             let g:ctrlp_custom_ignore.dir  .= item . "|"
"             let g:ctrlp_custom_ignore.dir  .= "\\." . item . "|"
"         elseif l:ignore_type != "full_name_files"
"             let g:ctrlp_custom_ignore.file .= item . "|"
"         endif
"     endfor
"
"     let g:ctrlp_custom_ignore.file = substitute(g:ctrlp_custom_ignore.file, "\\$", "", "")
"     let g:ctrlp_custom_ignore.dir  = substitute(g:ctrlp_custom_ignore.dir, "\\$", "", "")
" endfor
"
" let g:ctrlp_custom_ignore.file = substitute(g:ctrlp_custom_ignore.file, "|$", "", "") . ')$'
" let g:ctrlp_custom_ignore.dir  = substitute(g:ctrlp_custom_ignore.dir, "|$", "", "") . ')$'

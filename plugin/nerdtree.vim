" ############################################################################
"
"                               NERDTree settings
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

if !exists('g:plugs["nerdtree"]')
    finish
endif

" Enable line numbers
let g:NERDTreeShowLineNumbers=1
" Make sure relative line numbers are used
augroup NERDNumbers
    autocmd!
    autocmd FileType nerdtree setlocal relativenumber
augroup end
if exists("*mkdir")
    if !isdirectory(fnameescape(g:parent_dir . 'cache/NERDTree/'))
        call mkdir(fnameescape(g:parent_dir . 'cache/NERDTree/'), "p")
    endif
endif

if ( isdirectory(fnameescape(g:parent_dir . 'cache/NERDTree/')) ) && exists("g:parent_dir")
    let g:NERDTreeBookmarksFile = g:parent_dir . 'cache/NERDTree/Bookmarks'
endif

let g:NERDTreeRespectWildIgnore  = 1
let g:NERDTreeShowBookmarks      = 1
let g:NERDTreeIndicatorMapCustom = {
    \   "Modified"  : "✹",
    \   "Staged"    : "✚",
    \   "Untracked" : "✭",
    \   "Renamed"   : "➜",
    \   "Unmerged"  : "═",
    \   "Deleted"   : "✖",
    \   "Dirty"     : "✗",
    \   "Clean"     : "✔︎",
    \   "Unknown"   : "?"
    \}

" Ignore files in NERDTree
function! s:GetNerdIgnores()
    " let g:NERDTreeIgnore = ['\.pyc$', '\~$', '\.sw$', '\.swp$']
    let g:NERDTreeIgnore = []

    for [ l:ignore_type, l:ignore_list ] in items(g:ignores)
        " I don't want to ignore logs here
        if l:ignore_type == "logs" || l:ignore_type == "bin" || l:ignore_type == "vcs"
            continue
        endif

        for l:item in l:ignore_list
            let l:ignore_pattern = []

            if l:ignore_type == "tmp_dir"
                " Add both version, normal and hidden
                let l:ignore_pattern = [ l:item . "$[[dir]]" ,  "\\." . l:item . "$[[dir]]" ]
            elseif l:ignore_type != "full_name_files"
                let l:ignore_pattern = [ "\\." . fnameescape(l:item) . "$[[file]]" ]
            else
                let l:ignore_pattern = [ l:item . "$[[file]]" ]
            endif

            let g:NERDTreeIgnore += l:ignore_pattern
        endfor
    endfor
endfunction

if !exists("g:NERDTreeIgnore") || len(g:NERDTreeIgnore) == 0
    call s:GetNerdIgnores()
endif


if !empty($NO_COOL_FONTS)
    let NERDTreeDirArrowExpandable  = '+'
    let NERDTreeDirArrowCollapsible = '~'
endif

" nnoremap <F3> :NERDTreeToggle<CR>
" nnoremap T :NERDTreeToggle<CR>

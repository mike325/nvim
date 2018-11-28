" ############################################################################
"
"                               tools Setttings
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

let s:greplist = {
            \   'git': {
            \       'grepprg': 'git --no-pager grep --no-color -Iin ',
            \       'grepformat': '%f:%l:%m'
            \    },
            \   'rg' : {
            \       'grepprg':  'rg -S -n --color never -H --no-search-zip --trim --vimgrep ',
            \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
            \   },
            \   'ag' : {
            \       'grepprg': 'ag -S -l --follow --nogroup --nocolor --hidden --vimgrep ' . vars#ignore_cmd('ag') . ' ',
            \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
            \   },
            \   'grep' : {
            \       'grepprg': 'grep -HiIn --color=never ' . vars#ignore_cmd('grep') . ' ',
            \       'grepformat': '%f:%l:%m'
            \   },
            \   'findstr' : {
            \       'grepprg': 'findstr -rspn ' . vars#ignore_cmd('findstr') . ' ',
            \       'grepformat': '%f:%l:%m'
            \   },
            \}

let s:filelist = {
            \   'git': 'git --no-pager ls-files -co --exclude-standard',
            \   'rg' : 'rg --with-filename --color never --no-search-zip --hidden --trim --files',
            \   'ag' : 'ag -l --follow --nocolor --nogroup --hidden '. vars#ignore_cmd('ag') . ' -g ""',
            \}


" Small wrap to avoid change code all over the repo
function! tools#grep(tool, properity) abort
    return s:greplist[a:tool][a:properity]
endfunction

" Just like GrepTool but for listing files
function! tools#filelist(tool) abort
    return s:filelist[a:tool]
endfunction

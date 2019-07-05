" ############################################################################
"
"                               vim-plug Setttings
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

function! s:plug_doc() abort
    let name = matchstr(getline('.'), '^- \zs\S\+\ze:')
    if has_key(g:plugs, name)
        for doc in split(globpath(g:plugs[name].dir, 'doc/*.txt'), '\n')
        execute 'tabe' doc
        endfor
    endif
endfunction

function! s:plug_gx() abort
    let line = getline('.')
    let sha  = matchstr(line, '^  \X*\zs\x\{7,9}\ze ')
    let name = empty(sha) ? matchstr(line, '^[-x+] \zs[^:]\+\ze:')
                        \ : getline(search('^- .*:$', 'bn'))[2:-2]
    let uri  = get(get(g:plugs, name, {}), 'uri', '')
    if uri !~# 'github.com'
        return
    endif
    let repo = matchstr(uri, '[^:/]*/'.name)
    let url  = empty(sha) ? 'https://github.com/'.repo
                        \ : printf('https://github.com/%s/commit/%s', repo, sha)
    call netrw#BrowseX(url, 0)
endfunction

function! s:scroll_preview(down) abort
    silent! wincmd P
    if &previewwindow
        execute 'normal!' a:down ? "\<c-e>" : "\<c-y>"
        wincmd p
    endif
endfunction

nnoremap <buffer> <silent> gx :call <sid>plug_gx()<CR>
nnoremap <silent> <buffer> H :call <sid>plug_doc()<CR>
nnoremap <silent> <buffer> J :call <sid>scroll_preview(1)<CR>
nnoremap <silent> <buffer> K :call <sid>scroll_preview(0)<CR>
nnoremap <silent> <buffer> <C-n> :call search('^  \X*\zs\x')<CR>
nnoremap <silent> <buffer> <C-p> :call search('^  \X*\zs\x', 'b')<CR>
nmap <silent> <buffer> <C-j> <C-n>o
nmap <silent> <buffer> <C-k> <C-p>o

" Vimwiki Settings
" github.com/mike325/.vim

if !has#plugin('vimwiki') || exists('g:config_vimwiki')
    finish
endif

let g:config_vimwiki = 1

function! VimwikiLinkHandler(link) abort
    " Use Vim to open external files with the 'vfile:' scheme.  E.g.:
    "   1) [[file:~/Code/PythonProject/abc123.py]]
    "   2) [[file:./|Wiki Home]]
    let l:link = a:link

    if l:link !~# '\v^(file|vnc):' && (os#name('windows') && l:link !~# '^explorer:')
        return 0
    endif

    if l:link =~# '^file:'
        let l:link = split(l:link, ':\ze[0-9]\+\(:[0-9\+\)\?')

        let l:line   = (len(l:link) > 1) ? l:link[1] : 0
        let l:column = (len(l:link) > 2) ? l:link[2] : 0

        let l:link_infos = vimwiki#base#resolve_link(l:link[0])

        if l:link_infos.filename ==# ''
            echomsg 'Vimwiki Error: Unable to resolve link!'
            return 0
        else
            execute 'edit ' . fnameescape(l:link_infos.filename) . ' | normal! ' . l:line . 'G' . l:column . '|'
            return 1
        endif
    elseif os#name('windows') && l:link =~# '^explorer:'
        let l:link = tr(split(l:link, ':')[1], '/', '\')
        silent! execute '!mkdir -Force ' . l:link
        silent! execute '!explorer.exe ' . l:link
        return 1
    elseif l:link =~# '^vnc:'
        let l:link = split(l:link, ':')[1]
        execute 'VNC ' . l:link
        return 1
    endif
    return 0
endfunction

let g:vimwiki_table_mappings = 0

let s:work_wiki = {
    \ 'path'     : vars#home() . '/vimwiki/',
    \ 'syntax'   : 'markdown',
    \ 'ext'      : '.md',
    \ 'auto_tags': 1,
    \ 'nested_syntaxes': {
    \       'ruby'  : 'ruby',
    \       'python': 'python',
    \       'c++'   : 'cpp',
    \       'sh'    : 'sh',
    \       'bash'  : 'sh' ,
    \       'racket': 'racket'
    \    },
    \ }

let s:personal_wiki = {
    \ 'path'     : '~/notes/',
    \ 'syntax'   : 'markdown',
    \ 'ext'      : '.md',
    \ 'auto_tags': 1,
    \ 'nested_syntaxes': {
    \       'ruby'  : 'ruby',
    \       'python': 'python',
    \       'c++'   : 'cpp',
    \       'sh'    : 'sh',
    \       'bash'  : 'sh' ,
    \       'racket': 'racket'
    \    },
    \ }
" let g:vimwiki_table_mappings = 0

if os#name('windows')
    let g:vimwiki_list = [ s:work_wiki, s:personal_wiki ]
else
    let g:vimwiki_list = [ s:personal_wiki, s:work_wiki ]
endif

let g:vimwiki_ext2syntax = {
    \   '.md': 'markdown',
    \   '.mkd': 'markdown',
    \   '.wiki': 'media'
    \ }

nmap gww <Plug>VimwikiIndex
nmap gwt <Plug>VimwikiTabIndex
nmap gwd <Plug>VimwikiDiaryIndex
nmap gwn <Plug>VimwikiMakeDiaryNote
nmap gwu <Plug>VimwikiUISelect

" nmap <Leader>dt <Plug>VimwikiTabMakeDiaryNote
" nmap <Leader>dy <Plug>VimwikiMakeYesterdayDiaryNote
" nmap <Leader>dm <Plug>VimwikiMakeTomorrowDiaryNote

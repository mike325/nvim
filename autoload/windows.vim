" Windows Setttings
" github.com/mike325/.vim

let g:sh_defaults = {
    \ 'shell':&shell,
    \ 'shellcmdflag':&shellcmdflag,
    \ 'shellquote':&shellquote,
    \ 'shellxquote':&shellxquote,
    \ 'shellpipe':&shellpipe,
    \ 'shellredir':&shellredir
    \}

function! windows#toggle_powershell() abort
    if &shell =~# 'powershell\(.exe\)\?'
        let s = g:sh_defaults

        let &shell        = s.shell
        let &shellquote   = s.shellquote
        let &shellpipe    = s.shellpipe
        let &shellredir   = s.shellredir
        let &shellcmdflag = s.shellcmdflag
        let &shellxquote  = s.shellxquote
    else
        set shell=powershell.exe
        set shellcmdflag=-NoLogo\ -NoProfile\ -ExecutionPolicy\ RemoteSigned\ -Command
        set shellxquote=
        let &shellquote = ''
        let &shellpipe  = has('nvim') ? '| Out-File -Encoding UTF8 %s' : '>'
        let &shellredir = '| Out-File -Encoding UTF8 %s'
    endif
    echomsg 'Current shell ' . &shell
endfunction

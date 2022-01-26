" filetypedetect Settings
" github.com/mike325/.vim

let g:load_custom_fts = 0

function! filetypedetect#detect() abort

    if g:load_custom_fts == 1
        return
    endif

    augroup filetypedetect
        autocmd BufNewFile,BufRead *.{conf,si,sle,in},.coveragerc,config.txt    setlocal filetype=dosini
        autocmd BufNewFile,BufRead *.log,*.rpt,*.rdl                            setlocal filetype=log
        autocmd BufNewFile,BufRead */etc/nginx/*,*.nginx,nginx.conf             setlocal filetype=nginx
        autocmd BufNewFile,BufRead *.pkg                                        setlocal filetype=conf
        autocmd BufNewFile,BufRead .pdbrc                                       setlocal filetype=python
        autocmd BufNewFile,BufRead *.bash{_*,rc,rc.*},.profile                  setlocal filetype=sh
        autocmd BufNewFile,BufRead tmux.conf                                    setlocal filetype=tmux
        autocmd BufNewFile,BufRead *.{toml,ini},.flake8,setup.cfg,.editorconfig setlocal filetype=toml
        autocmd BufNewFile,BufRead *.xmp                                        setlocal filetype=xml
        autocmd BufNewFile,BufRead www.overleaf.com_*.txt                       setlocal filetype=tex
        autocmd BufNewFile,BufRead github.com_*.txt                             setlocal filetype=markdown
        autocmd BufNewFile,BufRead godbolt.org_*.txt                            setlocal filetype=cpp
        autocmd BufNewFile,BufRead cppreference.com_*.txt                       setlocal filetype=cpp
        autocmd BufNewFile,BufRead *.cppreference.com_*.txt                     setlocal filetype=cpp
        " autocmd BufNewFile,BufRead *.txt if ( tools#checksize() == 1 ) |      setlocal filetype=log | endif
    augroup END

    let g:load_custom_fts = 1

endfunction

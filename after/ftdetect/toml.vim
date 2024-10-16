" toml Settings
" github.com/mike325/.vim

autocmd BufNewFile,BufRead *.{toml,ini},.flake8,flake8,setup.cfg setlocal filetype=toml

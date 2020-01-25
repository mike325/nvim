" Projections Setttings
" github.com/mike325/.vim

function! plugins#vim_projectionist#init(data) abort
    if !exists('g:plugs["vim-projectionist"]')
        return -1
    endif

    augroup CommonProjections
        autocmd!
        autocmd User ProjectionistDetect
                    \ call projectionist#append(getcwd(),
                    \ {
                    \   '.projections.json'             : {'type': 'Projections'},
                    \   '.gitignore'                    : {'type': 'Gitignore'},
                    \   '.git/hooks/*'                  : {'type': 'GitHooks'},
                    \   '.git/config'                   : {'type': 'Git'},
                    \   '.git/info/*'                   : {'type': 'Git'},
                    \   '.github/workflows/main.yml'    : {'type': 'Github'},
                    \   '.github/workflows/*.yml'       : {'type': 'Github'},
                    \   '.travis.yml'                   : {'type': 'Travis' },
                    \   '.ycm_extra_conf.py'            : {'type': 'ConfigYCM'},
                    \   '.project.vim'                  : {'type': 'Project'},
                    \   'clang-format'                  : {'type': 'ClangFormat'},
                    \   'README.md'                     : {'type': 'Readme'},
                    \   'LICENSE'                       : {'type': 'License'},
                    \ })

    augroup end

endfunction

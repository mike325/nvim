" Projections Setttings
" github.com/mike325/.vim

if !exists('g:plugs["vim-projectionist"]') || exists('g:config_projectionist')
    finish
endif

let g:config_projectionist = 1

augroup CommonProjections
    autocmd!
    autocmd User ProjectionistDetect
                \ call projectionist#append(getcwd(),
                \ {
                \   '.projections.json'          : {'type': 'Projections'},
                \   '.gitignore'                 : {'type': 'Gitignore'},
                \   '.git/hooks/*'               : {'type': 'GitHooks'},
                \   '.git/config'                : {'type': 'Git'},
                \   '.git/info/*'                : {'type': 'Git'},
                \   '.github/workflows/main.yml' : {'type': 'Github'},
                \   '.github/workflows/*.yml'    : {'type': 'Github'},
                \   '.travis.yml'                : {'type': 'Travis' },
                \   '.ycm_extra_conf.py'         : {'type': 'YCM'},
                \   '.project.vim'               : {'type': 'Project'},
                \   '.clang-format'              : {'type': 'Clang'},
                \   '.clang-*'                   : {'type': 'Clang'},
                \   'UltiSnips/*.snippets'       : {'type': 'UltiSnips'},
                \   'README.md'                  : {'type': 'Readme'},
                \   'LICENSE'                    : {'type': 'License'},
                \   'Makefile'                   : {'type': 'Makefile'},
                \   'CMakeLists.txt'             : {'type': 'CMakeLists'},
                \   'cmake/*.cmake'              : {'type': 'CMakeLists'},
                \ })
                " \   'test/*'                     : {'type': 'Test'},

augroup end

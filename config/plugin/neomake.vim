" ############################################################################
"
"                               Neomake settings
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

if !exists('g:plugs["neomake"]')
    finish
endif
"
" nnoremap <F6> :Neomake<CR>
" nnoremap <F7> :lopen<CR>
" nnoremap <F8> :lclose<CR>

" let g:neomake_message_sign = {
"     \   'text': '➤',
"     \   'texthl': 'NeomakeMessageSign',
"     \}
" let g:neomake_info_sign = {'text': 'ℹ', 'texthl': 'NeomakeInfoSign'}

if !empty($NO_COOL_FONTS)
    let g:neomake_warning_sign = {
        \ 'text': 'W',
        \ 'texthl': 'WarningMsg',
        \ }

    let g:neomake_error_sign = {
        \ 'text': 'E',
        \ 'texthl': 'ErrorMsg',
        \ }
endif

" Show location list and keep the cursor in the buffer
" let g:neomake_open_list = 2

" Don't show the location list, silently run Neomake
let g:neomake_open_list = 0

if executable("vint")
    let g:neomake_vim_enabled_makers = ['vint']

    " The configuration scrips use Neovim commands
    let g:neomake_vim_vint_maker = {
        \ 'args': [
        \   '--enable-neovim',
        \   '-e'
        \],}
endif

let g:neomake_python_enabled_makers = get(g:,'neomake_python_enabled_makers',[])

if executable("flake8")
    let g:neomake_python_enabled_makers += ['flake8']

    " E501 is line length of 80 characters
    let g:neomake_python_flake8_maker = {
        \   'args': [
        \       '--ignore=E501'
        \],}

endif

if executable("pep8")
    let g:neomake_python_enabled_makers += ['pep8']

    let g:neomake_python_pep8_maker = {
        \ 'args': [
        \   '--max-line-length=100',
        \   '--ignore=E501'
        \],}
endif

let b:outpath = "/tmp/neomake.out"
if has("win32") || has("win64")
    let b:outpath = "C:/Temp/neomake"
endif

let g:neomake_c_enabled_makers = get(g:,'neomake_c_enabled_makers',[])

if executable("gcc")
    let g:neomake_c_enabled_makers += ["gcc"]

    let g:neomake_c_gcc_maker = {
        \   'exe': 'gcc',
        \   'args': [
        \       '-Wall',
        \       '-Wextra',
        \       '-o', b:outpath,
        \],}

endif

if executable("clang")
    let g:neomake_c_enabled_makers += ["clang"]

    let g:neomake_c_clang_maker = {
        \   'exe': 'clang',
        \   'args': [
        \       '-Wall',
        \       '-Wextra',
        \       '-Weverything',
        \       '-Wno-missing-prototypes',
        \       '-o', b:outpath,
        \],}
endif

let g:neomake_cpp_enabled_makers = get(g:,'neomake_cpp_enabled_makers',[])

if executable("g++")
    let g:neomake_cpp_enabled_makers += ["gcc"]

    let g:neomake_cpp_gcc_maker = {
        \   'exe': 'g++',
        \   'args': [
        \      '-std=c++11',
        \      '-Wall',
        \      '-Wextra',
        \       '-o', b:outpath,
        \],}
endif

if executable("clang++")
    let g:neomake_cpp_enabled_makers += ["clang"]

    let g:neomake_cpp_clang_maker = {
        \   'exe': 'clang++',
        \   'args': [
        \      '-std=c++11',
        \      '-Wall',
        \      '-Wextra',
        \      '-Weverything',
        \      '-Wno-c++98-compat',
        \      '-Wno-missing-prototypes',
        \       '-o', b:outpath,
        \],}
endif

" TODO Config the proper makers for more languages
" JSON linter       : npm install -g jsonlint
" Typescript linter : npm install -g typescript
" SCSS linter       : gem install --user-install scss-lint
" Markdown linter   : gem install --user-install mdl
" Shell linter      : ( apt-get install / yaourt -S / dnf install ) shellcheck
" VimL linter       : pip install --user vim-vint
" Python linter     : pip install --user flake8 pep8
" C/C++ linter      : ( apt-get install / yaourt -S / dnf install ) clang gcc g++
" Go linter         : ( apt-get install / yaourt -S / dnf install ) golang

" Trigger neomake right after save a file or after 1s after leaving insert mode
" available options:
"       TextChanged
"       InsertLeave
"       BufWritePost
"       BufWinEnter
try
    call neomake#configure#automake({
        \ 'InsertLeave': {},
        \ 'BufWritePost': {'delay': 0},
        \ }, 1000)
catch E117
    echomsg "Please run :PlugInstall to get Neomake plugin"
endtry

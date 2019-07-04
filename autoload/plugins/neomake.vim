scriptencoding 'utf-8'
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

function! plugins#neomake#init(data) abort
    if !exists('g:plugs["neomake"]')
        return -1
    endif

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

    if executable('vint')
        let g:neomake_vim_enabled_makers = ['vint']

        " The configuration scrips use Neovim commands
        let g:neomake_vim_vint_maker = {
            \ 'errorformat': '%f:%l:%c: %trror: %m,%f:%l:%c: %tarning: %m,%f:%l:%c: %tote: %m',
            \ 'args': [
            \   '-f',
            \   '{file_path}:{line_number}:{column_number}: {severity}: {description} (see {reference})',
            \   '--enable-neovim',
            \],}
    endif

    let g:neomake_python_enabled_makers = get(g:,'neomake_python_enabled_makers',[])

    if executable('flake8')
        let g:neomake_python_enabled_makers += ['flake8']

        let s:config = os#name('windows') ? vars#home() . '/.flake8' : vars#home() . '/.config/flake8'

        if filereadable(s:config)
            let g:neomake_python_flake8_maker = {
                \ 'args': [
                \   '--max-line-length=120',
                \   '--builtins=xrange,reload,long,raw_input',
                \   '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203,E27'
                \],}
        else
            let g:neomake_python_flake8_maker = {
                \ 'args': [
                \   '--max-line-length=120',
                \   '--builtins=xrange,reload,long',
                \   '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203,E27'
                \],}
        endif

        unlet s:config

    elseif executable('pycodestyle')
        let g:neomake_python_enabled_makers += ['pycodestyle']

        let g:neomake_python_pycodestyle_maker = {
            \ 'args': [
            \   '--max-line-length=120',
            \   '--ignore=E121,E123,E126,E226,E24,E704,W503,W504,H233,E228,E701,E226,E251,E501,E221,E203,E27'
            \],}

    endif

    let g:neomake_c_enabled_makers = get(g:,'neomake_c_enabled_makers',[])

    if executable('gcc')
        let g:neomake_c_enabled_makers += ['gcc']

        let g:neomake_c_gcc_maker = {
            \   'exe': 'gcc',
            \   'args': [
            \       '-Wall',
            \       '-Wextra',
            \       '-o', os#tmp('neomake'),
            \],}

    endif

    if executable('clang')
        let g:neomake_c_enabled_makers += ['clang']

        let g:neomake_c_clang_maker = {
            \   'exe': 'clang',
            \   'args': [
            \       '-Wall',
            \       '-Wextra',
            \       '-Weverything',
            \       '-Wno-missing-prototypes',
            \       '-o', os#tmp('neomake'),
            \],}
    endif

    let g:neomake_cpp_enabled_makers = get(g:,'neomake_cpp_enabled_makers',[])

    if executable('g++')
        let g:neomake_cpp_enabled_makers += ['gcc']

        let g:neomake_cpp_gcc_maker = {
            \   'exe': 'g++',
            \   'args': [
            \      '-std=c++17',
            \      '-Wall',
            \      '-Wextra',
            \       '-o', os#tmp('neomake'),
            \],}
    endif

    if executable('clang++')
        let g:neomake_cpp_enabled_makers += ['clang']

        let g:neomake_cpp_clang_maker = {
            \   'exe': 'clang++',
            \   'args': [
            \      '-std=c++17',
            \      '-Wall',
            \      '-Wextra',
            \      '-Weverything',
            \      '-Wno-c++98-compat',
            \      '-Wno-missing-prototypes',
            \       '-o', os#tmp('neomake'),
            \],}
    endif

    if executable('shellcheck')
        let g:neomake_sh_enabled_makers = get(g:,'neomake_sh_enabled_makers',[])

        let g:neomake_sh_enabled_makers += ['shellcheck']

        let g:neomake_sh_shellcheck_maker = {
            \   'exe': 'shellcheck',
            \   'errorformat':'%f:%l:%c: %trror: %m [SC%n],%f:%l:%c: %tarning: %m [SC%n],%f:%l:%c: %tote: %m [SC%n]',
            \   'args': [
            \      '-f', 'gcc',
            \      '-e', '1117',
            \      '-x',
            \      '-a',
            \],}
    endif

    if has('nvim-0.3.2')
        let g:neomake_virtualtext_current_error = 1
        let g:neomake_virtualtext_prefix = empty($NO_COOL_FONTS) ? '➤ ' :  '❯ '
    endif

    try
        " Trigger neomake right after save a file or after 1s after leaving insert mode
        " available options:
        "       TextChanged
        "       InsertLeave
        "       BufWritePost
        "       BufWinEnter
        call neomake#configure#automake({
            \ 'InsertLeave': {},
            \ 'BufWritePost': {'delay': 0},
            \ }, 1000)

    catch E117
    endtry
endfunction

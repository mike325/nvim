scriptencoding "utf-8"

" ############################################################################
"
"                                YCM settings
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

function! plugins#youcompleteme#OnDeleteChar() abort
    if pumvisible()
        return "\<C-y>"
    endif
    return ''
endfunction

function! plugins#youcompleteme#FixYCMBs() abort
    imap <BS> <C-R>=plugins#youcompleteme#OnDeleteChar()<CR><Plug>delimitMateBS
    imap <C-h> <C-R>=plugins#youcompleteme#OnDeleteChar()<CR><Plug>delimitMateBS
endfunction


function! plugins#youcompleteme#install(info) abort
    if a:info.status ==# 'installed' || a:info.force
        " !./install.py --all

        " Since YCM download libclang there's no need to have clang install
        " FIX: ArchLinux users should run this first
        "  # sudo ln -s /lib64/libtinfo.so.6 /lib64/libtinfo.so.5
        "       or use --system-clang
        " https://github.com/Valloric/YouCompleteMe/issues/778#issuecomment-211452969
        let l:cmd = (exists('g:python3_host_prog')) ? [g:python3_host_prog] : [g:python_host_prog]

        let l:cmd += ['./install.py']

        "  Both libclang and clangd are downloaded from the upstream, so they can always be install
        let l:cmd += ['--clang-completer']
        let l:cmd += ['--clangd-completer']

        if executable('go') && (!empty($GOROOT))
            let l:cmd += ['--go-completer']
        endif

        if executable('mono') && ( (os#name('windows') && executable('msbuild')) || ( !os#name('windows') && executable('xbuild') ) )
            let l:cmd += ['--cs-completer']
        endif

        if executable('racer') && executable('cargo')
            let l:cmd += ['--rust-completer']
        endif

        if executable('npm') && executable('node')
            let l:cmd += ['--ts-completer']
        endif

        if !os#name('windows') && executable('java')
            " JDK8 must be installed
            let l:java = system('java -version')
            if l:java =~# '^java.*"1\.8.*"'
                let l:cmd += ['--java-completer']
            endif
        endif

        echomsg 'CMD: ' . join(l:cmd, ' ')
        execute ' !' join(l:cmd, ' ')

        " if os#name('windows')
        "     execute '!' . l:python . ' ./install.py ' . l:cmd
        " elseif executable('python3')
        "     " Force python3
        "     execute '!' . l:python . ' ./install.py ' . l:cmd
        " else
        "     execute '!./install.py ' . l:cmd
        " endif
    endif
endfunction

function! plugins#youcompleteme#init(data) abort
    if !exists('g:plugs["YouCompleteMe"]')
        return -1
    endif

    let g:ycm_min_num_of_chars_for_completion           = 2
    let g:ycm_auto_trigger                              = 1
    let g:ycm_complete_in_comments                      = 1
    let g:ycm_seed_identifiers_with_syntax              = 1
    let g:ycm_add_preview_to_completeopt                = 1
    let g:ycm_autoclose_preview_window_after_completion = 1
    let g:ycm_autoclose_preview_window_after_insertion  = 1
    let g:ycm_key_detailed_diagnostics                  = '<leader>D'

    let g:ycm_key_list_select_completion   = ['<C-n>', '<Down>']
    let g:ycm_key_list_previous_completion = ['<C-p>', '<Up>']
    " let g:ycm_key_list_stop_completion     = ['<C-y>', '<CR>']

    if !empty($NO_COOL_FONTS)
        let g:ycm_error_symbol   = 'E'
        let g:ycm_warning_symbol = 'W'
    else
        let g:ycm_error_symbol   = '✖'
        let g:ycm_warning_symbol = '⚠'
    endif

    let g:ycm_extra_conf_globlist   = ['~/.vim/*', '~/.config/nvim/*', '~/AppData/nvim/*']

    let g:ycm_python_interpreter_path = exists('g:python3_host_prog') ?  g:python3_host_prog : g:python_host_prog
    let g:ycm_python_interpreter_path = exepath(g:ycm_python_interpreter_path)

    let g:ycm_language_server = []
    if tools#CheckLanguageServer('bash')
        let g:ycm_language_server += [
            \ {
            \     'name': 'bash',
            \     'cmdline': ['bash-language-server', 'start'],
            \     'filetypes': ['bash', 'sh']
            \ }]
    endif

    let g:ycm_extra_conf_vim_data = [
                \  'g:ycm_python_interpreter_path',
                \]

    " Set fallback ycm config file
    if filereadable(fnameescape(vars#basedir() . '/host/ycm_extra_conf.py'))
        let g:ycm_global_ycm_extra_conf = fnameescape(vars#basedir().'/host/ycm_extra_conf.py')
    elseif filereadable(fnameescape(vars#basedir() . '/ycm_extra_conf.py'))
        let g:ycm_global_ycm_extra_conf = fnameescape(vars#basedir() . '/ycm_extra_conf.py')
    endif

    " let g:ycm_clangd_binary_path = ''
    let g:ycm_use_clangd = 'Auto' " Clangd will be use if it's in third_party folder
    let g:ycm_clangd_args = ['-index']
    " let g:ycm_clangd_uses_ycmd_caching = 1

    if executable('ctags')
        let g:ycm_collect_identifiers_from_tags_files = 1
    endif

    " In case there are other completion plugins
    let g:ycm_filetype_specific_completion_to_disable = {}

    " Don't ask fro confirmation
    let g:ycm_confirm_extra_conf = 0

    " Get Language syntax identifiers
    let g:ycm_seed_identifiers_with_syntax = 1

    " In case there are other completion plugins
    let g:ycm_filetype_blacklist = {
            \ 'log' : 1,
            \ 'tagbar' : 1,
            \ 'qf' : 1,
            \ 'unite' : 1,
            \ 'pandoc' : 1,
            \ 'infolog' : 1,
            \ 'objc' : 1,
            \ 'mail' : 1,
            \ 'man' : 1,
            \ 'netrw': 1,
            \ 'denite': 1
    \}

    if !exists('g:ycm_semantic_triggers')
        let g:ycm_semantic_triggers = {}
    endif

    if exists('g:plugs["vimtex"]') && exists('g:vimtex#re#youcompleteme')
        let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme
    endif

    " let g:ycm_server_log_level      = 'debug'
    " let g:ycm_server_use_vim_stdout = 1

    let g:ycm_cache_omnifunc = 1

    let g:ycm_use_ultisnips_completer = exists('g:plugs["ultisnips"]') ? 1 : 0

    function! s:SplitYCM(split_type, ycm_cmd) abort
        execute a:split_type
        execute a:ycm_cmd
    endfunction

    augroup YCMGoTo
        autocmd!
        autocmd FileType c,cpp                                          nnoremap <buffer> <leader>i :YcmCompleter GoToInclude<CR>
        autocmd FileType c,cpp,cs                                       command! -buffer FixIt :YcmCompleter FixIt

        autocmd FileType c,cpp,objc,objcpp,cuda                         command! -buffer Include :YcmCompleter GoToInclude
        autocmd FileType c,cpp,objc,objcpp,cuda                         command! -buffer Parent :YcmCompleter GetParent
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,cuda       command! -buffer Declaration :YcmCompleter GoToDeclaration
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer Definition :YcmCompleter GoToDefinition
        autocmd FileType javascript,python,typescript                   command! -buffer References :YcmCompleter GoToReferences
        autocmd FileType cs                                             command! -buffer Implementation :YcmCompleter GoToImplementationElseDeclaration

        autocmd FileType python,c,cpp,objc,objcpp,javascript            command! -buffer Type :YcmCompleter GetType

        autocmd FileType c,cpp,objc,objcpp,cuda                         command! -buffer IncludeVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToInclude")
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,cuda       command! -buffer DeclarationVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToDeclaration")
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer DefinitionVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToDefinition")
        autocmd FileType javascript,python,typescript                   command! -buffer ReferencesVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToReferences")
        autocmd FileType cs                                             command! -buffer ImplementationVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToImplementationElseDeclaration")

        autocmd FileType c,cpp,objc,objcpp                              command! -buffer IncludeSplit :call s:SplitYCM("split", "YcmCompleter GoToInclude")
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust            command! -buffer DeclarationSplit :call s:SplitYCM("split", "YcmCompleter GoToDeclaration")
        autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer DefinitionSplit :call s:SplitYCM("split", "YcmCompleter GoToDefinition")
        autocmd FileType javascript,python,typescript                   command! -buffer ReferencesSplit :call s:SplitYCM("split", "YcmCompleter GoToReferences")
        autocmd FileType cs                                             command! -buffer ImplementationSplit :call s:SplitYCM("split", "YcmCompleter GoToImplementationElseDeclaration")
    augroup end

    if exists('g:plugs["YouCompleteMe"]') && exists('g:plugs["delimitMate"]')
        " Hack around
        " https://github.com/Valloric/YouCompleteMe/issues/2696
        if has( 'vim_starting' )
            augroup BsHack
                autocmd!
                autocmd VimEnter * call plugins#youcompleteme#FixYCMBs()
            augroup END
        else
            call plugins#youcompleteme#FixYCMBs()
        endif
    endif

    try
        call host#ycm#config()
    catch E117
    endtry

endfunction

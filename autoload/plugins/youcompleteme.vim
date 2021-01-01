scriptencoding 'utf-8'
" YCM settings
" github.com/mike325/.vim

if !has#plugin('YouCompleteMe') || exists('g:config_ycm')
    finish
endif

let g:config_ycm = 1

function! plugins#youcompleteme#OnDeleteChar() abort
    if pumvisible()
        return "\<C-y>"
    endif
    return ''
endfunction

function! plugins#youcompleteme#FixYCMBs() abort
    imap <silent><BS> <C-R>=plugins#youcompleteme#OnDeleteChar()<CR><Plug>delimitMateBS
    imap <silent><C-h> <C-R>=plugins#youcompleteme#OnDeleteChar()<CR><Plug>delimitMateBS
endfunction

let g:ycm_languages = []

function! plugins#youcompleteme#install(info) abort
    if a:info.status ==# 'installed' || a:info.force
        " !./install.py --all

        " Since YCM download libclang there's no need to have clang install
        " FIX: ArchLinux users should run this first
        "  # sudo ln -s /lib64/libtinfo.so.6 /lib64/libtinfo.so.5
        "       or use --system-clang
        " https://github.com/Valloric/YouCompleteMe/issues/778#issuecomment-211452969
        let l:cmd = []
        if exists('g:python3_host_prog') && has#python('3', '5', '1')
            let l:cmd += [g:python3_host_prog]
        else
            let l:cmd += [g:python_host_prog]
        endif

        let l:cmd += ['./install.py']

        " if !executable('ccls')
            "  Both libclang and clangd are downloaded from the upstream, so they can always be install
            let l:cmd += ['--clang-completer']
            let l:cmd += ['--clangd-completer']
        " endif

        if executable('go') && !empty($GOROOT)
            let l:cmd += ['--go-completer']
        endif

        if executable('mono') && ( (os#name('windows') && executable('msbuild')) || ( !os#name('windows') && executable('xbuild') ) )
            let l:cmd += ['--cs-completer']
        endif

        if executable('cargo')
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

        if os#name('windows') && executable('msbuild')
            let l:msbuild = split(systemlist('msbuild /version')[-1], '\.')[0]
            let l:cmd += ['--msvc', l:msbuild]
        endif

        if os#name('windows')
            silent! py3 ycm_state.OnVimLeave()
        endif

        echomsg 'CMD: ' . join(l:cmd, ' ')
        execute ' !' join(l:cmd, ' ')

        " silent! YcmRestartServer

    endif
endfunction

let g:ycm_min_num_of_chars_for_completion           = 2
let g:ycm_auto_trigger                              = 1
let g:ycm_complete_in_comments                      = 1
let g:ycm_seed_identifiers_with_syntax              = 1
let g:ycm_add_preview_to_completeopt                = 0
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

let g:ycm_language_server = get(g:, 'ycm_language_server', [])

let g:ycm_languages = []

let g:ycm_languages += ['c', 'cpp', 'objc', 'objcpp', 'python']

if executable('go') && !empty($GOROOT)
    let g:ycm_languages += ['go']
endif

if executable('mono') && ( (os#name('windows') && executable('msbuild')) || ( !os#name('windows') && executable('xbuild') ) )
    let g:ycm_languages += ['cs']
endif

if executable('racer') && executable('cargo')
    let g:ycm_languages += ['rust']
endif

if executable('npm') && executable('node')
    let g:ycm_languages += ['javascript']
endif

if !os#name('windows') && executable('java')
    let g:ycm_languages += ['java']
endif


if tools#CheckLanguageServer('tex')
    let s:ft = ['tex', 'bib']
    let g:ycm_language_server += [{
        \     'name': 'tex',
        \     'cmdline': tools#getLanguageServer('tex'),
        \     'filetypes': s:ft,
        \ }]
    let g:ycm_languages += s:ft
endif

if tools#CheckLanguageServer('sh')
    let s:ft = ['bash', 'sh']
    let g:ycm_language_server += [{
        \     'name': 'sh',
        \     'cmdline': tools#getLanguageServer('sh'),
        \     'filetypes': s:ft
        \ }]
    let g:ycm_languages += s:ft
endif

if tools#CheckLanguageServer('vim')
    let s:ft = ['vim']
    let g:ycm_language_server += [{
        \     'name': 'vim',
        \     'cmdline': tools#getLanguageServer('vim'),
        \     'filetypes': s:ft
        \ }]
    let g:ycm_languages += s:ft
endif

if tools#CheckLanguageServer('dockerfile')
    let s:ft = ['dockerfile', 'Dockerfile']
    let g:ycm_language_server += [{
        \     'name': 'docker',
        \     'cmdline': tools#getLanguageServer('dockerfile'),
        \     'filetypes': s:ft
        \ }]
    let g:ycm_languages += s:ft
endif

" if executable('ccls')
"     let g:ycm_language_server += [{
"         \   'name': 'ccls',
"         \   'cmdline': tools#getLanguageServer('c'),
"         \   'filetypes': [ 'c', 'cpp', 'cuda', 'objc', 'objcpp'  ],
"         \   'project_root_files': [ '.ccls-root', 'compile_commands.json', 'compile_flags.txt', '.git']
"         \ }]
" endif

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
let g:ycm_use_clangd = 1
let g:ycm_clangd_args = [
    \   '--index',
    \   '--background-index',
    \   '--suggest-missing-includes',
    \   '--clang-tidy',
    \   '--header-insertion=iwyu',
    \   '--function-arg-placeholders',
    \   '--log=verbose',
    \]

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
        \ 'denite': 1,
        \ 'GV': 1,
        \ 'git': 1,
\}

if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
endif

" let g:ycm_server_log_level      = 'debug'
" let g:ycm_server_use_vim_stdout = 1

" let g:ycm_cache_omnifunc = 1

let g:ycm_use_ultisnips_completer = has#plugin('ultisnips')

function! s:SplitYCM(split_type, ycm_cmd) abort
    execute a:split_type
    execute a:ycm_cmd
endfunction

if has#plugin('vimtex')
    let g:ycm_semantic_triggers.tex = g:vimtex#re#youcompleteme
endif

augroup YCMMappings
    autocmd!
augroup end

execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> <c-]> :YcmCompleter GoToDefinition<CR>'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> gd    :YcmCompleter GoToDeclaration<CR>'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> gD    :YcmCompleter GoToImplementation<CR>'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> gr    :YcmCompleter GoToReferences<CR>'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> gI    :YcmCompleter GoToInclude<CR>'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' nnoremap <buffer> <silent> K     :YcmCompleter GetDoc<CR>'
                                                                    ,
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer FixIt YcmCompleter FixIt'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Include YcmCompleter GoToInclude'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Parent YcmCompleter GoToParent'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Declaration YcmCompleter GoToDeclaration'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Definition YcmCompleter GoToDefinition'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer References YcmCompleter GoToReferences'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Doc YcmCompleter GetDoc'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Hover YcmCompleter GetDoc'
execute 'autocmd YCMMappings FileType ' . join(g:ycm_languages, ',') . ' command! -buffer Type YcmCompleter GetType'

if has#plugin('YouCompleteMe') && has#plugin('delimitMate')
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

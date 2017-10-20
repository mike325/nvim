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

if !exists('g:plugs["YouCompleteMe"]')
    finish
endif

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

" let g:ycm_extra_conf_globlist   = ['~/.vim/*']
" if exists('g:plugs["vim-fugitive"]')
"     let g:ycm_global_ycm_extra_conf =  fugitive#extract_git_dir(expand('%:p')) . "/ycm_extra_conf.py"
"     if g:ycm_global_ycm_extra_conf ==# ''
"         let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
"     endif
if filereadable(fnameescape(getcwd() . "/.git/ycm_extra_conf.py"))
    let g:ycm_global_ycm_extra_conf = fnameescape(getcwd() . "/.git/ycm_extra_conf.py")
elseif filereadable(fnameescape(g:base_path . "ycm_extra_conf.py"))
    let g:ycm_global_ycm_extra_conf = fnameescape(g:base_path . "ycm_extra_conf.py")
endif

if executable("ctags")
    let g:ycm_collect_identifiers_from_tags_files = 1
endif

" In case there are other completion plugins
let g:ycm_filetype_specific_completion_to_disable = {}

" In case there are other completion plugins
let g:ycm_filetype_blacklist    = {
        \ 'log' : 1,
        \ 'tagbar' : 1,
        \ 'qf' : 1,
        \ 'notes' : 1,
        \ 'markdown' : 1,
        \ 'md' : 1,
        \ 'unite' : 1,
        \ 'text' : 1,
        \ 'vimwiki' : 1,
        \ 'pandoc' : 1,
        \ 'infolog' : 1,
        \ 'objc' : 1,
        \ 'mail' : 1
\}

function! s:SplitYCM(split_type, ycm_cmd)
    execute a:split_type
    execute a:ycm_cmd
endfunction

augroup YCMGoTo
    autocmd!
    autocmd FileType c,cpp                                          nnoremap <buffer> <leader>i :YcmCompleter GoToInclude<CR>
    autocmd FileType c,cpp,cs                                       command! -buffer FixIt :YcmCompleter FixIt

    autocmd FileType c,cpp,objc,objcpp                              command! -buffer Include :YcmCompleter GoToInclude
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust            command! -buffer Declaration :YcmCompleter GoToDeclaration
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer Definition :YcmCompleter GoToDefinition
    autocmd FileType javascript,python,typescript                   command! -buffer References :YcmCompleter GoToReferences
    autocmd FileType cs                                             command! -buffer Implementation :YcmCompleter GoToImplementationElseDeclaration

    autocmd FileType c,cpp,objc,objcpp,javascript                   command! -buffer Type :YcmCompleter GetType

    autocmd FileType c,cpp,objc,objcpp                              command! -buffer IncludeVSplit        :call s:SplitYCM("vsplit", "YcmCompleter GoToInclude")
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust            command! -buffer DeclarationVSplit    :call s:SplitYCM("vsplit", "YcmCompleter GoToDeclaration")
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer DefinitionVSplit     :call s:SplitYCM("vsplit", "YcmCompleter GoToDefinition")
    autocmd FileType javascript,python,typescript                   command! -buffer ReferencesVSplit     :call s:SplitYCM("vsplit", "YcmCompleter GoToReferences")
    autocmd FileType cs                                             command! -buffer ImplementationVSplit :call s:SplitYCM("vsplit", "YcmCompleter GoToImplementationElseDeclaration")

    autocmd FileType c,cpp,objc,objcpp                              command! -buffer IncludeSplit        :call s:SplitYCM("split", "YcmCompleter GoToInclude")
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust            command! -buffer DeclarationSplit    :call s:SplitYCM("split", "YcmCompleter GoToDeclaration")
    autocmd FileType c,cpp,python,go,cs,objc,objcpp,rust,javascript command! -buffer DefinitionSplit     :call s:SplitYCM("split", "YcmCompleter GoToDefinition")
    autocmd FileType javascript,python,typescript                   command! -buffer ReferencesSplit     :call s:SplitYCM("split", "YcmCompleter GoToReferences")
    autocmd FileType cs                                             command! -buffer ImplementationSplit :call s:SplitYCM("split", "YcmCompleter GoToImplementationElseDeclaration")
augroup end

" nnoremap <leader>F :YcmCompleter FixIt<CR>
" nnoremap <leader>gr :YcmCompleter GoToReferences<CR>
" nnoremap <leader>gg :YcmCompleter GoTo<CR>
" nnoremap <leader>gp :YcmCompleter GetParent<CR>
" nnoremap <leader>gi :YcmCompleter GoToInclude<CR>
" nnoremap <leader>gt :YcmCompleter GetType<CR>

" nnoremap <F5> :YcmForceCompileAndDiagnostics<CR>


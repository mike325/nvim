" HEADER {{{
"
"                            Autocmds settings
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
" }}} END HEADER

" We just want to source this file once and if we have autocmd available
if !has("autocmd") || ( exists("g:autocmds_loaded") && g:autocmds_loaded )
    finish
endif

let g:autocmds_loaded = 1

" TODO make a function to save the state of the toggles
augroup Numbers
    autocmd!
    autocmd FileType help setlocal relativenumber number
    autocmd WinEnter *    setlocal relativenumber number
    autocmd WinLeave *    setlocal norelativenumber number
    autocmd InsertLeave * setlocal relativenumber number
    autocmd InsertEnter * setlocal norelativenumber number
augroup end

if has("nvim")
    " Set modifiable to use easymotions
    " autocmd TermOpen * setlocal modifiable

    " I like to see the numbers in the terminal
    augroup TerminalAutocmds
        autocmd!
        autocmd TermOpen * setlocal relativenumber number
    augroup end
endif

" Auto resize all windows
augroup AutoResize
    autocmd!
    autocmd VimResized * wincmd =
augroup end

" TODO: check this in the future
" augroup autoSaveAndRead
"     autocmd!
"     autocmd TextChanged,InsertLeave,FocusLost * silent! wall
"     autocmd CursorHold * silent! checktime
" augroup end

" Set small sidescroll in log plaintext files
augroup SideScroll
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter *.log,*.txt setlocal sidescroll=1
augroup end

" TODO To be improve
function! RemoveTrailingWhitespaces()
    " Sometimes we don't want to remove spaces
    let l:buftypes = 'nofile\|help\|quickfix\|terminal'
    let l:filetypes = 'bin\|hex\|log'

    if &buftype =~? l:buftypes || &filetype ==? l:filetypes || &filetype ==? ''
        return
    endif

    "Save last cursor position
    let savepos = getpos('.')
    silent! exec '%s/\s\+$//e'
    call setpos('.', savepos)
endfunction

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd FileType * autocmd BufWritePre <buffer> call RemoveTrailingWhitespaces()
augroup end

" Specially helpful for html and xml
augroup MatchChars
    autocmd!
    autocmd FileType xml,html,vim autocmd BufReadPre <buffer> setlocal matchpairs+=<:>
augroup end

augroup localCR
    autocmd!
    autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
    autocmd BufReadPost quickfix nnoremap <silent> <buffer> q :q!<CR>
    autocmd FileType help        nnoremap <silent> <buffer> q :q!<CR>
    autocmd CmdwinEnter *        nnoremap <CR> <CR>
augroup end

augroup FileTypeDetect
    autocmd!
    autocmd BufRead,BufNewFile gitconfig          setlocal filetype=gitconfig
    autocmd BufRead,BufNewFile *.bash*            setlocal filetype=sh
    autocmd BufRead,BufNewFile *.in,*.si,*.sle    setlocal filetype=conf
    autocmd BufNewFile,BufReadPre /*/nginx/*.conf setlocal filetype=nginx
augroup end

" *currently no all functions work
augroup omnifuncs
    autocmd!
    autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
    autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
    autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
    autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
    autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
    autocmd FileType go            setlocal omnifunc=go#complete#Complete
    autocmd FileType cs            setlocal omnifunc=OmniSharp#Complete
    autocmd FileType php           setlocal omnifunc=phpcomplete#CompletePHP
    autocmd FileType java          setlocal omnifunc=javacomplete#Complete

    autocmd BufNewFile,BufRead,BufEnter *.cpp,*.hpp setlocal omnifunc=omni#cpp#complete#Main
    autocmd BufNewFile,BufRead,BufEnter *.c,*.h     setlocal omnifunc=ccomplete#Complete
augroup end

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType help                     setlocal nospell
    autocmd FileType gitcommit                setlocal spell complete+=kspell
    autocmd FileType markdown                 setlocal spell complete+=kspell
    autocmd FileType tex                      setlocal spell complete+=kspell
    autocmd FileType plaintex                 setlocal spell complete+=kspell
    autocmd FileType text                     setlocal spell complete+=kspell
    autocmd BufNewFile,BufRead,BufEnter *.org setlocal spell complete+=kspell
augroup end
" }}} EndSpell

" Skeletons {{{
" TODO: Improve personalization of the templates

function! CMainOrFunc()

    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    if b:extension =~# "^cpp$"
        if b:file_name =~# "^main$"
            exec '0r '.fnameescape(g:parent_dir.'skeletons/main.cpp')
        else
            exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.cpp')
        endif
    else
        if b:file_name =~# "^main$"
            exec '0r '.fnameescape(g:parent_dir.'skeletons/main.c')
        else
            exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.c')
        endif
    endif

endfunction

function! CHeader()

    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    let b:upper_name = toupper(b:file_name)

    if b:extension =~# "^hpp$"
        exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.hpp')
        exec '%s/NAME_HPP/'.b:upper_name.'_HPP/g'
    else
        exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.h')
        exec '%s/NAME_H/'.b:upper_name.'_H/g'
    endif

endfunction

function! JavaClass()
    let b:file_name = expand('%:t:r')
    let b:extension = expand('%:e')

    exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.java')
    exec '%s/NAME/'.b:file_name.'/e'
endfunction

augroup Skeletons
    autocmd!
    autocmd BufNewFile *.css  silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.css')
    autocmd BufNewFile *.html silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.html')
    autocmd BufNewFile *.md   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.md')
    autocmd BufNewFile *.js   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.js')
    autocmd BufNewFile *.xml  silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.xml')
    autocmd BufNewFile *.py   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.py')
    autocmd BufNewFile *.go   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.go')
    autocmd BufNewFile *.cs   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.cs')
    autocmd BufNewFile *.php  silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.php')
    autocmd BufNewFile *.sh   silent! exec '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.sh')
    autocmd BufNewFile *.java silent! call JavaClass()
    autocmd BufNewFile *.cpp  silent! call CMainOrFunc()
    autocmd BufNewFile *.hpp  silent! call CHeader()
    autocmd BufNewFile *.c    silent! call CMainOrFunc()
    autocmd BufNewFile *.h    silent! call CHeader()
augroup end

" }}} EndSkeletons

scriptencoding "uft-8"
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
if !has('autocmd') || ( exists('g:autocmds_loaded') && g:autocmds_loaded )
    finish
endif

let g:autocmds_loaded = 1

" Allow to use Vim as Pager
augroup Modifiable
    autocmd!
    autocmd BufReadPre * if &modifiable == 1 | setlocal fileencoding=utf-8 | endif
augroup end

if has('nvim') || v:version > 702
    " TODO make a function to save the state of the toggles
    augroup Numbers
        autocmd!
        autocmd WinEnter    *    setlocal relativenumber number
        autocmd WinLeave    *    setlocal norelativenumber number
        autocmd InsertLeave *    setlocal relativenumber number
        autocmd InsertEnter *    setlocal norelativenumber number
    augroup end
endif

" We don't need Vim's temp files here
augroup DisableTemps
    autocmd!
    autocmd BufNewFile,BufReadPre,BufEnter /tmp/* setlocal noswapfile nobackup noundofile
augroup end


if has('nvim')
    " Set modifiable to use easymotions
    " autocmd TermOpen * setlocal modifiable

    " I like to see the numbers in the terminal
    augroup TerminalAutocmds
        autocmd!
        autocmd TermOpen * setlocal relativenumber number nocursorline
        autocmd TermOpen * setlocal noswapfile nobackup noundofile
    augroup end
endif

" Auto resize all windows
augroup AutoResize
    autocmd!
    autocmd VimResized * wincmd =
augroup end

" TODO: check this in the future
" augroup AutoSaveAndRead
"     autocmd!
"     autocmd TextChanged,InsertLeave,FocusLost * silent! wall
"     autocmd CursorHold * silent! checktime
" augroup end

augroup LastEditPosition
    autocmd!
    autocmd BufReadPost *
                \   if line("'\"") > 1 && line("'\"") <= line("$") && &ft != "gitcommit" |
                \       exe "normal! g'\""                                               |
                \   endif
augroup end

" TODO To be improve

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
    autocmd BufWritePre                 * call autocmd#CleanFile()
augroup end

" Specially helpful for html and xml
augroup MatchChars
    autocmd!
    autocmd FileType xml,html autocmd BufReadPre <buffer> setlocal matchpairs+=<:>
augroup end

augroup QuickQuit
    autocmd!
    autocmd BufEnter,BufReadPost __LanguageClient__ nnoremap <silent> <buffer> q :q!<CR>
    if has('nvim')
        autocmd TermOpen    *        nnoremap <silent> <buffer> q :q!<CR>
    endif
augroup end

augroup LocalCR
    autocmd!
    autocmd CmdwinEnter * nnoremap <CR> <CR>
augroup end

augroup FileTypeDetect
    autocmd!
    autocmd BufRead,BufNewFile    *.bash*         setlocal filetype=sh
    autocmd BufNewFile,BufReadPre /*/nginx/*.conf setlocal filetype=nginx
augroup end

" if exists("g:minimal")
"     " *currently no all functions work
"     augroup omnifuncs
"         autocmd!
"         autocmd FileType css           setlocal omnifunc=csscomplete#CompleteCSS
"         autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
"         autocmd FileType javascript    setlocal omnifunc=javascriptcomplete#CompleteJS
"         autocmd FileType xml           setlocal omnifunc=xmlcomplete#CompleteTags
"         autocmd FileType python        setlocal omnifunc=pythoncomplete#Complete
"         autocmd FileType go            setlocal omnifunc=go#complete#Complete
"         autocmd FileType cs            setlocal omnifunc=OmniSharp#Complete
"         autocmd FileType php           setlocal omnifunc=phpcomplete#CompletePHP
"         autocmd FileType java          setlocal omnifunc=javacomplete#Complete
"         autocmd FileType cpp           setlocal omnifunc=ccomplete#Complete
"         autocmd FileType c             setlocal omnifunc=ccomplete#Complete
"     augroup end
" endif

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType                    tex      setlocal spell complete+=k,kspell " Add spell completion
    autocmd BufNewFile,BufRead,BufEnter *.org    setlocal spell complete+=k,kspell " Add spell completion
augroup end
" }}} EndSpell

" Skeletons {{{
" TODO: Improve personalization of the templates
" TODO: Create custom cmd

augroup Skeletons
    autocmd!
    autocmd BufNewFile .projections.json silent! call autocmd#FileName('projections.json')
    autocmd BufNewFile *.css             silent! call autocmd#FileName()
    autocmd BufNewFile *.html            silent! call autocmd#FileName()
    autocmd BufNewFile *.md              silent! call autocmd#FileName()
    autocmd BufNewFile *.js              silent! call autocmd#FileName()
    autocmd BufNewFile *.xml             silent! call autocmd#FileName()
    autocmd BufNewFile *.py              silent! call autocmd#FileName()
    autocmd BufNewFile *.cs              silent! call autocmd#FileName()
    autocmd BufNewFile *.php             silent! call autocmd#FileName()
    autocmd BufNewFile *.sh              silent! call autocmd#FileName()
    autocmd BufNewFile *.java            silent! call autocmd#FileName()
    autocmd BufNewFile *.vim             silent! call autocmd#FileName()
    autocmd BufNewFile *.go              silent! call autocmd#FileName()
    autocmd BufNewFile *.cpp             silent! call autocmd#FileName()
    autocmd BufNewFile *.c               silent! call autocmd#FileName()
    autocmd BufNewFile *.hpp             silent! call autocmd#FileName()
    autocmd BufNewFile *.h               silent! call autocmd#FileName()
augroup end

" }}} EndSkeletons

" TODO: Add support for git worktrees

augroup ProjectConfig
    autocmd!
    if has('nvim-0.2')
        autocmd DirChanged * call autocmd#SetProjectConfigs()
    endif
    autocmd VimEnter,SessionLoadPost * call autocmd#SetProjectConfigs()
    autocmd VimEnter * call tools#abolish('en')
augroup end

augroup LaTex
    autocmd!
    autocmd FileType tex let b:vimtex_main = 'main.tex'
augroup end

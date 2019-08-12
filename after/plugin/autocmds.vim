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

" We don't need Vim's temp files here
augroup DisableTemps
    autocmd!
    autocmd BufNewFile,BufReadPre,BufEnter /tmp/* setlocal noswapfile nobackup noundofile
augroup end

if has('nvim') || v:version > 702
    " TODO make a function to save the state of the toggles
    augroup Numbers
        autocmd!
        autocmd WinEnter    * setlocal relativenumber number
        autocmd WinLeave    * setlocal norelativenumber number
        autocmd InsertLeave * setlocal relativenumber number
        autocmd InsertEnter * setlocal norelativenumber number
    augroup end

endif

if has('nvim') || has('terminal')
    " Set modifiable to use easymotions
    " autocmd TermOpen * setlocal modifiable

    " I like to see the numbers in the terminal
    augroup TerminalAutocmds
        autocmd!
        if has('nvim')
            autocmd TermOpen *      setlocal relativenumber number nocursorline
            autocmd TermOpen *      setlocal noswapfile nobackup noundofile
        elseif has('terminal')
            autocmd TerminalOpen *  setlocal relativenumber number nocursorline
            autocmd TerminalOpen *  setlocal noswapfile nobackup noundofile
        endif
    augroup end
endif

" Auto resize all windows
augroup AutoResize
    autocmd!
    autocmd VimResized * wincmd =
augroup end

augroup LastEditPosition
    autocmd!
    autocmd BufReadPost *
                \   if line("'\"") > 1 && line("'\"") <= line("$") && &filetype !~# "\v(gitcommit|fugitive|git)" |
                \       exe "normal! g'\""                                                                       |
                \   endif
augroup end

" TODO To be improve

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
    if !exists('g:plugs["completor.vim"]')
        autocmd BufWritePre                 * call autocmd#CleanFile()
    endif
augroup end

" Specially helpful for html and xml
augroup MatchChars
    autocmd!
    autocmd FileType xml,html autocmd BufReadPre <buffer> setlocal matchpairs+=<:>
augroup end

augroup QuickQuit
    autocmd!
    autocmd BufEnter,BufReadPost __LanguageClient__ nnoremap <silent> <buffer> q :q!<CR>
    autocmd BufEnter,BufWinEnter * if &previewwindow | nnoremap <silent> <buffer> q :q!<CR> | endif
    if has('nvim')
        autocmd TermOpen * nnoremap <silent> <buffer> q :q!<CR>
    elseif has('terminal')
        autocmd TerminalOpen * nnoremap <silent> <buffer> q :q!<CR>
    endif
augroup end

augroup LocalCR
    autocmd!
    autocmd CmdwinEnter * nnoremap <CR> <CR>
augroup end

augroup FileTypeDetect
    autocmd!
    autocmd BufNewFile,BufReadPre    *.xmp          setlocal filetype=xml
    autocmd BufNewFile,BufReadPre    *.bash*        setlocal filetype=sh
    autocmd BufNewFile,BufReadPre /*/nginx/*.conf   setlocal filetype=nginx
augroup end

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType tex,vimwiki              setlocal spell complete+=k,kspell
    autocmd BufNewFile,BufRead,BufEnter *.org setlocal spell complete+=k,kspell
augroup end
" }}} EndSpell

" Skeletons {{{

augroup Skeletons
    autocmd!
    autocmd BufNewFile * call autocmd#FileName()
augroup end

" }}} EndSkeletons

augroup ProjectConfig
    autocmd!
    if  has('nvim-0.2') || v:version >= 801 || has('patch-8.0.1459')
        autocmd DirChanged * call autocmd#SetProjectConfigs()
    endif
    if has('nvim-0.2') || v:version >= 800 || has('patch-7.4.2077')
        autocmd WinNew, * call autocmd#SetProjectConfigs()
    endif
    autocmd  WinEnter,VimEnter,SessionLoadPost * call autocmd#SetProjectConfigs()
    autocmd VimEnter                          * call tools#abolish('en')
augroup end

augroup LaTex
    autocmd!
    autocmd FileType tex let b:vimtex_main = 'main.tex'
augroup end

augroup Wipe
    autocmd!
    if has('nvim')
        autocmd TermOpen * setlocal bufhidden=wipe
    elseif has('terminal')
        autocmd TerminalOpen * setlocal bufhidden=wipe
    endif
augroup end

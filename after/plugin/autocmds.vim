scriptencoding 'utf-8'
" Autocmds settings
" github.com/mike325/.vim

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
        elseif  has('terminal') && exists('##TerminalOpen')
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
    elseif  has('terminal') && exists('##TerminalOpen')
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

augroup CRMapping
    autocmd!
    autocmd FileType vim,csh,zsh,sh,go,man,help,c,cpp,python nnoremap <buffer> <CR> :call mappings#cr()<CR>
augroup end


" }}} EndSkeletons

augroup ProjectConfig
    autocmd!
    if exists('##DirChanged')
        autocmd DirChanged * call autocmd#SetProjectConfigs()
    endif
    if exists('##WinNew')
        autocmd WinNew * call autocmd#SetProjectConfigs()
    endif
    autocmd WinEnter,VimEnter,SessionLoadPost * call autocmd#SetProjectConfigs()
    autocmd VimEnter                          * call tools#abolish(&spelllang)
augroup end

augroup LaTex
    autocmd!
    autocmd FileType tex let b:vimtex_main = 'main.tex'
augroup end

augroup Wipe
    autocmd!
    if has('nvim')
        autocmd TermOpen * setlocal bufhidden=wipe
    elseif  has('terminal') && exists('##TerminalOpen')
        autocmd TerminalOpen * setlocal bufhidden=wipe
    endif
augroup end

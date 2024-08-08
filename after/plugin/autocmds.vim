scriptencoding 'utf-8'
" Autocmds settings
" github.com/mike325/.vim

" We just want to source this file once and if we have autocmd available
if !has('autocmd') || exists('g:autocmds_loaded')
    finish
endif

let g:autocmds_loaded = 1

if has('nvim')
    lua require('settings/autocmds')
    finish
endif

let g:autocmds_loaded = 1

" We don't need Vim's temp files here
augroup DisableTemps
    autocmd!
    autocmd BufNewFile,BufReadPre,BufEnter /tmp/* setlocal noswapfile nobackup noundofile
augroup end

" TODO make a function to save the state of the toggles
augroup Numbers
    autocmd!
    autocmd WinEnter    * if &buftype !=# 'terminal' | setlocal relativenumber number | endif
    autocmd WinLeave    * if &buftype !=# 'terminal' | setlocal norelativenumber number | endif
    autocmd InsertLeave * if &buftype !=# 'terminal' | setlocal relativenumber number | endif
    autocmd InsertEnter * if &buftype !=# 'terminal' | setlocal norelativenumber number | endif
augroup end

if has#autocmd('TerminalOpen')
    augroup TerminalAutocmds
        autocmd!
        autocmd TerminalOpen * setlocal relativenumber number nocursorline
        autocmd TerminalOpen * setlocal noswapfile nobackup noundofile
        autocmd TerminalOpen * setlocal bufhidden=wipe
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

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
    if !has#plugin('completor.vim')
        autocmd BufWritePre * call autocmd#CleanFile()
    endif
augroup end

augroup QuickQuit
    autocmd!
    autocmd BufEnter,BufReadPost __LanguageClient__ nnoremap <silent> <nowait> <buffer> q :q!<CR>
    autocmd BufEnter,BufWinEnter * if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif
augroup end

augroup LocalCR
    autocmd!
    autocmd CmdwinEnter * nnoremap <CR> <CR>
augroup end

" Skeletons {{{

augroup Skeletons
    autocmd!
    autocmd BufNewFile * call autocmd#FileName()
augroup end

" }}} EndSkeletons

augroup ProjectConfig
    autocmd!
    if has#autocmd('DirChanged')
        autocmd DirChanged * call autocmd#SetProjectConfigs(has#patch('8.0.1394') ? deepcopy(v:event) : {})
    endif
    autocmd BufNewFile,BufReadPre,BufEnter,VimEnter * call autocmd#SetProjectConfigs(has#patch('8.0.1394') ? deepcopy(v:event) : {})
augroup end

augroup CloseMenu
    autocmd!
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
augroup end

if executable('tmux') && has#autocmd('TextYankPost')
    function! s:copy_yanked_text(data) abort
        if !empty($TMUX_VERSION)
            let l:reg = a:data['regname']
            let l:operator = a:data['operator']
            if l:operator == 'y' && (l:reg == '' || l:reg == '*' || l:reg == '+' || l:reg == '"')
                call system("tmux load-buffer -", join(a:data['regcontents'], '\n'))
            endif
        endif
    endfunction

    augroup CopyYankToTmux
        autocmd!
        autocmd TextYankPost * call s:copy_yanked_text(v:event)
    augroup end
endif

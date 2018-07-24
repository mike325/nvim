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
        autocmd FileType    help setlocal relativenumber number
        autocmd FileType    man  setlocal relativenumber number
        autocmd WinEnter    *    setlocal relativenumber number
        autocmd WinLeave    *    setlocal norelativenumber number
        autocmd InsertLeave *    setlocal relativenumber number
        autocmd InsertEnter *    setlocal norelativenumber number
    augroup end
endif

" We don't need Vim's temp files here
augroup DisableTemps
    autocmd!
    autocmd FileType                        git                setlocal noswapfile nobackup noundofile
    autocmd BufNewFile,BufReadPre,BufEnter  man://*            setlocal noswapfile nobackup noundofile
    autocmd BufNewFile,BufReadPre,BufEnter  /tmp/*             setlocal noswapfile nobackup noundofile
    autocmd BufNewFile,BufReadPre,BufEnter  gitcommit          setlocal noswapfile nobackup
    autocmd BufNewFile,BufReadPre,BufEnter  *.txt              setlocal noswapfile nobackup
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
function! s:CleanFile()
    " Sometimes we don't want to remove spaces
    let l:buftypes = 'nofile\|help\|quickfix\|terminal'
    let l:filetypes = 'bin\|hex\|log\|git\|man\|terminal'

    if b:trim != 1 || &buftype =~? l:buftypes || &filetype ==? l:filetypes || &filetype ==? ''
        return
    endif

    "Save last cursor position
    let l:savepos = getpos('.')
    " Save last search query
    let l:oldquery = getreg('/')

    " Cleaning line endings
    execute '%s/\s\+$//e'
    call histdel('search', -1)

    " Yep I some times I copy this things form the terminal
    silent! execute '%s/\(\s\+\)┊/\1 /ge'
    call histdel('search', -1)

    if &fileformat ==# 'unix'
        silent! execute '%s/\r$//ge'
        call histdel('search', -1)
    endif

    " Config dosini files must trim leading spaces
    if &filetype ==# 'dosini'
        silent! execute '%s/^\s\+//e'
        call histdel('search', -1)
    endif


    call setpos('.', l:savepos)
    call setreg('/', l:oldquery)
endfunction

" Trim whitespace in selected files
augroup CleanFile
    autocmd!
    autocmd BufNewFile,BufRead,BufEnter * if !exists('b:trim') | let b:trim = 1 | endif
    autocmd FileType                    * autocmd BufWritePre <buffer> call s:CleanFile()
augroup end

" Specially helpful for html and xml
augroup MatchChars
    autocmd!
    autocmd FileType xml,html autocmd BufReadPre <buffer> setlocal matchpairs+=<:>
augroup end

augroup QuickQuit
    autocmd!
    autocmd BufReadPost quickfix nnoremap <silent> <buffer> q :q!<CR>
    autocmd FileType    help     nnoremap <silent> <buffer> q :q!<CR>
    autocmd FileType    git      nnoremap <silent> <buffer> q :q!<CR>
    autocmd FileType    man      nnoremap <silent> <buffer> q :q!<CR>
    if has('nvim')
        autocmd TermOpen    *        nnoremap <silent> <buffer> q :q!<CR>
    endif
augroup end

augroup LocalCR
    autocmd!
    autocmd BufReadPost quickfix nnoremap <buffer> <CR> <CR>
    autocmd CmdwinEnter *        nnoremap <CR> <CR>
augroup end

augroup FileTypeDetect
    autocmd!
    autocmd BufRead,BufNewFile             gitconfig,*.git/config setlocal filetype=gitconfig
    autocmd BufRead,BufNewFile             *.bash*                setlocal filetype=sh
    autocmd BufRead,BufNewFile             *.in,*.si,*.sle        setlocal filetype=conf
    autocmd BufNewFile,BufReadPre          /*/nginx/*.conf        setlocal filetype=nginx
augroup end

augroup HideSettigns
    autocmd!
    autocmd FileType man       setlocal bufhidden=delete nomodifiable
    autocmd FileType git       setlocal bufhidden=hide
    " autocmd FileType git       autocmd BufLeave <buffer> call execute("bdelete!", "silent!")
    autocmd FileType gitcommit setlocal bufhidden=delete noreadonly modifiable
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

augroup TabSettings
    autocmd!
    autocmd FileType make setlocal noexpandtab
augroup end

augroup FoldSettings
    autocmd!
    autocmd FileType javascript setlocal foldmethod=syntax
    autocmd FileType git        setlocal foldmethod=syntax
    autocmd FileType go         setlocal foldmethod=syntax
    autocmd FileType python     setlocal foldmethod=indent
    autocmd FileType vim        setlocal foldmethod=indent " May change this for foldmarker
    autocmd FileType markdown   setlocal foldmethod=indent
augroup end

" Spell {{{
augroup Spells
    autocmd!
    autocmd FileType help                     setlocal nospell
    autocmd FileType gitcommit                setlocal spell complete+=k,kspell " Add spell completion
    autocmd FileType markdown                 setlocal spell complete+=k,kspell " Add spell completion
    autocmd FileType tex                      setlocal spell complete+=k,kspell " Add spell completion
    autocmd FileType plaintex                 setlocal spell complete+=k,kspell " Add spell completion
    autocmd FileType text                     setlocal spell complete+=k,kspell " Add spell completion
    autocmd BufNewFile,BufRead,BufEnter *.org setlocal spell complete+=k,kspell " Add spell completion
augroup end
" }}} EndSpell

" Skeletons {{{
" TODO: Improve personalization of the templates
" TODO: Create custom cmd

function! CHeader()

    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    let l:upper_name = toupper(l:file_name)

    if l:extension =~# '^hpp$'
        execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.hpp')
        execute '%s/NAME_HPP/'.l:upper_name.'_HPP/g'
    else
        execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.h')
        execute '%s/NAME_H/'.l:upper_name.'_H/g'
    endif

endfunction

function! CMainOrFunc()

    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    if l:extension =~# '^cpp$'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.cpp')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.cpp')
        endif
    elseif l:extension =~# '^c'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.c')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.c')
        endif
    elseif l:extension =~# '^go'
        if l:file_name =~# '^main$'
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/main.go')
        else
            let l:skeleton = fnameescape(g:parent_dir.'skeletons/skeleton.go')
        endif
    endif

    execute '0r '.l:skeleton
    execute '%s/NAME/'.l:file_name.'/e'

endfunction

function! FileName(file)
    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    execute '0r '.fnameescape(g:parent_dir.'skeletons/'.a:file)
    execute '%s/NAME/'.l:file_name.'/e'
endfunction

augroup Skeletons
    autocmd!
    autocmd BufNewFile .projections.json  silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/projections.json')
    autocmd BufNewFile *.css              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.css')
    autocmd BufNewFile *.html             silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.html')
    autocmd BufNewFile *.md               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.md')
    autocmd BufNewFile *.js               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.js')
    autocmd BufNewFile *.xml              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.xml')
    autocmd BufNewFile *.py               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.py')
    autocmd BufNewFile *.cs               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.cs')
    autocmd BufNewFile *.php              silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.php')
    autocmd BufNewFile *.sh               silent! execute '0r '.fnameescape(g:parent_dir.'skeletons/skeleton.sh')
    autocmd BufNewFile *.java             silent! call FileName('skeleton.java')
    autocmd BufNewFile *.vim              silent! call FileName('skeleton.vim')
    autocmd BufNewFile *.go               silent! call CMainOrFunc()
    autocmd BufNewFile *.cpp              silent! call CMainOrFunc()
    autocmd BufNewFile *.hpp              silent! call CHeader()
    autocmd BufNewFile *.c                silent! call CMainOrFunc()
    autocmd BufNewFile *.h                silent! call CHeader()
augroup end

function! s:FindProjectRoot(file)
    if exists('g:plugs["vim-fugitive"]')
        return fugitive#extract_git_dir(fnamemodify(a:file, ':p'))
    else
        let l:cwd = fnamemodify(a:file, ':h')
        let l:root = ''
        for l:dir in ['.git', '.svn', '.hg']
            let l:root = finddir(l:dir, l:cwd.';')
            if !empty(l:root)
                let l:project_root = fnamemodify(l:dir, ':p:h')
                return l:project_root
            endif
        endfor
    endif
    return ''
endfunction

function! s:SetProjectConfigs()
    let g:project_root =  s:FindProjectRoot(expand('%:p'))
    if g:project_root !=# ''
        let g:project_root = fnamemodify(g:project_root, ':h')

        if filereadable(g:project_root . '/project.vim')
            execute 'source '. g:project_root . '/project.vim'
        endif

        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = 1
        endif

        if exists('g:plugs["vim-grepper"]')
            if executable('git')
                let g:grepper.tools = ['git']
            else
                let g:grepper.tools = []
            endif

            if executable('ag')
                let g:grepper.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
            endif
        else
            if executable('git')
                let &grepprg='git grep --no-color -In'
            else
                if executable('ag')
                    let &grepprg='ag --nogroup --nocolor --hidden ' . g:ignore_patterns.ag . ' '
                elseif executable('grep')
                    let &grepprg='grep --color=never -HIn ' . g:ignore_patterns.grep . ' '
                elseif executable('findstr')
                    let &grepprg='findstr ' . g:ignore_patterns.findstr . ' '
                endif
            endif
        endif
    else
        let g:project_root = fnamemodify(getcwd(), ':p')
        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = (g:ctrlp_user_command.fallback =~# '^ag ')
        endif
        if exists('g:plugs["vim-grepper"]')
            let g:grepper.tools = []

            if executable('ag')
                let g:grepper.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
            endif
        else
            if executable('ag')
                let &grepprg='ag --nogroup --nocolor --hidden ' . g:ignore_patterns.ag . ' '
            elseif executable('grep')
                let &grepprg='grep -HIn --color=never ' . g:ignore_patterns.grep . ' '
            elseif executable('findstr')
                let &grepprg='findstr ' . g:ignore_patterns.findstr . ' '
            endif
        endif
    endif
endfunction

augroup ProjectConfig
    autocmd!
    if has('nvim')
        autocmd DirChanged * call s:SetProjectConfigs()
    endif
    autocmd VimEnter,SessionLoadPost * call s:SetProjectConfigs()
augroup end

" }}} EndSkeletons

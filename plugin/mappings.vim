scriptencoding "uft-8"
" HEADER {{{
"
"                               Mapping settings
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

" We just want to source this file once
if exists('g:mappings_loaded') && g:mappings_loaded
    finish
endif

let g:mappings_loaded = 1

nnoremap , :
xnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual/select the return character
xnoremap $ $h

" Avoid default Ex mode
nnoremap Q o<Esc>
nnoremap <leader>Q Q

" Preserve cursor position when joining lines
nnoremap J m`J``

" Better <ESC> mappings
imap jj <Esc>
nnoremap <BS> <ESC>

xnoremap <BS> <ESC>

" Turn diff off when closiong other windows
nnoremap <silent> <C-w><C-o> :diffoff!<bar>only<cr>
nnoremap <silent> <C-w>o :diffoff!<bar>only<cr>

" Seems like a good idea, may activate it later
" nnoremap <expr> q &diff ? ":diffoff!\<bar>only\<cr>" : "q"

" Move vertically by visual line unless preceded by a count. If a movement is
" greater than 5 then automatically add to the jumplist.
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" Jump to the previous mark, as <TAB>
nnoremap <S-tab> <C-o>

xnoremap > >gv
xnoremap < <gv

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Very Magic sane regex searches
nnoremap g/ /\v
nnoremap gs :%s/\v

" CREDITS: https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" Smart indent when entering insert mode with i on empty lines
function! IndentWithI()
    if len(getline('.')) == 0 && line('.') != line('$') && &buftype !~? 'terminal'
        return '"_ddO'
    else
        return 'i'
    endif
endfunction

nnoremap <expr> i IndentWithI()

if has('nvim') || v:version >= 704
    " Change word under cursor and dot repeat
    nnoremap c* *Ncgn
    nnoremap c# #NcgN
    nnoremap cg* g*Ncgn
    nnoremap cg# g#NcgN
    xnoremap <silent> c "cy/<C-r>c<CR>Ncgn
endif

" Fucking Spanish keyboard
nnoremap ¿ `
xnoremap ¿ `
nnoremap ¿¿ ``
xnoremap ¿¿ ``
nnoremap ¡ ^
xnoremap ¡ ^

" Move to previous file
nnoremap <leader>p <C-^>

" For systems without F's keys (ex. Android)
nnoremap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" TabBufferManagement {{{

" NOTE: Remove in favor of unimpaired plugin  [b and ]b
" Next buffer
" nnoremap <leader>n :bn<CR>
" Prev buffer
" nnoremap <leader>p :bp<CR>

" Buffer movement
nnoremap <leader>h <C-w>h
nnoremap <leader>j <C-w>j
nnoremap <leader>k <C-w>k
nnoremap <leader>l <C-w>l

" Equally resize buffer splits
nnoremap <leader>e <C-w>=

nnoremap <leader>1 1gt
nnoremap <leader>2 2gt
nnoremap <leader>3 3gt
nnoremap <leader>4 4gt
nnoremap <leader>5 5gt
nnoremap <leader>6 6gt
nnoremap <leader>7 7gt
nnoremap <leader>8 8gt
nnoremap <leader>9 9gt
nnoremap <leader>0 :tablast<CR>
nnoremap <leader><leader>n :tabnew<CR>

xnoremap <leader>1 <ESC>1gt
xnoremap <leader>2 <ESC>2gt
xnoremap <leader>3 <ESC>3gt
xnoremap <leader>4 <ESC>4gt
xnoremap <leader>5 <ESC>5gt
xnoremap <leader>6 <ESC>6gt
xnoremap <leader>7 <ESC>7gt
xnoremap <leader>8 <ESC>8gt
xnoremap <leader>9 <ESC>9gt
xnoremap <leader>0 <ESC>:tablast<CR>

" Use C-p and C-n to move in command's history
cnoremap <c-n> <down>
cnoremap <c-p> <up>

" }}} EndTabBufferManagement

if has('nvim') || has('terminal')
    tnoremap <esc> <C-\><C-n>

    if has('nvim')
        " Better splits
        nnoremap <A-s> <C-w>s
        nnoremap <A-v> <C-w>v

        " Better terminal access
        nnoremap <A-t> :terminal<CR>

        " Use ESC to exit terminal mode
        " tnoremap jj <C-\><C-n>
    endif

    if WINDOWS()
        " NOTE: clear (and cmd cls) doesn't work in the latest Neovim's terminal
        " Spawns a bash session inside cmd
        if filereadable('c:/Program Files/Git/bin/bash.exe')
            command! Terminal terminal 'c:/Program Files/Git/bin/bash.exe'
        elseif filereadable('c:/Program Files (x86)/Git/bin/bash.exe')
            command! Terminal terminal 'c:/Program Files (x86)/Git/bin/bash.exe'
        endif
    endif
endif

if exists('+relativenumber')
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if exists('+mouse')
    function! s:ToggleMouse()
        if &mouse ==# ''
            execute 'set mouse=a'
            echo 'mouse'
        else
            execute 'set mouse='
            echo 'nomouse'
        endif
    endfunction
    command! MouseToggle call s:ToggleMouse()
endif

" Remove buffers
"
" BufKill   will remove all hidden buffers
" BufKill!  will remove all unloaded buffers
"
" CREDITS: https://vimrcfu.com/snippet/154
function! s:BufKill(bang)
    let l:count = 0
    for b in range(1, bufnr('$'))
        if bufexists(b) && (!buflisted(b) || (a:bang && !bufloaded(b)))
            execute 'bwipeout '.b
            let l:count += 1
        endif
    endfor
    echo 'Deleted ' . l:count . ' buffers'
endfunction

" Clean buffer list
"
" BufClean   will unload all non active buffers
" BufClean!  will remove all unloaded buffers
function! s:BufClean(bang)
    let l:count = 0
    for b in range(1, bufnr('$'))
        if bufexists(b) && ( (a:bang && !buflisted(b)) || (!a:bang && !bufloaded(b) && buflisted(b)) )
            execute ( (a:bang) ? 'bwipeout ' : 'bdelete! ' ) . b
            let l:count += 1
        endif
    endfor
    echo 'Deleted ' . l:count . ' buffers'
endfunction

let s:arrows = -1

" Test remap arrow keys
function! s:ToggleArrows()
    let s:arrows = s:arrows * -1
    if s:arrows == 1
        nnoremap <left>  <c-w><
        nnoremap <right> <c-w>>
        nnoremap <up>    <c-w>+
        nnoremap <down>  <c-w>-
    else
        unmap <left>
        unmap <right>
        unmap <up>
        unmap <down>
    endif
endfunction

command! ArrowsToggle call s:ToggleArrows()

command! -bang BufKill call s:BufKill(<bang>0)
command! -bang BufClean call s:BufClean(<bang>0)

command! ModifiableToggle setlocal modifiable! modifiable?
command! CursorLineToggle setlocal cursorline! cursorline?
command! ScrollBindToggle setlocal scrollbind! scrollbind?
command! HlSearchToggle   setlocal hlsearch! hlsearch?
command! NumbersToggle    setlocal number! number?
command! PasteToggle      setlocal paste! paste?
command! SpellToggle      setlocal spell! spell?
command! WrapToggle       setlocal wrap! wrap?
command! VerboseToggle    let &verbose=!&verbose | echo "Verbose " . &verbose


if has('nvim') || v:version >= 704
    function! s:SetFileData(action, type, default)
        let l:param = (a:type ==# '') ? a:default : a:type
        execute 'setlocal ' . a:action . '=' . l:param
    endfunction

    function! s:Filter(list, arg)
        let l:filter = filter(a:list, 'v:val =~ a:arg')
        return map(l:filter, 'fnameescape(v:val)')
    endfunction

    function! s:Formats(ArgLead, CmdLine, CursorPos)
        return s:Filter(['unix', 'dos', 'mac'], a:ArgLead)
    endfunction

    " Yes I'm quite lazy to type the cmds
    command! -nargs=? -complete=filetype FileType call s:SetFileData('filetype', <q-args>, 'text')
    command! -nargs=? -complete=customlist,s:Formats FileFormat call s:SetFileData('fileformat', <q-args>, 'unix')
endif

function! s:Trim()
    " Since default is to trim, the first call is to deactivate trim
    if b:trim == 0
        let b:trim = 1
        echomsg ' Trim'
    else
        let b:trim = 0
        echomsg ' NoTrim'
    endif

    return 0
endfunction

command! TrimToggle call s:Trim()

function! s:Spells(ArgLead, CmdLine, CursorPos)
    return ['en', 'es']
endfunction

command! -nargs=? -complete=customlist,s:Spells SpellLang
            \ let s:spell = (empty(<q-args>)) ?  'en' : expand(<q-args>) |
            \ execute 'set spelllang='.s:spell |
            \ execute 'set spelllang?' |
            \ unlet s:spell

" Avoid dispatch command conflict
" QuickfixOpen
command! -nargs=? Qopen
            \ execute 'botright copen ' . expand(<q-args>)

if executable('svn')
    command! -nargs=* SVNstatus execute('!git status ' . <q-args>)
    command! -complete=file -nargs=+ SVN execute('!svn ' . <q-args>)
    command! -complete=file -nargs=* SVNupdate execute('!svn update ' . <q-args>)
    command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
                \ let s:bang = empty(<bang>0) ? '' : '!' |
                \ execute('edit'.s:bang) |
                \ unlet s:bang

endif

" function! s:Scratch(bang, args, range)
"     let s:bang = a:bang
"     if !exists('s:target') || a:bang
"         if bufexists(s:target) || filereadable(s:target)
"             Remove! expand( s:target )
"         endif
"
"         let s:args = expand(a:args)
"         if isdirectory(s:args)
"
"         endif
"         let s:target = fnamemodify(empty(a:args) ? expand($TMPDIR . "/scratch.vim") : expand(a:args), ":p")
"         let s:target = ( fnamemodify(expand( s:target ), ":e") != "vim") ? s:target . ".vim" : s:target
"         unlet s:args
"     endif
"     topleft 18sp expand(s:target)
"     unlet s:bang
" endfunction

" command! -bang -complete=dir -nargs=? Scratch

" function! s:FindProjectRoot()
"     " Statement
" endfunction

" command -nargs=1 -bang -bar -range=0 -complete=custom,s:SubComplete S
"       \ :exec s:subvert_dispatcher(<bang>0,<line1>,<line2>,<count>,<q-args>)

" ####### Fallback Plugin mapping {{{
if !exists('g:plugs["ultisnips"]') && !exists('g:plugs["vim-snipmate"]')
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""

    function! NextSnippetOrReturn()
        if pumvisible()
            if exists('g:plugs["YouCompleteMe"]')
                call feedkeys("\<C-y>")
                return ''
            else
                return "\<C-y>"
            endif
        elseif exists('g:plugs["delimitMate"]') && delimitMate#WithinEmptyPair()
            return delimitMate#ExpandReturn()
        endif
        return "\<CR>"
    endfunction

    inoremap <silent><CR>    <C-R>=NextSnippetOrReturn()<CR>
endif

if !exists('g:plugs["vim-bbye"]')
    nnoremap <leader>d :bdelete!<CR>
endif

if !exists('g:plugs["vim-indexed-search"]')
    " TODO: Integrate center next into vim-slash

    " Center searches results
    " CREDITS: https://amp.reddit.com/r/vim/comments/4jy1mh/slightly_more_subltle_n_and_n_behavior/
    function! s:NiceNext(cmd)
        let view = winsaveview()
        execute 'silent! normal! ' . a:cmd
        if view.topline != winsaveview().topline
            silent! normal! zz
        endif
    endfunction

    " nnoremap * *zz
    " nnoremap # #zz
    nnoremap <silent> n :call <SID>NiceNext('n')<cr>
    nnoremap <silent> N :call <SID>NiceNext('N')<cr>
endif

if !exists('g:plugs["vim-unimpaired"]')
    nnoremap [Q :cfirst<CR>
    nnoremap ]Q :clast<CR>
    nnoremap ]q :cnext<CR>
    nnoremap [q :cprevious<CR>

    nnoremap [l :lprevious<CR>
    nnoremap ]l :lnext<CR>
    nnoremap [L :lfirst<CR>
    nnoremap ]L :llast<CR>

    nnoremap [B :bfirst<cr>
    nnoremap ]B :blast<cr>
    nnoremap [b :bprevious<cr>
    nnoremap ]b :bnext<cr>
endif

if !exists('g:plugs["vim-vinegar"]') && !exists('g:plugs["nerdtree"]')
    nnoremap - :Explore<CR>
endif

" if !exists('g:plugs["vim-grepper"]')
"     onoremap igc
"     xnoremap igc
" endif

if !exists('g:plugs["vim-eunuch"]')
    " command! -bang -nargs=1 -complete=file Move
    "             \

    " command! -bang -nargs=1 -complete=file Rename
    "             \

    command! -bang -nargs=1 -complete=dir Mkdir
                \ let s:bang = empty(<bang>0) ? 0 : 1 |
                \ let s:dir = expand(<q-args>) |
                \ if exists('*mkdir') |
                \   call mkdir(fnameescape(s:dir), (s:bang) ? "p" : "") |
                \ else |
                \   echoerr "Failed to create dir '" . s:dir . "' mkdir is not available" |
                \ endif |
                \ unlet s:bang |
                \ unlet s:dir

    command! -bang -nargs=? -complete=file Remove
                \ let s:bang = empty(<bang>0) ? 0 : 1 |
                \ let s:target = fnamemodify(empty(<q-args>) ? expand("%") : expand(<q-args>), ":p") |
                \ if filereadable(s:target) || bufloaded(s:target) |
                \   if filereadable(s:target) |
                \       if delete(s:target) == -1 |
                \           echoerr "Failed to delete the file '" . s:target . "'" |
                \       endif |
                \   endif |
                \   if bufloaded(s:target) |
                \       let s:cmd = (s:bang) ? "bwipeout! " : "bdelete! " |
                \       try |
                \           execute s:cmd . s:target |
                \       catch /E94/ |
                \           echoer "Failed to delete/wipe '" . s:target . "'" |
                \       finally |
                \           unlet s:cmd |
                \       endtry |
                \   endif |
                \ elseif isdirectory(s:target) |
                \   let s:flag = (s:bang) ? "rf" : "d" |
                \   if delete(s:target, s:flag) == -1 |
                \       echoerr "Failed to remove '" . s:target . "'" |
                \   endif |
                \   unlet s:flag |
                \ else |
                \   echoerr "Failed to remove '" . s:target . "'" |
                \ endif |
                \ unlet s:bang |
                \ unlet s:target
endif

if !exists('g:plugs["vim-fugitive"]') && executable('git')
    " TODO: Git pull command
    if has('nvim')
        command! -nargs=+ Git execute('botright 20split term://git ' . <q-args>)
        command! -nargs=* Gstatus execute('botright 20split term://git status ' . <q-args>)
        command! -nargs=* Gcommit execute('botright 20split term://git commit ' . <q-args>)
        command! -nargs=* Gpush  execute('botright 20split term://git push ' .<q-args>)
        command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
        command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    elseif has('terminal')
        command! -nargs=+ Git call term_start('git ' . <q-args>)
        command! -nargs=* Gstatus call term_start('git status ' . <q-args>)
        command! -nargs=* Gcommit call term_start('git commit ' . <q-args>)
        command! -nargs=* Gpush  call term_start('git push ' .<q-args>)
        command! -nargs=* Gpull  call term_start('git pull ' .<q-args>)
        command! -nargs=* Gwrite  call term_start('git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread call term_start('git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    else
        command! -nargs=+ Git botright 10split gitcmd | 0,$delete | 0read '!git ' . <q-args>
        command! -nargs=* Gstatus botright 10split gitcmd | 0,$delete | 0read '!git status ' . <q-args>
        command! -nargs=* Gcommit botright 10split gitcmd | 0,$delete | 0read '!git commit ' . <q-args>
        command! -nargs=* Gpush  botright 10split gitcmd | 0,$delete | 0read '!git push ' .<q-args>
        command! -nargs=* Gpull  botright 10split gitcmd | 0,$delete | 0read '!git pull ' .<q-args>
        command! -nargs=* Gwrite  botright 10split gitcmd | 0,$delete | 0read '!git add ' . expand("%" . ' ' .<q-args>)
        command! -bang Gread botright 10split gitcmd | 0,$delete | 0read '!git reset HEAD ' . expand("%" . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    endif


    nnoremap <leader>gw :Gwrite<CR>
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gr :Gread<CR>
endif

" }}} END Fallback Plugin mapping

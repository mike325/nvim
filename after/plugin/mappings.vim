scriptencoding 'utf-8'
" Mapping settings
" github.com/mike325/.vim

" We just want to source this file once
if exists('g:mappings_loaded')
    finish
endif

nnoremap , :
xnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual/select the return character
xnoremap $ $h

" Avoid default Ex mode
" Use gQ instead of plain Q, it has tab completion and more cool things
nnoremap Q o<Esc>

" Preserve cursor position when joining lines
nnoremap J m`J``

" Better <ESC> mappings
imap jj <Esc>

nnoremap <BS> :call mappings#bs()<CR>
xnoremap <BS> <ESC>

" We assume that if we are running neovim from windows without has#gui we are
" running from cmd or powershell, windows terminal send <C-h> when backspace is press
if has('nvim') && os#name('windows') && !has#gui()
    nnoremap <C-h> :call mappings#bs()<CR>
    " nnoremap <C-h> <ESC>
    xnoremap <C-h> <ESC>

    " We can't sent neovim to background in cmd or powershell
    nnoremap <C-z> <nop>
endif

inoremap <C-U> <C-G>u<C-U>

" Use <C-L> to clear the highlighting of :set hlsearch.
if maparg('<C-L>', 'n') ==# ''
  nnoremap <silent> <C-L> :nohlsearch<C-R>=has('diff')?'<Bar>diffupdate':''<CR><CR><C-L>
endif

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

" I prefer to jump directly to the file line
" nnoremap gf gF

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Very Magic sane regex searches
nnoremap / ms/
nnoremap g/ ms/\v
" nnoremap gs :%s/\v

nnoremap <expr> i mappings#IndentWithI()

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

cabbrev Gti Git
cabbrev W   w
cabbrev Q   q
cabbrev q1  q!
cabbrev w1  w!
cabbrev wA! wa!

" Use C-p and C-n to move in command's history
cnoremap <C-n> <down>
cnoremap <C-p> <up>

cnoremap <C-r><C-w> "<C-r>=escape(expand('<cword>'), '#')<CR>"

" Repeat last substitution
nnoremap & :&&<CR>
xnoremap & :&&<CR>

" Swap 0 and ^, ^ is them most common line beginning for me
nnoremap 0 ^
nnoremap ^ 0

" select last inserted text
nnoremap gV `[v`]

" repeat last command for each line of a visual selection
" xnoremap . :normal .<CR>

" }}} EndTabBufferManagement

if has('nvim') || has('terminal')
    tnoremap <ESC> <C-\><C-n>

    command! -nargs=? Terminal call mappings#terminal(<q-args>)

    if has('nvim')
        " Better splits
        nnoremap <A-s> <C-w>s
        nnoremap <A-v> <C-w>v

        " Better terminal access
        nnoremap <A-t> :Terminal<CR>
    endif
endif

if os#name('windows')
    command! PowershellToggle call windows#toggle_powershell()
endif

if exists('+relativenumber')
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if exists('+mouse')
    command! MouseToggle call mappings#ToggleMouse()
endif

command! ArrowsToggle call mappings#ToggleArrows()
command! -bang BufKill call mappings#BufKill(<bang>0)
command! -bang BufClean call mappings#BufClean(<bang>0)

command! ModifiableToggle setlocal modifiable! modifiable?
command! CursorLineToggle setlocal cursorline! cursorline?
command! ScrollBindToggle setlocal scrollbind! scrollbind?
command! HlSearchToggle   setlocal hlsearch! hlsearch?
command! NumbersToggle    setlocal number! number?
command! PasteToggle      setlocal paste! paste?
command! SpellToggle      setlocal spell! spell?
command! WrapToggle       setlocal wrap! wrap?
command! VerboseToggle    let &verbose=!&verbose | echo "Verbose " . &verbose

if exists('g:gonvim_running')
    command! -nargs=* GonvimSettngs execute('edit ~/.gonvim/setting.toml')
endif

if has('nvim') || v:version >= 704
    command! -nargs=? -complete=filetype FileType call mappings#SetFileData('filetype', <q-args>, 'text')
    command! -nargs=? -complete=customlist,mappings#format FileFormat call mappings#SetFileData('fileformat', <q-args>, 'unix')
endif

command! TrimToggle call mappings#Trim()

command! -nargs=? -complete=customlist,mappings#spells SpellLang
            \ let s:spell = (empty(<q-args>)) ?  'en' : expand(<q-args>) |
            \ call tools#spelllangs(s:spell) |
            \ unlet s:spell
            " \ execute 'set spelllang?' |

command! -nargs=? ConncallLevel  call mappings#ConncallLevel(expand(<q-args>))

" Avoid dispatch command conflict
" QuickfixOpen
command! -nargs=? Qopen execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)

if executable('svn')
    command! -nargs=* SVNstatus execute('!svn status ' . <q-args>)
    command! -complete=file -nargs=+ SVN execute('!svn ' . <q-args>)
    command! -complete=file -nargs=* SVNupdate execute('!svn update ' . <q-args>)
    command! -complete=file -bang SVNread execute('!svn revert ' . expand("%")) |
                \ let s:bang = empty(<bang>0) ? '' : '!' |
                \ execute('edit'.s:bang) |
                \ unlet s:bang

endif

" ####### Fallback Plugin mapping {{{

if !exists('g:plugs["denite.nvim"]') && !exists('g:plugs["fzf.vim"]')
    command! -nargs=1 -complete=customlist,tools#oldfiles Oldfiles edit <args>
endif

if !exists('g:plugs["iron.nvim"]') && has#python()
    command! -complete=file -nargs=* Python call mappings#Python(2, <q-args>)
    command! -complete=file -nargs=* Python3 call mappings#Python(3, <q-args>)
endif

if !exists('g:plugs["ultisnips"]') && !exists('g:plugs["vim-snipmate"]')
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""
    inoremap <silent><CR>    <C-R>=mappings#NextSnippetOrReturn()<CR>
endif

if !exists('g:plugs["vim-bbye"]')
    nnoremap <leader>d :bdelete!<CR>
endif

if !exists('g:plugs["vim-indexed-search"]')
    " nnoremap * *zz
    " nnoremap # #zz
    nnoremap <silent> n :call mappings#NiceNext('n')<cr>
    nnoremap <silent> N :call mappings#NiceNext('N')<cr>
endif

if !exists('g:plugs["vim-unimpaired"]')

    nnoremap <silent> [Q  :<C-U>exe "".(v:count ? v:count : "")."cfirst"<CR>zvzz
    nnoremap <silent> ]Q  :<C-U>exe "".(v:count ? v:count : "")."clast"<CR>zvzz
    nnoremap <silent> [q  :<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz
    nnoremap <silent> ]q  :<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz

    nnoremap <silent> [L  :<C-U>exe "".(v:count ? v:count : "")."lfirst"<CR>zvzz
    nnoremap <silent> ]L  :<C-U>exe "".(v:count ? v:count : "")."llast"<CR>zvzz
    nnoremap <silent> [l  :<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz
    nnoremap <silent> ]l  :<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz

    nnoremap <silent> [B :<C-U>exe "".(v:count ? v:count : "")."bfirst"<CR>
    nnoremap <silent> ]B :<C-U>exe "".(v:count ? v:count : "")."blast"<CR>
    nnoremap <silent> [b :<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>
    nnoremap <silent> ]b :<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>

endif

if !exists('g:plugs["vim-vinegar"]') && !exists('g:plugs["nerdtree"]')
    nnoremap - :Explore<CR>
endif

" if !exists('g:plugs["vim-grepper"]')
"     onoremap igc
"     xnoremap igc
" endif

if !exists('g:plugs["vim-eunuch"]')
    if exists('*rename')
        command! -bang -nargs=1 -complete=file Move
                    \ let s:name = expand(<q-args>) |
                    \ let s:current = expand('%:p') |
                    \ if (rename(s:current, s:name)) |
                    \   execute 'edit ' . s:name |
                    \   execute 'bwipeout! '.s:current |
                    \ endif |
                    \ unlet s:name |
                    \ unlet s:current

        command! -bang -nargs=1 -complete=file Rename
                    \ let s:name = expand('%:p:h') . '/' . expand(<q-args>) |
                    \ let s:current = expand('%:p') |
                    \ if (rename(s:current, s:name)) |
                    \   execute 'edit ' . s:name |
                    \   execute 'bwipeout! '.s:current |
                    \ endif |
                    \ unlet s:name |
                    \ unlet s:current
    endif

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
                \           echoerr "Failed to delete/wipe '" . s:target . "'" |
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
    if has('nvim')
        command! -nargs=+ Git execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git ' . <q-args>)
        command! -nargs=* Gstatus execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git status ' . <q-args>)
        command! -nargs=* Gcommit execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git commit ' . <q-args>)
        command! -nargs=* Gpush  execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split term://git push ' .<q-args>)
        command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
        command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    else
        if has('terminal')
            command! -nargs=+ Git     term_start('git ' . <q-args>, {'       term_rows': 20})
            command! -nargs=* Gstatus term_start('git status ' . <q-args>, {'term_rows': 20})
            command! -nargs=* Gpush   term_start('git push ' .<q-args>, {'   term_rows': 20})
        else
            command! -nargs=+ Git     execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git ' . <q-args>)
            command! -nargs=* Gstatus execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git status ' . <q-args>)
            command! -nargs=* Gpush   execute(((&splitbelow) ? 'botright' : 'topleft' ) . ' 20split gitcmd | 0,$delete | 0read !git push ' .<q-args>)
        endif

        command! -nargs=* Gcommit execute('!git commit ' . <q-args>)
        command! -nargs=* Gpull  execute('!git pull ' .<q-args>)
        command! -nargs=* Gwrite  execute('!git add ' . expand("%") . ' ' .<q-args>)
        command! -bang Gread execute('!git reset HEAD ' . expand("%") . ' && git checkout -- ' . expand("%")) |
                    \ let s:bang = empty(<bang>0) ? '' : '!' |
                    \ execute('edit'.s:bang) |
                    \ unlet s:bang
    endif


    nnoremap <leader>gw :Gwrite<CR>
    nnoremap <leader>gs :Gstatus<CR>
    nnoremap <leader>gc :Gcommit<CR>
    nnoremap <leader>gr :Gread<CR>
endif

" if !exists('g:plugs["denite.nvim"]') && !exists('g:plugs["vim-grepper"]')
"     nnoremap gs :set operatorfunc=GrepOperator<cr>g@
"     vnoremap gs :<c-u>call GrepOperator(visualmode())<cr>
"
"     function! GrepOperator(type)
"         if a:type ==# 'v'
"             normal! `<v`>y
"         elseif a:type ==# 'char'
"             normal! `[v`]y
"         else
"             return
"         endif
"
"         silent execute 'grep -nIR ' . shellescape(@@) . ' .'
"     endfunction
" endif

" }}} END Fallback Plugin mapping

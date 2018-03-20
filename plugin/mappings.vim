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
if exists("g:mappings_loaded") && g:mappings_loaded
    finish
endif

let g:mappings_loaded = 1

nnoremap , :
vnoremap , :

" Similar behavior as C and D
nnoremap Y y$

" Don't visual/select the return character
vnoremap $ $h

" Avoid defualt Ex mode
nnoremap Q o<Esc>
nnoremap <leader>Q Q

" Preserve cursor position when joining lines
nnoremap J mzJ`z:delmarks<space>z<CR>

" Better <ESC> mappings
imap jj <Esc>
nnoremap <BS> <ESC>
vnoremap <BS> <ESC>

" Move vertically by visual line unless preceded by a count. If a movement is
" greater than 5 then automatically add to the jumplist.
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" NOTE: Removed mapping to use jump list
" nnoremap <tab> >>
nnoremap <S-tab> <C-o>

vnoremap > >gv
vnoremap < <gv

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Very Magic sane regex searches
nnoremap g/ /\v

" https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" -- Smart indent when entering insert mode with i on empty lines --------------
function! IndentWithI()
    if len(getline('.')) == 0 && line('.') != line('$') && &buftype !~? 'terminal'
        return "\"_ddO"
    else
        return "i"
    endif
endfunction

nnoremap <expr> i IndentWithI()

if has("nvim") || v:version >= 704
    " Change word under cursor and dot repeat
    nnoremap c* *Ncgn
    nnoremap c# #NcgN
    nnoremap cg* g*Ncgn
    nnoremap cg# g#NcgN
    xnoremap <silent> c "cy/<C-r>c<CR>Ncgn
endif

" Fucking Spanish keyboard
nnoremap ¿ `
nnoremap ¿¿ ``
nnoremap ¡ ^

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

vnoremap <leader>1 <ESC>1gt
vnoremap <leader>2 <ESC>2gt
vnoremap <leader>3 <ESC>3gt
vnoremap <leader>4 <ESC>4gt
vnoremap <leader>5 <ESC>5gt
vnoremap <leader>6 <ESC>6gt
vnoremap <leader>7 <ESC>7gt
vnoremap <leader>8 <ESC>8gt
vnoremap <leader>9 <ESC>9gt
vnoremap <leader>0 <ESC>:tablast<CR>

" }}} EndTabBufferManagement

if has("nvim")
    " Better splits
    nnoremap <A-s> <C-w>s
    nnoremap <A-v> <C-w>v

    " Better terminal access
    nnoremap <A-t> :terminal<CR>
    if WINDOWS()
        " NOTE: clear (and cmd cls) doesn't work in the latest Neovim's terminal
        " Spawns a bash session inside cmd
        if filereadable("c:/Program\ Files/Git/bin/bash.exe")
            command! Terminal terminal "c:/Program Files/Git/bin/bash.exe"
        elseif filereadable("c:/Program Files (x86)/Git/bin/bash.exe")
            command! Terminal terminal "c:/Program Files (x86)/Git/bin/bash.exe"
        endif
    endif

    " Use ESC to exit terminal mode
    tnoremap <Esc> <C-\><C-n>
endif

if exists("+relativenumber")
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if exists("+mouse")
    function! s:ToggleMouse()
        if &mouse == ''
            execute 'set mouse=a'
            echo "mouse"
        else
            execute 'set mouse='
            echo "nomouse"
        endif
    endfunction
    command! MouseToggle call s:ToggleMouse()
endif

" Remove buffers
"
" 'Buffkill'   will remove all hidden buffers
" 'Buffkill!'  will remove all unloaded buffers
"
" CREDITS: https://vimrcfu.com/snippet/154
function! s:BuffKill(bang)
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
" 'BuffClean'   will unload all non active buffers
" 'BuffClean!'  will remove all unloaded buffers
function! s:BuffClean(bang)
    let l:count = 0
    for b in range(1, bufnr('$'))
        if bufexists(b) && ( (a:bang && !buflisted(b)) || (!a:bang && !bufloaded(b) && buflisted(b)) )
            execute ( (a:bang) ? 'bwipeout ' : 'bdelete! ' ) . b
            let l:count += 1
        endif
    endfor
    echo 'Deleted ' . l:count . ' buffers'
endfunction

command! -bang Buffkill call s:BufferKill(<bang>0)
command! -bang BuffClean call s:BuffClean(<bang>0)

command! ModifiableToggle setlocal modifiable! modifiable?
command! CursorLineToggle setlocal cursorline! cursorline?
command! ScrollBindToggle setlocal scrollbind! scrollbind?
command! HlSearchToggle   setlocal hlsearch! hlsearch?
command! NumbersToggle    setlocal number! number?
command! PasteToggle      setlocal paste! paste?
command! SpellToggle      setlocal spell! spell?
command! WrapToggle       setlocal wrap! wrap?

function! s:SetFileData(action, type, default)
    let l:param = (a:type == "") ? a:default : a:type
    execute "setlocal " . a:action . "=" . l:param
endfunction

function! s:Filter(list, arg)
    let l:filter = filter(a:list, 'v:val =~ a:arg')
    return map(l:filter, 'fnameescape(v:val)')
endfunction

function! s:Formats(ArgLead, CmdLine, CursorPos)
    return s:Filter(["unix", "dos", "mac"], a:ArgLead)
endfunction

function! s:Types(ArgLead, CmdLine, CursorPos)
    let l:names =  [
                \ "c",
                \ "cmake",
                \ "cpp",
                \ "cs",
                \ "csh",
                \ "css",
                \ "dosini",
                \ "go",
                \ "html",
                \ "java",
                \ "javascript",
                \ "json",
                \ "log",
                \ "lua",
                \ "make",
                \ "markdown",
                \ "php",
                \ "python",
                \ "ruby",
                \ "rust",
                \ "sh",
                \ "simics",
                \ "tex",
                \ "text",
                \ "vim",
                \ "xml",
                \ "yml",
                \ "zsh"
            \ ]
    return s:Filter(l:names, a:ArgLead)
endfunction

" Yes I'm quite lazy to type the cmds
command! -nargs=? -complete=customlist,s:Types FileType call s:SetFileData("filetype", <q-args>, "text")
command! -nargs=? -complete=customlist,s:Formats FileFormat call s:SetFileData("fileformat", <q-args>, "unix")

" Use in autocmds.vim
if !exists("b:trim")
    let b:trim = 1
endif

function! s:Trim()
    if !exists("b:trim") || b:trim != 1
        let b:trim = 1
        echomsg " Trim"
    else
        let b:trim = 0
        echomsg " NoTrim"
    endif

    return 0
endfunction

command! TrimToggle call s:Trim()

function! s:SpellLang(lang)
    let l:spell = (a:lang == "") ?  "en" : a:lang
    execute "set spelllang=".l:spell
    execute "set spelllang?"
endfunction

function! s:Spells(ArgLead, CmdLine, CursorPos)
    return ["en", "es"]
endfunction

command! -nargs=? -complete=customlist,s:Spells SpellLang call s:SpellLang(<q-args>)

" Small wrapper around copen cmd
function! s:OpenQuickfix(size)
    execute "botright copen " . a:size
endfunction

" Avoid dispatch command conflicw
" QuickfixOpen
command! -nargs=? Qopen call s:OpenQuickfix(<q-args>)

" ####### Fallback Plugin mapping {{{
if !exists('g:plugs["ultisnips"]') && !exists('g:plugs["vim-snipmate"]')
    inoremap <expr><TAB> pumvisible() ? "\<C-n>" : "\<TAB>"
    inoremap <expr><S-TAB> pumvisible() ? "\<C-p>" : ""

    function! NextSnippetOrReturn()
        if pumvisible()
            if exists('g:plugs["YouCompleteMe"]')
                call feedkeys("\<C-y>")
                return ""
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
        execute "silent! normal! " . a:cmd
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

" }}} END Fallback Plugin mapping

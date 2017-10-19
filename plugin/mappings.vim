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

" Don't visual select the return character
vnoremap $ $h

" Avoid Ex mode
nnoremap Q o<Esc>

" Preserve cursor position when joining lines
nnoremap J mzJ`z:delmarks<space>z<CR>

" Easy <ESC> insert mode
imap jj <Esc>

" Move vertically by visual line unless preceded by a count. If a movement is
" greater than 5 then automatically add to the jumplist.
nnoremap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
nnoremap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'

" NOTE: Removed mapping to use jump list
" nnoremap <tab> >>
nnoremap <S-tab> <C-o>

" TODO: May use this in UltiSnips
" Remove stuff in normal/visual mode without change any register
" nnoremap <BS> "_
" vnoremap <BS> "_
vnoremap > >gv
vnoremap < <gv

vnoremap <BS> <ESC>

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Very Magic sane regex searches
nnoremap g/ /\v

" Center searches results
" Credits to https://amp.reddit.com/r/vim/comments/4jy1mh/slightly_more_subltle_n_and_n_behavior/
function! s:nice_next(cmd)
    let view = winsaveview()
    execute "silent! normal! " . a:cmd
    if view.topline != winsaveview().topline
        silent! normal! zz
    endif
endfunction

" nnoremap * *zz
" nnoremap # #zz
nnoremap <silent> n :call <SID>nice_next('n')<cr>
nnoremap <silent> N :call <SID>nice_next('N')<cr>

" https://github.com/alexlafroscia/dotfiles/blob/master/nvim/init.vim
" -- Smart indent when entering insert mode with i on empty lines --------------
function! IndentWithI()
    if len(getline('.')) == 0 && getline('.') != getline('$') && &buftype !~? 'terminal'
        return "\"_ddO"
    else
        return "i"
    endif
endfunction

nnoremap <expr> i IndentWithI()

" Change word under cursor and dot repeat
nnoremap c* *Ncgn
nnoremap c# #NcgN
nnoremap cg* g*Ncgn
nnoremap cg# g#NcgN
xnoremap <silent> c y/<C-r>"<CR>Ncgn

" Fucking Spanish keyboard
nnoremap ¿ `
nnoremap ¡ ^

" For systems without F's keys (ex. Android)
nmap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" TabBufferManagement {{{

" Next buffer
nnoremap <leader>n :bn<CR>

" Prev buffer
nnoremap <leader>p :bp<CR>

" Buffer movement
nmap <leader>h <C-w>h
nmap <leader>j <C-w>j
nmap <leader>k <C-w>k
nmap <leader>l <C-w>l

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

" }}} EndTabBufferManagement

if has("nvim")
    " Better splits
    nnoremap <A-s> <C-w>s
    nnoremap <A-v> <C-w>v

    " Better terminal access
    nnoremap <A-t> :terminal<CR>

    " Use ESC to exit terminal mode
    tnoremap <Esc> <C-\><C-n>
endif

" Small wrapper around copen cmd
function! s:OpenQuickfix(size)
    execute "botright copen " . a:size
endfunction

command! -nargs=? Copen call s:OpenQuickfix(<q-args>)

if exists("+relativenumber")
    command! RelativeNumbersToggle set relativenumber! relativenumber?
endif

if exists("+mouse")
    function! s:ToggleMouse()
        if &mouse == ''
            execute 'set mouse=a'
        else
            execute 'set mouse='
        endif
    endfunction
    command! MouseToggle call s:ToggleMouse()
endif

command! CursorLineToggle setlocal cursorline! cursorline?
command! NumbersToggle setlocal number! number?
command! HlSearchToggle setlocal hlsearch! hlsearch?
command! SpellToggle setlocal spell! spell?

command! ScrollBindToggle setlocal scrollbind! scrollbind?

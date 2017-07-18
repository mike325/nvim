" HEADER {{{
"
"                             Small improvements
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

" Don't visual select the <CR> character
vnoremap $ $h

" Easy <ESC> insert mode
imap jj <Esc>

" Echo the relative path and of the file
nnoremap <leader><leader>e :echo expand("%")<CR>

" Add lines in normal mode without enter in insert mode
nnoremap <C-o> O<Esc>
nmap Q o<Esc>

" Remove stuff in normal/visul mode without change any register
nnoremap <BS> "_
vnoremap <BS> "_

" Easy indentation in normal mode
nnoremap <tab> >>
nnoremap <S-tab> <<
vnoremap <tab> >gv
vnoremap <S-tab> <gv

" nnoremap <F2> :update<CR>
" vmap <F2> <Esc><F2>gv
" imap <F2> <Esc><F2>a

" For systems without F's keys (ex. android)
nmap <leader>w :update<CR>

" Close buffer/Editor
nnoremap <leader>q :q!<CR>

" easy dump bin files into hex
nnoremap <leader>x :%!xxd<CR>

" Native explorer
" nnoremap E :Explore<CR>

" TabBufferManagement {{{

" Next buffer
nnoremap <leader>n :bn<CR>

" Prev buffer
nnoremap <leader>p :bp<CR>

nnoremap <C-x> <C-w><C-w>

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
nnoremap <leader>N :tabNext<CR>
nnoremap <leader><leader>n :tabnew<CR>
nnoremap <leader>c :tabclose<CR>

" }}} EndTabBufferManagement

" Toggles {{{ May be repleace by unpaired tpope plugin
"
" nnoremap tn :set number!<Bar>set number?<CR>
" nnoremap tr :set relativenumber!<Bar>set relativenumber?<CR>
"
" nnoremap th :set hlsearch!<Bar>set hlsearch?<CR>
" nnoremap ti :set ignorecase!<Bar>set ignorecase?<CR>
"
" nnoremap tw :set wrap!<Bar>set wrap?<CR>
"
" nnoremap tcl :set cursorline!<Bar>set cursorline?<CR>
" nnoremap tcc :set cursorcolumn!<Bar>set cursorcolumn?<CR>
"
" nnoremap tss :setlocal spell!<Bar>set spell?<CR>
" nnoremap tse :setlocal spelllang=en_us<Bar>set spelllang?<CR>
" nnoremap tsm :setlocal spelllang=es_mx<Bar>set spelllang?<CR>
"
" nnoremap td :<C-R>=&diff ? 'diffoff' : 'diffthis'<CR><CR>
"
" }}} EndToggles

if has("nvim")
    " Better splits
    nnoremap <A-s> <C-w>s
    nnoremap <A-v> <C-w>v

    " Better terminal access
    nnoremap <A-t> :terminal<CR>

    " Use ESC to exit terminal mode
    tnoremap <Esc> <C-\><C-n>
endif

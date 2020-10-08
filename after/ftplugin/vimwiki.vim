" Vimwiki Setttings
" github.com/mike325/.vim

" if !has#gui() " Terminals can't detect some special key combinations
" endif

setlocal spell
setlocal complete+=k,kspell
setlocal textwidth=80

if !has#plugin('vimwiki')
    finish
endif

nmap <buffer> gww <Plug>VimwikiIndex
nmap <buffer> gws :VimwikiSearchTags<space>
" nmap <buffer> <leader>gt :VimwikiGenerateTags<CR>

nmap <buffer> <CR> <Plug>VimwikiFollowLink

if os#name('windows') && !has#gui()
    nmap <buffer> <C-h> <Plug>VimwikiGoBackLink
else
    nmap <buffer> <BS> <Plug>VimwikiGoBackLink
endif

nmap <buffer> - <Plug>VimwikiToggleListItem
vmap <buffer> - <Plug>VimwikiToggleListItem
nmap <buffer> g- <Plug>VimwikiRemoveSingleCB
vmap <buffer> g- <Plug>VimwikiRemoveSingleCB

nmap <buffer> g<CR> <Plug>VimwikiVSplitLink

nmap <buffer> <C-j> <Plug>VimwikiNextLink
nmap <buffer> <C-k> <Plug>VimwikiPrevLink

nmap <buffer> g= <Plug>VimwikiRemoveHeaderLevel


nnoremap <buffer> gwt :VimwikiTable<CR>
nnoremap <buffer> gwg :VimwikiGoto<space>

nnoremap <buffer> <A-l> m`:VimwikiTableMoveColumnLeft<CR>``
nnoremap <buffer> <A-h> m`:VimwikiTableMoveColumnRight<CR>``

" " Restore signify mappings
" if has#plugin('vim-signify')
"     call plugins#vim_signify#init(0)
" endif

if has('nvim-0.4')
    call luaeval('require"tools".abolish("'.&l:spelllang.'")')
else
    call tools#abolish(&l:spelllang)
endif

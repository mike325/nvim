" Git Fugitive settings
" github.com/mike325/.vim

if !exists('g:plugs["vim-fugitive"]') || exists('g:config_fugitive')
    finish
endif

let g:config_fugitive = 1

" augroup SetGitTags
"     autocmd!
"     autocmd BufReadPost,BufEnter * if filereadable(FugitiveExtractGitDir(getcwd()) . '/tags')  |
"                                 \    let &l:tags .= ','.FugitiveExtractGitDir(getcwd()) . '/tags' |
"                                 \  endif
" augroup end

nnoremap <silent> Us :Gstatus<CR>
nnoremap <silent> Ua :Gcommit --amend --reset-author --no-edit<CR>
nnoremap <silent> Ud :Gdiff<CR>
nnoremap <silent> Uw :Gwrite<CR>
nnoremap <silent> Ur :Gread<CR>
nnoremap <silent> Ub :Gblame<CR>
nnoremap <silent> Ue :exe 'Gedit\|'.line('.')<CR>zz

nmap US Us
nmap UA Ua
nmap UD Ud
nmap UW Uw
nmap UR Ur
nmap UB Ub
nmap UE Ue
nmap UG Ug

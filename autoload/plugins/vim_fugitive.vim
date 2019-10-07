" Git Fugitive settings
" github.com/mike325/.vim

function! plugins#vim_fugitive#init(data) abort
    if !exists('g:plugs["vim-fugitive"]')
        return -1
    endif

    " nnoremap <silent> <leader>gs :Gstatus<CR>
    " nnoremap <silent> <leader>gc :Gcommit<CR>
    " nnoremap <silent> <Leader>ga :Gcommit --amend --reset-author --no-edit<CR>
    " nnoremap <silent> <leader>gd :Gdiff<CR>
    " nnoremap <silent> <leader>gw :Gwrite<CR>
    " nnoremap <silent> <leader>gr :Gread<CR>

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

endfunction

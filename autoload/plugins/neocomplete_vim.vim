" Neocomplete settings
" github.com/mike325/.vim

function! plugins#neocomplete_vim#init(data) abort
    if !exists('g:plugs["neocomplete.vim"]')
        return -1
    endif

    let g:neocomplete#enable_at_startup = 1

    " Use smartcase.
    let g:neocomplete#enable_smart_case = 1
    let g:neocomplete#enable_refresh_always = 1

    " Set minimum syntax keyword length.
    let g:neocomplete#sources#syntax#min_keyword_length = 1
    let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

    if !exists('g:neocomplete#keyword_patterns')
        let g:neocomplete#keyword_patterns = {}
    endif

    " inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-y>  neocomplete#mappings#smart_close_popup()
    " inoremap <expr><C-e>  neocomplete#cancel_popup()

    let g:neocomplete#omni#input_patterns = get(g:,'neocomplete#omni#input_patterns',{})

    let g:neocomplete#sources={}

    " let g:neocomplete#sources._    = ['buffer', 'member', 'file', 'ultisnips']
    " let g:neocomplete#sources.vim        = ['buffer', 'member', 'file', 'ultisnips']
    " let g:neocomplete#sources.c          = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.cpp        = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.go         = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.java       = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.python     = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.javascript = ['buffer', 'member', 'file', 'omni', 'ultisnips']
    " let g:neocomplete#sources.ruby       = ['buffer', 'member', 'file', 'ultisnips']

    " if !exists('g:neocomplete#sources#omni#input_patterns')
    "     let g:neocomplete#sources#omni#input_patterns = {}
    " endif

    augroup CloseMenu
        autocmd!
        autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    augroup end
endfunction

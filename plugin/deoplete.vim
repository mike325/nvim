" ############################################################################
"
"                                Deoplete settings
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
" ############################################################################

if !exists('g:plugs["deoplete.nvim"]')
    finish
endif

let g:deoplete#enable_at_startup = 1

" Use smartcase.
let g:deoplete#enable_smart_case = 1
let g:deoplete#enable_refresh_always = 1

" Set minimum syntax keyword length.
let g:deoplete#sources#syntax#min_keyword_length = 1
let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

" inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
" inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
" inoremap <expr><C-y>  deoplete#mappings#smart_close_popup()
" inoremap <expr><C-e>  deoplete#cancel_popup()

let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})

let g:deoplete#omni#input_patterns.java = ['[^. *\t0-9]\.\w*']
let g:deoplete#omni#input_patterns.javascript = ['[^. *\t0-9]\.\w*']
let g:deoplete#omni#input_patterns.python = ['[^. *\t0-9]\.\w*']
let g:deoplete#omni#input_patterns.go = ['[^. *\t0-9]\.\w*']
let g:deoplete#omni#input_patterns.ruby = ['[^. *\t0-9]\.\w*']

let g:deoplete#omni#input_patterns.c = [
            \'[^. *\t0-9]\.\w*',
            \'[^. *\t0-9]\->\w*',
            \]

let g:deoplete#omni#input_patterns.cpp = [
            \'[^. *\t0-9]\.\w*',
            \'[^. *\t0-9]\->\w*',
            \'[^. *\t0-9]\::\w*',
            \]

let g:deoplete#sources={}
" let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tags', 'ultisnips']

" let g:deoplete#sources.vim        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.c          = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.cpp        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.go         = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.java       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.python     = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.javascript = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
" let g:deoplete#sources.ruby       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']

" if !exists('g:deoplete#omni#input_patterns')
"     let g:deoplete#omni#input_patterns = {}
" endif

augroup CloseMenu
    autocmd!
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
augroup end

call deoplete#custom#set('ultisnips', 'matchers', ['matcher_full_fuzzy'])

if exists('g:plugs["deoplete-jedi"]')
    let g:deoplete#sources#jedi#enable_cache   = 1
    let g:deoplete#sources#jedi#show_docstring = 1
endif

if exists('g:plugs["deoplete-clang"]')
    " Set posible locations in linux
    " /usr/lib/libclang.so
    " /usr/lib/clang
    let g:deoplete#sources#clang#libclang_path = '/usr/lib/libclang.so'
    let g:deoplete#sources#clang#clang_header  = '/usr/lib/clang'
endif

if exists('g:plugs["deoplete-go"]')
    let g:deoplete#sources#go             = 'vim-go'
    let g:deoplete#sources#go#sort_class  = ['package', 'func', 'type', 'var', 'const']
    let g:deoplete#sources#go#use_cache   = 1
    let g:deoplete#sources#go#package_dot = 1
endif

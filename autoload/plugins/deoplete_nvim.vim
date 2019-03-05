" ############################################################################
"
"                          Deoplete and plugins settings
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

" TODO:  Move this out into autocmds.vim
augroup CloseMenu
    autocmd!
    autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
augroup end

function! plugins#deoplete_nvim#gocomletion(info) abort
    if !executable('gocode')
        if os#name('windows')
            !go get -u -ldflags -H=windowsgui github.com/nsf/gocode
        else
            !go get -u github.com/nsf/gocode
        endif
    endif
    make
endfunction

function! plugins#deoplete_nvim#init(data) abort
    if !exists('g:plugs["deoplete.nvim"]')
        return -1
    endif


    let g:deoplete#enable_at_startup = 1

    " Set minimum syntax keyword length.
    let g:deoplete#lock_buffer_name_pattern = '\*ku\*'

    try
        call deoplete#custom#option({
        \   'auto_complete_delay': 20,
        \   'smart_case': 1,
        \   'min_keyword_length': 1,
        \ })
    catch
        let g:deoplete#enable_refresh_always             = 1
        let g:deoplete#enable_smart_case                 = 1
        let g:deoplete#sources#syntax#min_keyword_length = 1
        let g:deoplete#auto_complete_delay               = 20
    endtry

    " inoremap <expr><BS> deoplete#mappings#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-h> deoplete#mappings#smart_close_popup()."\<C-h>"
    " inoremap <expr><C-y>  deoplete#mappings#smart_close_popup()
    " inoremap <expr><C-e>  deoplete#cancel_popup()

    " let g:deoplete#omni#functions      = get(g:,'g:deoplete#omni#functions',{})
    " let g:deoplete#omni#input_patterns = get(g:,'deoplete#omni#input_patterns',{})
    "
    " let g:deoplete#omni#input_patterns.java       = '\w+|[^. *\t0-9].\w*'
    " let g:deoplete#omni#input_patterns.javascript = '\w+|[^. *\t0-9].\w*'
    " let g:deoplete#omni#input_patterns.python     = '\w+|[^. *\t0-9].\w*'
    " let g:deoplete#omni#input_patterns.go         = '\w+|[^. *\t0-9].\w*'
    " let g:deoplete#omni#input_patterns.ruby       = '\w+|[^. *\t0-9].\w*'
    " let g:deoplete#omni#input_patterns.lua        = '\w+|[^. *\t0-9](.:)\w*'
    " let g:deoplete#omni#input_patterns.c          = '\w+|[^. *\t0-9](.|->)\w*'
    " let g:deoplete#omni#input_patterns.cpp        = '\w+|[^. *\t0-9](.|->|::)\w*'

    let g:deoplete#sources = get(g:,'deoplete#sources',{})

    " let g:deoplete#sources._ = ['buffer', 'member', 'file', 'tags', 'ultisnips']

    " let g:deoplete#sources.vim        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.c          = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.cpp        = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.go         = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.java       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.python     = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.javascript = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']
    " let g:deoplete#sources.ruby       = ['buffer', 'member', 'file', 'tags', 'omni', 'ultisnips']

    if !exists('g:deoplete#omni#input_patterns')
        let g:deoplete#omni#input_patterns = {}
    endif

    " call deoplete#enable_logging('DEBUG', fnameescape(g:base_path . '/deoplete.log'))

    " call deoplete#custom#set('ultisnips', 'matchers', ['matcher_full_fuzzy'])

    if exists('g:plugs["LanguageClient-neovim"]')
        try
            call deoplete#custom#source('LanguageClient', 'min_pattern_length',  2)
        catch
            let g:deoplete#sources#LanguageClient#min_pattern_length = 2
        endtry
    endif

    if exists('g:plugs["vim-lua-ftplugin"]') && (executable('luac') || executable('lualint') || exists('g:lua_compiler_name'))
        let g:lua_check_syntax               = 0
        let g:lua_complete_omni              = 1
        let g:lua_complete_dynamic           = 0
        let g:lua_define_completion_mappings = 0

        let g:deoplete#omni#functions     = get(g:, 'deoplete#omni#functions', {})
        let g:deoplete#omni#functions.lua = 'xolox#lua#omnifunc'
    endif

    if exists('g:plugs["deoplete-jedi"]')
        let g:deoplete#sources#jedi#enable_cache   = 1
        let g:deoplete#sources#jedi#show_docstring = 1
    else
        let g:deoplete#omni#functions = get(g:, 'deoplete#omni#functions', {})
        " let g:deoplete#omni#functions.python = 'pythoncomplete#Complete'
    endif

    if exists('g:plugs["deoplete-clang"]') || exists('g:plugs["deoplete-clang2"]')
        let g:deoplete#sources#clang#libclang_path = vars#libclang()

        let g:deoplete#sources = get(g:,'deoplete#sources',{})

        let g:deoplete#sources.c = ['clang']
        let g:deoplete#sources.cpp = ['clang']

        " call deoplete#custom#source('clang', 'debug_enabled', 1)

        let g:deoplete#sources#clang#sort_algo = 'priority'

        if os#name('windows')
            if isdirectory(vars#home() . '/.local/lib/clang/')
                let g:deoplete#sources#clang#clang_header = vars#home() . '/.local/lib/clang/'
            elseif isdirectory('c:/Program Files/LLVM/lib/clang/')
                let g:deoplete#sources#clang#clang_header = 'c:/Program Files/LLVM/lib/clang/'
            elseif isdirectory('c:/Program Files(x86)/LLVM/lib/clang/')
                let g:deoplete#sources#clang#clang_header = 'c:/Program Files(x86)/LLVM/lib/clang/'
            endif
        else
            if isdirectory(vars#home() . '/.local/lib/clang/')
                let g:deoplete#sources#clang#clang_header = vars#home() . '/.local/lib/clang/'
            else
                let g:deoplete#sources#clang#clang_header = '/usr/lib/clang/'
            endif
        endif

        let g:deoplete#sources#clang#std = {
                    \    'c'      : 'c11',
                    \    'cpp'    : 'c++14',
                    \    'objc'   : 'c11',
                    \    'objcpp' : 'c++1z'
                    \}
    endif

    if exists('g:plugs["neoinclude.vim"]')
        let g:neoinclude#exts = get(g:, 'neoinclude#exts', {})

        let g:neoinclude#exts.c   = ['', 'h']
        let g:neoinclude#exts.cpp = ['', 'h', 'hpp', 'hxx']
    endif

    if exists('g:plugs["deoplete-go"]')
        let g:deoplete#sources#go                   = 'vim-go'
        let g:deoplete#sources#go#cgo#libclang_path = vars#libclang()
        let g:deoplete#sources#go#sort_class        = ['package', 'func', 'type', 'var', 'const']
        let g:deoplete#sources#go#use_cache         = 1
        let g:deoplete#sources#go#package_dot       = 1
    endif


    try
        if exists('g:plugs["vimtex"]') && exists('g:vimtex#re#deoplete')
            let g:deoplete#omni#input_patterns.tex = g:vimtex#re#deoplete
        endif
    catch
        "
    endtry
endfunction

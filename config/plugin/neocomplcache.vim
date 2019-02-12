" ############################################################################
"
"                              Neocomplcache settings
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

if !exists('g:plugs["neocomplcache.vim"]')
    finish
endif

" Use neocomplcache.
let g:neocomplcache_enable_at_startup = 1

" Use smartcase.
let g:neocomplcache_enable_smart_case = 1

" Set minimum syntax keyword length.
let g:neocomplcache_fuzzy_completion_start_length = 1
let g:neocomplcache_enable_fuzzy_completion       = 1
let g:neocomplcache_enable_camel_case_completion  = 1
let g:neocomplcache_min_syntax_length             = 1
let g:neocomplcache_auto_completion_start_length  = 1
let g:neocomplcache_lock_buffer_name_pattern      = '\*ku\*'

let g:neocomplcache_omni_patterns = get(g:,'neocomplcache_omni_patterns',{})

" inoremap <expr><BS> neocomplcache#smart_close_popup()."\<C-h>"
" inoremap <expr><C-h> neocomplcache#smart_close_popup()."\<C-h>"
" inoremap <expr><C-y>  neocomplcache#smart_close_popup()
" inoremap <expr><C-e>  neocomplcache#cancel_popup()

let g:neocomplcache_omni_patterns.python = '[^.[:digit:] *\t]\%(\.\)'
let g:neocomplcache_omni_patterns.c      = '[^.[:digit:] *\t]\%(\.\|->\)'
let g:neocomplcache_omni_patterns.cpp    = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

let g:neocomplcache_filename_include_exts     = get(g:,'neocomplcache_filename_include_exts',{})
let g:neocomplcache_filename_include_exts.cpp = ['', 'h', 'hpp', 'hxx']
let g:neocomplcache_filename_include_exts.c   = ['', 'h']

let g:neocomplcache_delimiter_patterns       = get(g:,'neocomplcache_delimiter_patterns',{})
" let g:neocomplcache_delimiter_patterns.vim = ['#']
let g:neocomplcache_delimiter_patterns.cpp   = ['::']

let g:neocomplcache_sources_list     = get(g:,'neocomplcache_delimiter_patterns',{})
" let g:neocomplcache_sources_list._ = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']

" let g:neocomplcache_sources_list.c      = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
" let g:neocomplcache_sources_list.cpp    = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
" let g:neocomplcache_sources_list.java   = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']
" let g:neocomplcache_sources_list.python = ['omni_complete', 'syntax_complete', 'member_complete', 'filename_complete', 'tags_complete', 'buffer_complete']

if exists('*mkdir')
    if !isdirectory(fnameescape(os#cache() . '/neocomplcache/'))
        call mkdir(fnameescape(os#cache() . '/neocomplcache/'), 'p')
    endif
endif

let g:neocomplcache_temporary_dir = os#cache() .'/neocomplcache/'

" Syntax seems to cause some problems in old Vim's versions ( <= 703 )
if ( has('nvim') || (v:version >= 704) ) && has('autocmd')
    augroup CloseMenu
        autocmd!
        autocmd InsertLeave,CompleteDone * if pumvisible() == 0 | pclose | endif
    augroup end
endif

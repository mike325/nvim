" ############################################################################
"
"                               denite Setttings
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

if !exists('g:plugs["denite.nvim"]')
    finish
endif

if executable('rg') || executable('ag')
    let s:tool = executable('rg') ? 'rg' : 'ag'
    call denite#custom#var('file/rec', 'command', split(FileListTool(s:tool)))

    call denite#custom#var('grep', 'command', split(GrepTool(s:tool, 'grepprg'))[0:0])
    call denite#custom#var('grep', 'default_opts', split(GrepTool(s:tool, 'grepprg'))[1:])
    call denite#custom#var('grep', 'recursive_opts', [])
    call denite#custom#var('grep', 'pattern_opt', [])
    call denite#custom#var('grep', 'separator', ['--'])
    call denite#custom#var('grep', 'final_opts', [])

    unlet s:tool

elseif has('unix')
    call denite#custom#var('file/rec', 'command', ['find', '.', '-type', 'f', '-iname', '*', g:ignore_patterns.find])
elseif WINDOWS()
    let s:ignore = &wildignore . ',.git,.hg,.svn'
    call denite#custom#var('file/rec', 'command', ['scantree.py', '--ignore', s:ignore])
    unlet s:ignore

    if !executable('grep')
        call denite#custom#var('grep', 'command', ['findstr'])
        call denite#custom#var('grep', 'default_opts', ['/p', '/n'])
        call denite#custom#var('grep', 'recursive_opts', ['/s'])
        call denite#custom#var('grep', 'pattern_opt', [])
        call denite#custom#var('grep', 'separator', [])
        call denite#custom#var('grep', 'final_opts', ['*'])
    endif

endif

if executable('git')
    call denite#custom#alias('source', 'file/rec/git', 'file/rec')
    call denite#custom#var('file/rec/git', 'command', split(FileListTool('git')))

    nnoremap <silent> <C-p>  :<C-u>Denite <C-r>=finddir('.git', ';') != '' ? 'file/rec/git' : '-resume file/rec'<CR><CR>
    nnoremap <silent> g<C-p> :<C-u>Denite <C-r>=finddir('.git', ';') != '' ? 'file/rec/git' : 'file/rec'<CR><CR>

    call denite#custom#alias('source', 'grep/git', 'grep')
    call denite#custom#var('grep/git', 'command', split(GrepTool('git', 'grepprg'))[0:2])
    call denite#custom#var('grep/git', 'default_opts', split(GrepTool('git',  'grepprg'))[3:])
    call denite#custom#var('grep/git', 'recursive_opts', [])
    call denite#custom#var('grep/git', 'pattern_opt', [])
    call denite#custom#var('grep/git', 'separator', [])
    call denite#custom#var('grep/git', 'final_opts', [])

    nnoremap <silent> <C-g>  :<C-u>Denite <C-r>=finddir('.git', ';') != '' ? '-resume grep/git' : '-resume grep'<CR><CR>
    nnoremap <silent> g<C-g> :<C-u>Denite <C-r>=finddir('.git', ';') != '' ? 'grep/git' : 'grep'<CR><CR>

else
    nnoremap <silent> g<C-p> :<C-u>Denite file/rec<CR>
    nnoremap <silent> <C-p>  :<C-u>Denite -resume file/rec<CR>
    nnoremap <silent> <C-g>  :<C-u>Denite -resume -no-empty grep<CR>
    nnoremap <silent> g<C-g> :<C-u>Denite -no-empty grep<CR>
endif

" Default mappigns search for macros, but tags are already faster and more accurate
nnoremap ]d :Denite -resume -cursor-pos=+1 -immediately<CR>
nnoremap [d :Denite -resume -cursor-pos=-1 -immediately<CR>

nnoremap [D :Denite -resume -cursor-pos=0 -immediately<CR>
nnoremap ]D :Denite -resume -cursor-pos=$ -immediately<CR>

" Change matchers.
" call denite#custom#source('file/rec', 'matchers', ['matcher/cpsm'])

" Change sorters.
call denite#custom#source('file/rec', 'sorters', ['sorter/sublime'])

" Default
" call denite#custom#source('file/rec', 'sorters', ['sorter/rank'])

" Change default prompt
call denite#custom#option('default', 'prompt', 'Mike >')

" Change ignore_globs
" call denite#custom#filter('matcher/ignore_globs', 'ignore_globs',
"         \ [ '.git/', '.ropeproject/', '__pycache__/',
"         \   'venv/', 'images/', '*.min.*', 'img/', 'fonts/'])

call denite#custom#map(
        \ 'insert',
        \ '<C-j>',
        \ '<denite:move_to_next_line>',
        \ 'noremap'
        \)

call denite#custom#map(
        \ 'insert',
        \ '<C-k>',
        \ '<denite:move_to_previous_line>',
        \ 'noremap'
        \)

call denite#custom#map(
        \ 'normal',
        \ 'a',
        \ '<denite:do_action:add>',
        \ 'noremap'
        \)

call denite#custom#map(
        \ 'normal',
        \ 'd',
        \ '<denite:do_action:delete>',
        \ 'noremap'
        \)

call denite#custom#map(
        \ 'normal',
        \ 'r',
        \ '<denite:do_action:reset>',
        \ 'noremap'
        \)

call denite#custom#map(
    \ 'normal',
    \ '<C-a>',
    \ '<denite:multiple_mappings:denite:toggle_select_all,denite:do_action:quickfix>',
    \ 'noremap')

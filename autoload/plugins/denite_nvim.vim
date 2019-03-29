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

function! plugins#denite_nvim#denitebuffer(prefix) abort
    let l:name = fnamemodify(fnamemodify(getcwd(), ':r'), ':t')
    return (empty(a:prefix) ? l:name : a:prefix . l:name)
endfunction

function! plugins#denite_nvim#init(data) abort
    if !exists('g:plugs["denite.nvim"]')
        return -1
    endif

    try
        " Change default prompt
        call denite#custom#option('default', 'prompt', 'Mike >')
    catch E117
        return -1
    endtry

    if executable('fd')
        call denite#custom#var('file/rec', 'command', split(tools#filelist('fd')))
    elseif executable('rg') || executable('ag')
        let l:tool = executable('rg') ? 'rg' : 'ag'
        call denite#custom#var('file/rec', 'command', split(tools#filelist(l:tool)))
    elseif os#name('linux')
        call denite#custom#var('file/rec', 'command', ['find', '.', '-type', 'f', '-iname', '*'])
    elseif os#name('windows')
        let l:ignore = &wildignore . ',.git,.hg,.svn'
        call denite#custom#var('file/rec', 'command', ['scantree.py', '--ignore', l:ignore])
    endif

    if executable('rg') || executable('ag')
        let l:tool = executable('rg') ? 'rg' : 'ag'
        call denite#custom#var('grep', 'command', split(tools#grep(l:tool, 'grepprg'))[0:0])
        call denite#custom#var('grep', 'default_opts', split(tools#grep(l:tool, 'grepprg'))[1:])
        call denite#custom#var('grep', 'recursive_opts', [])
        call denite#custom#var('grep', 'pattern_opt', [])
        call denite#custom#var('grep', 'separator', ['--'])
        call denite#custom#var('grep', 'final_opts', [])
    elseif os#name('linux')
        call denite#custom#var('grep', 'command', split(tools#grep('grep', 'grepprg'))[0:0])
        call denite#custom#var('grep', 'default_opts', split(tools#grep('grep', 'grepprg'))[1:])
        call denite#custom#var('grep', 'recursive_opts', ['-r'])
        call denite#custom#var('grep', 'pattern_opt', ['-e'])
        call denite#custom#var('grep', 'separator', ['--'])
        call denite#custom#var('grep', 'final_opts', [])
    elseif os#name('windows') && !executable('grep')
        call denite#custom#var('grep', 'command', ['findstr'])
        call denite#custom#var('grep', 'default_opts', ['/p', '/n'])
        call denite#custom#var('grep', 'recursive_opts', ['/s'])
        call denite#custom#var('grep', 'pattern_opt', [])
        call denite#custom#var('grep', 'separator', [])
        call denite#custom#var('grep', 'final_opts', ['*'])
    endif

    if executable('git')
        call denite#custom#alias('source', 'file/rec/git', 'file/rec')
        call denite#custom#var('file/rec/git', 'command', split(tools#filelist('git')))

        call denite#custom#alias('source', 'grep/git', 'grep')
        call denite#custom#var('grep/git', 'command', split(tools#grep('git', 'grepprg'))[0:2])
        call denite#custom#var('grep/git', 'default_opts', split(tools#grep('git',  'grepprg'))[3:])
        call denite#custom#var('grep/git', 'recursive_opts', [])
        call denite#custom#var('grep/git', 'pattern_opt', [])
        call denite#custom#var('grep/git', 'separator', [])
        call denite#custom#var('grep/git', 'final_opts', [])

        nnoremap <silent> <C-p>  :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='Files >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('files_')<CR> <C-r>=finddir('.git', ';') != '' ? 'file/rec/git' : '-resume file/rec'<CR><CR>
        nnoremap <silent> g<C-p> :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='Files >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('files_')<CR> <C-r>=finddir('.git', ';') != '' ? 'file/rec/git' : 'file/rec'<CR><CR>

        nnoremap <silent> <C-g>  :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -mode=normal -no-empty -prompt='Grep >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> <C-r>=finddir('.git', ';') != '' ? 'grep/git' : 'grep'<CR><CR>
        nnoremap <silent> g<C-g> :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -mode=normal -no-empty -prompt='Grep >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> <C-r>=finddir('.git', ';') != '' ? 'grep/git' : 'grep'<CR>:::<C-r>=expand('<cword>')<CR><CR>
    else
        nnoremap <silent> g<C-p> :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='Files >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('files_')<CR> file/rec<CR>
        nnoremap <silent> <C-p>  :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -prompt='Files >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('files_')<CR> -resume file/rec<CR>

        nnoremap <silent> <C-g>  :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -mode=normal -prompt='Grep >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -no-empty grep<CR>
        nnoremap <silent> g<C-g> :<C-u>Denite -highlight-mode-insert=off -highlight-matched-range=off -mode=normal -prompt='Grep >' -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -no-empty grep:::<C-r>=expand('<cword>')<CR><CR>
    endif

    " Default mappigns search for macros, but tags are already faster and more accurate
    nnoremap ]d :<C-u>Denite -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -resume -cursor-pos=+1 -immediately<CR>
    nnoremap [d :<C-u>Denite -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -resume -cursor-pos=-1 -immediately<CR>

    nnoremap [D :<C-u>Denite -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -resume -cursor-pos=0 -immediately<CR>
    nnoremap ]D :<C-u>Denite -buffer-name=<C-r>=plugins#denite_nvim#denitebuffer('grep_')<CR> -resume -cursor-pos=$ -immediately<CR>


    nnoremap <silent> <C-b> :<C-u>Denite -prompt='Buffers >' -buffer-name='Buffers' buffer<CR>

    command! Oldfiles Denite -prompt='Oldfiles >' -buffer-name='Oldfiles' file/old

    if exists('g:plugs["fruzzy"]')
        let g:fruzzy#usenative = 1
        call denite#custom#source('_', 'matchers', ['matcher/fruzzy'])
    endif

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

    " call denite#custom#map(
    "     \ 'normal',
    "     \ '<C-a>',
    "     \ '<denite:multiple_mappings:denite:toggle_select_all,denite:do_action:quickfix>',
    "     \ 'noremap')

    call denite#custom#map(
        \ 'normal',
        \ '<C-a>',
        \ '<denite:multiple_mappings:denite:toggle_select_all,denite:do_action:quickfix>',
        \ 'noremap')

    if exists('g:plugs["projectile.nvim"]')

        let g:projectile#data_dir =  vars#home() . '/cache/projectile'

        let g:projectile#enabled = 1

        let g:projectile#directory_command = has('nvim') ? 'tcd ' : 'cd '

        if executable('rg')
            let g:projectile#search_prog = 'rg'
        elseif executable('ag')
            let g:projectile#search_prog = 'ag'
        elseif os#name('windows') && !executable('grep')
            let g:projectile#search_prog = 'findstr'
        endif

        let g:projectile#todo_terms =  [
            \  'TODO',
            \  'WARN',
            \  'FIXME',
            \  'HACK',
            \  'NOTE',
            \ ]
    endif

endfunction

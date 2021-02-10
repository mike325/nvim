scriptencoding 'utf-8'
" Neomake settings
" github.com/mike325/.vim

if !has#plugin('neomake') || exists('g:config_neomake')
    finish
endif

let g:config_neomake = 1

" let g:neomake_ft_maker_remove_invalid_entries = 1

let g:neomake_error_sign = {
    \ 'text': tools#get_icon('error'),
    \ 'texthl': 'NeomakeErrorSign',
    \ }
let g:neomake_warning_sign = {
    \ 'text': tools#get_icon('warn'),
    \ 'texthl': 'NeomakeWarningSign',
    \ }
let g:neomake_info_sign = {
    \ 'text': tools#get_icon('info'),
    \ 'texthl': 'NeomakeInfoSign'
    \ }
let g:neomake_message_sign = {
    \ 'text': tools#get_icon('message'),
    \   'texthl': 'NeomakeMessageSign',
    \ }

" Don't show the location list, silently run Neomake
let g:neomake_open_list = 0

if has('nvim-0.3.2')
    let g:neomake_echo_current_error = 0
    let g:neomake_virtualtext_current_error = 1
    let g:neomake_virtualtext_prefix = tools#get_icon('virtual_text').' '
endif

function! plugins#neomake#makeprg() abort
    if empty(&makeprg)
        return
    endif
    let l:ft = &filetype
    let l:makeprg = map(split(&makeprg, ' '), {key, val -> substitute(val, '^%$', '%t', 'g') })
    let l:executable = l:makeprg[0]
    let l:args = l:makeprg[1:]
    let l:name = plugins#convert_name(l:executable)

    let b:neomake_{l:ft}_enabled_makers = [l:name]
    let b:neomake_{l:ft}_{l:name}_maker = {
        \   'exe': l:executable,
        \   'args': l:args,
        \   'errorformat': !empty(&l:errorformat) ? &l:errorformat : &errorformat,
        \}
endfunction

augroup NeomakeConfig
    autocmd!
    autocmd OptionSet makeprg call plugins#neomake#makeprg()
augroup end

if os#name('windows')
    let s:triggers = [
        \ {
        \   'InsertLeave': {},
        \   'BufWinEnter': {},
        \   'BufWritePost': {'delay': 0},
        \ },
        \ 500
        \]
else
    let s:triggers = ['nrw', 200]
endif

if v:vim_did_enter
    silent! call neomake#configure#automake(s:triggers[0], s:triggers[1])
else
    augroup NeomakeConfig
        autocmd VimEnter * silent! call neomake#configure#automake(s:triggers[0], s:triggers[1])
    augroup end
endif

" Grepper settings
" github.com/mike325/.vim

function! plugins#vim_grepper#init(data) abort
    if !exists('g:plugs["vim-grepper"]')
        return -1
    endif

    " You can use <TAB> to change the current grep tool
    nnoremap <C-g> :Grepper<CR>

    command! Todo :Grepper -query '\(TODO\|FIXME\)'

    " Motions for grepper command
    nmap gs  <plug>(GrepperOperator)
    xmap gs  <plug>(GrepperOperator)

    let g:grepper               = {} " initialize g:grepper with empty dictionary
    let g:grepper.open          = 0  " We now use CtrlP plugin to look for the matches inside quickfix
    let g:grepper.jump          = 0
    let g:grepper.switch        = 0
    let g:grepper.highlight     = 1
    let g:grepper.simple_prompt = 1
    let g:grepper.tools         = []
    let g:grepper.repo          = ['.git', '.hg', '.svn'] " This is already the default
    let g:grepper.dir           = 'repo,filecwd'
    let g:grepper.prompt_quote  = 0

    let g:grepper.operator               = {}
    let g:grepper.operator.open          = 0 " We now use CtrlP plugin to look for the matches inside quickfix
    let g:grepper.operator.jump          = 0
    let g:grepper.operator.switch        = 0
    let g:grepper.operator.highlight     = 1
    let g:grepper.operator.simple_prompt = 1
    let g:grepper.operator.tools         = []
    let g:grepper.operator.repo          = ['.git', '.hg', '.svn'] " This is already the default
    let g:grepper.operator.dir           = 'repo,filecwd'
    let g:grepper.operator.prompt_quote  = 0

    if executable('git')
        let g:grepper.tools += ['git']
        " I like to search ignore case when greppper is call from <C-g>
        let g:grepper.git = {
            \ 'grepprg':    tools#grep('git', 'grepprg'),
            \ 'grepformat': tools#grep('git', 'grepformat'),
            \ 'escape':     '\^$.*[]',
            \ }

        let g:grepper.operator.tools += ['git']
        let g:grepper.operator.git = {
            \ 'grepprg':    tools#grep('git', 'grepprg'),
            \ 'grepformat': tools#grep('git', 'grepformat'),
            \ 'escape':     '\^$.*[]',
            \ }
    endif

    if executable('rg')
        let g:grepper.tools += ['rg']
        let g:grepper.rg = {
            \ 'grepprg':    tools#grep('rg', 'grepprg') ,
            \ 'grepformat': tools#grep('rg', 'grepformat'),
            \ 'escape':     '\^$.*+?()[]{}|',
            \ }

        let g:grepper.operator.tools += ['rg']
        let g:grepper.operator.rg = g:grepper.rg
    endif

    if executable('ag')
        let g:grepper.tools += ['ag']
        let g:grepper.ag = {
            \ 'grepprg':    tools#grep('ag', 'grepprg'),
            \ 'grepformat': tools#grep('ag', 'grepformat'),
            \ 'escape':     '\^$.*+?()[]{}|',
            \ }

        let g:grepper.operator.tools += ['ag']
        let g:grepper.operator.ag = g:grepper.ag
    endif

    if executable('grep')
        let g:grepper.tools += ['grep']
        let g:grepper.grep = {
            \ 'grepprg':    tools#grep('grep', 'grepprg') . ' -r $*',
            \ 'grepprgbuf': tools#grep('grep', 'grepprg') . ' -- $* $.',
            \ 'grepformat': tools#grep('grep', 'grepformat'),
            \ 'escape':     '\^$.*[]',
            \ }

        let g:grepper.operator.tools += ['grep']
        let g:grepper.operator.grep = g:grepper.grep
    endif


    if executable('findstr')
        let g:grepper.tools += ['findstr']
        let g:grepper.findstr = {
            \ 'grepprg': 'findstr -rspnc:$* *',
            \ 'grepprgbuf': 'findstr -rpnc:$* $.',
            \ 'grepformat': tools#grep('findstr', 'grepformat'),
            \ 'wordanchors': ['\<', '\>'],
            \ }

        let g:grepper.operator.tools += ['findstr']
        let g:grepper.operator.findstr = {
            \ 'grepprg': tools#grep('findstr', 'grepprg') . '/c:$* *',
            \ 'grepprgbuf': 'findstr -rpnc:$* $.',
            \ 'grepformat': tools#grep('findstr', 'grepformat'),
            \ 'wordanchors': ['\<', '\>'],
            \ }
    endif

endfunction

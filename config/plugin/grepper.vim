" ############################################################################
"
"                                Grepper settings
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

if !exists('g:plugs["vim-grepper"]')
    finish
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
let g:grepper.tools         = [] " may add rg
let g:grepper.repo          = ['.git', '.hg', '.svn'] " This is already the default
let g:grepper.dir           = 'repo,filecwd'
let g:grepper.prompt_quote  = 0

let g:grepper.operator               = {}
let g:grepper.operator.open          = 0 " We now use CtrlP plugin to look for the matches inside quickfix
let g:grepper.operator.jump          = 0
let g:grepper.operator.switch        = 0
let g:grepper.operator.highlight     = 1
let g:grepper.operator.simple_prompt = 1
let g:grepper.operator.tools         = [] " may add rg
let g:grepper.operator.repo          = ['.git', '.hg', '.svn'] " This is already the default
let g:grepper.operator.dir           = 'repo,filecwd'
let g:grepper.operator.prompt_quote  = 0

" let g:grepper.highlight = 1
" let g:grepper.rg.grepprg .= ' --smart-case'

" let g:grepper.tools = ['git', 'ag', 'ack', 'grep', 'findstr'] " may add rg

if executable("git")
    let g:grepper.tools += ['git']
    " I like to search ignore case when greppper is call from <C-g>
    let g:grepper.git = {
        \ 'grepprg':    'git grep -inI',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }

    let g:grepper.operator.tools += ['git']
    let g:grepper.operator.git = {
        \ 'grepprg':    'git grep -nwI',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }
endif

" I like to keep Ag and grep as a ignore case searchers (smart case for Ag)
" and git as a case sensitive project searcher
if executable("ag")
    let g:grepper.tools += ['ag']
    let g:grepper.ag = {
        \ 'grepprg':    'ag -S -U --hidden ' . g:ignore_patterns.ag,
        \ 'grepformat': '%f:%l:%c:%m,%f:%l:%m',
        \ 'escape':     '\^$.*+?()[]{}|',
        \ }

    let g:grepper.operator.tools += ['ag']
    let g:grepper.operator.ag = {
        \ 'grepprg':    'ag -S -U --hidden ' . g:ignore_patterns.ag,
        \ 'grepformat': '%f:%l:%c:%m,%f:%l:%m',
        \ 'escape':     '\^$.*+?()[]{}|',
        \ }
endif

if executable("grep")
    let g:grepper.tools += ['grep']
    let g:grepper.grep = {
        \ 'grepprg':    'grep -iRIn '. g:ignore_patterns.grep .' $*',
        \ 'grepprgbuf': 'grep -HIn -- $* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }

    let g:grepper.operator.tools += ['grep']
    let g:grepper.operator.grep = {
        \ 'grepprg':    'grep -oRIn '. g:ignore_patterns.grep .' $*',
        \ 'grepprgbuf': 'grep -HIn -- $* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'escape':     '\^$.*[]',
        \ }
endif


if executable("findstr")
    let g:grepper.tools += ['findstr']
    let g:grepper.findstr = {
        \ 'grepprg': 'findstr -rspnc:$* *',
        \ 'grepprgbuf': 'findstr -rpnc:$* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'wordanchors': ['\<', '\>'],
        \ }

    let g:grepper.operator.tools += ['findstr']
    let g:grepper.operator.findstr = {
        \ 'grepprg': 'findstr -rspnc:$* *',
        \ 'grepprgbuf': 'findstr -rpnc:$* $.',
        \ 'grepformat': '%f:%l:%m',
        \ 'wordanchors': ['\<', '\>'],
        \ }
endif

" FIXME: Crappy windows settings
" Windows cannot handle double quotes inside single quotes without escaping
" if WINDOWS()
"     if executable("ag")
"         let g:grepper.ag.escape += "'\""
"         let g:grepper.operator.ag.escape += "'\""
"     endif
"
"     if executable("grep")
"         let g:grepper.grep.escape += "'\""
"         let g:grepper.operator.grep.escape += "'\""
"     endif
"
"     if executable("git")
"         let g:grepper.git.escape += "'\""
"         let g:grepper.operator.git.escape += "'\""
"     endif
" endif

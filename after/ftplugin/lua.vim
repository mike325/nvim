" lua Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

if has('nvim')
    execute 'setlocal path^=' . luaeval('require"sys".base') . '/lua'
    setlocal suffixesadd^=.lua
    setlocal includeexpr=substitute(v:fname,'\\.','/','g')
endif

if executable('luacheck')
    setlocal makeprg=luacheck\ --std\ luajit\ --formatter\ plain\ %
    let &errorformat='%f:%l:%c: %m'

    if exists('g:plugs["neomake"]')
        call plugins#neomake#makeprg()
    endif
endif

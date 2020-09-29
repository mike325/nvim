" lua Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

let &l:define = '\s*\(local\s\+\)\?\(function\s\+\|\ze\i\+\s*=\s*function\)'

if has('nvim')
    execute 'setlocal path^=' . luaeval('require"sys".base') . '/lua'
    setlocal suffixesadd^=.lua
    setlocal includeexpr=substitute(v:fname,'\\.','/','g')
endif

if executable('luacheck')
    setlocal makeprg=luacheck\ --std\ luajit\ --formatter\ plain\ %
    setlocal errorformat=%f:%l:%c:\ %m

    if has#plugin('neomake')
        call plugins#neomake#makeprg()
    endif
endif

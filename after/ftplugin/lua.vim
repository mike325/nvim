" lua Setttings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal tabstop=4
setlocal softtabstop=-1

if has('nvim')

    execute 'setlocal path^=' . luaeval('require"sys".base') . '/lua'
    setlocal suffixesadd^=.lua
    setlocal includeexpr=substitute(v:fname,'\\.','/','g')

endif

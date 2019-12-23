" lua Setttings
" github.com/mike325/.vim

if has('nvim')

    execute 'setlocal path^=' . luaeval('require"sys".base') . '/lua'
    setlocal suffixesadd^=.lua
    setlocal includeexpr=substitute(v:fname,'\\.','/','g')

endif

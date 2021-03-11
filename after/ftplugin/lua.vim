" lua Settings
" github.com/mike325/.vim

setlocal expandtab
setlocal shiftround
setlocal tabstop=4
setlocal shiftwidth=0
setlocal softtabstop=-1

setlocal suffixesadd^=.lua,init.lua
setlocal includeexpr=substitute(v:fname,'\\.','/','g')

let &l:define = '\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)'

let lua_version = 5
let lua_subversion = 1

let s:luacheck = ''

if has('nvim')
    let s:base = luaeval('require"sys".base')
    let s:cache = luaeval('require"sys".cache')
    let s:luajit = luaeval('require"sys".luajit')

    execute 'setlocal path^=' . s:base . '/lua'
endif

if executable('luacheck')
    let s:luacheck = 'luacheck'
elseif has('nvim') && filereadable(s:cache.'/plenary_hererocks/'.s:luajit.'/bin/luacheck')
    let s:luacheck = s:cache.'/plenary_hererocks/'.s:luajit.'/bin/luacheck'
endif

if s:luacheck !=# ''
    let &l:makeprg = s:luacheck . ' --std luajit --formatter plain %'
    setlocal errorformat=%f:%l:%c:\ %m

    if has#plugin('neomake')
        call plugins#neomake#makeprg()
    endif
endif

function! has#plugin(plugin) abort
    return type(luaeval('require"nvim".plugins[_A]', a:plugin)) == type({})
endfunction

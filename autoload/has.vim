function! has#plugin(plugin) abort
    return type(luaeval('require"neovim".plugins[_A]', a:plugin)) == type({})
endfunction

" Plugins Setttings
" github.com/mike325/.vim

function! plugins#convert_name(name) abort
    let l:name = (a:name =~? '[\.\-]') ? substitute(a:name, '[\.\-]', '_', 'g') : a:name
    let l:name = (l:name =~? '[\+]') ? substitute(l:name, '[\+]', '', 'g') : l:name
    let l:name = substitute(l:name, '.', '\l\0', 'g')
    return l:name
endfunction

function! plugins#settings() abort
    let s:available_configs = map(glob(vars#basedir() . '/autoload/plugins/*.vim', 0, 1), 'fnamemodify(v:val, ":t:r")')

    try
        for [s:name, s:data] in items(filter(deepcopy(g:plugs), 'index(s:available_configs, plugins#convert_name(v:key), 0) != -1'))
            let s:func_name = plugins#convert_name(s:name)
            execute 'runtime! autoload/plugins/' . s:func_name . '.vim'
        endfor
    catch
        call tools#echoerr("Something failed trying to source ".s:func_name.".vim")
    endtry

endfunction

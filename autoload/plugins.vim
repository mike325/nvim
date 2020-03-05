" Plugins Setttings
" github.com/mike325/.vim

function! s:Convert2settings(name) abort
    let l:name = (a:name =~? '[\.\-]') ? substitute(a:name, '[\.\-]', '_', 'g') : a:name
    let l:name = substitute(l:name, '.', '\l\0', 'g')
    return l:name
endfunction

function! plugins#settings() abort
    let s:available_configs = map(glob(vars#basedir() . '/autoload/plugins/*.vim', 0, 1), 'fnamemodify(v:val, ":t:r")')

    try
        for [s:name, s:data] in items(filter(deepcopy(g:plugs), 'index(s:available_configs, s:Convert2settings(v:key), 0) != -1'))
            let s:func_name = s:Convert2settings(s:name)
            execute 'runtime! autoload/plugins/' . s:func_name . '.vim'
        endfor
    catch
        call tools#echoerr('Error trying to read config from ' . s:name)
    endtry
endfunction

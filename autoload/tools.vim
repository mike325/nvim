scriptencoding 'utf-8'
" Tools Setttings
" github.com/mike325/.vim

function! tools#checksize() abort
    " If the size of the file is bigger than ~5MB
    " lets consider it as a log
    return ( getfsize(expand('%')) > 5242880 ) ? 1 : 0
endfunction

if has('nvim-0.5')
    function! tools#getLanguageServer(language) abort
        return v:lua.tools.helpers.get_language_server(a:language)
    endfunction

    function! tools#CheckLanguageServer(...) abort
        return v:lua.tools.helpers.check_language_server(a:000)
    endfunction

    function! tools#grep(tool) abort
        return v:lua.tools.helpers.grep(a:tool)
    endfunction

    function! tools#grep(tool, ...) abort
        return v:lua.tools.helpers.grep(a:tool, a:000)
    endfunction

    function! tools#select_grep(is_git, ...) abort
        return v:lua.tools.helpers.select_grep(a:is_git, a:000)
    endfunction

    function! tools#filelist(tool) abort
        return v:lua.tools.helpers.filelist(a:tool)
    endfunction

    function! tools#select_filelist(is_git) abort
        return v:lua.tools.helpers.select_filelist(a:is_git)
    endfunction

    function! tools#spelllangs(lang) abort
        call v:lua.tools.helpers.spelllang(a:lang)
    endfunction

    function! tools#echoerr(msg) abort
        call v:lua.tools.messages.echoerr(a:msg)
    endfunction

    function! tools#ignores(tool) abort
        return v:lua.tools.helpers.ignores(a:tool)
    endfunction

    function! tools#set_grep(is_git, is_local) abort
        return v:lua.tools.helpers.set_grep(a:is_git, a:is_local)
    endfunction

    finish
endif

let s:gitversion = ''
let s:moderngit = -1

let s:langservers = {
    \ 'python'     : ['pyls', 'jedi-language-server'],
    \ 'c'          : ['clangd', 'ccls', 'cquery'],
    \ 'cpp'        : ['clangd', 'ccls', 'cquery'],
    \ 'cuda'       : ['clangd', 'ccls', 'cquery'],
    \ 'objc'       : ['clangd', 'ccls', 'cquery'],
    \ 'sh'         : ['bash-language-server'],
    \ 'bash'       : ['bash-language-server'],
    \ 'go'         : ['gopls'],
    \ 'latex'      : ['texlab'],
    \ 'tex'        : ['texlab'],
    \ 'bib'        : ['texlab'],
    \ 'vim'        : ['vim-language-server'],
    \ 'dockerfile' : ['docker-langserver'],
    \ 'Dockerfile' : ['docker-langserver'],
    \ }

function! tools#echoerr(msg) abort
    echohl ErrorMsg
    echo a:msg
    echohl
endfunction

" Extracted from tpop's Fugitive plugin
function! tools#GitVersion(...) abort
    if !executable('git')
        return 0
    endif

    if empty(s:gitversion)
        let s:gitversion = matchstr(system('git --version'), "\\S\\+\\ze\n")
    endif

    let l:version = s:gitversion

    if !a:0
        return l:version
    endif

    let l:components = split(l:version, '\D\+')

    for l:i in range(len(a:000))
        if a:000[l:i] > +get(l:components, l:i)
            return 0
        elseif a:000[l:i] < +get(l:components, l:i)
            return 1
        endif
    endfor
    return a:000[l:i] ==# get(l:components, l:i)
endfunction

function! tools#getLanguageServer(language) abort
    if ! tools#CheckLanguageServer(a:language)
        return []
    endif

    let l:cmds = {
        \ 'pyls'   : ['pyls', '--check-parent-process', '--log-file=' . os#tmp('pyls.log')],
        \ 'jedi-language-server' : ['jedi-language-server'],
        \ 'clangd' : [
        \   'clangd',
        \   '--index',
        \   '--background-index',
        \   '--suggest-missing-includes',
        \   '--clang-tidy',
        \   '--header-insertion=iwyu',
        \   '--function-arg-placeholders',
        \   '--log=verbose',
        \ ],
        \ 'ccls'   : [
        \   'ccls',
        \   '--log-file=' . os#tmp('ccls.log'),
        \   '--init={'.
        \       '"cache": {"directory": "' . os#cache() . '/ccls"},'.
        \       '"completion": {"filterAndSort": false},'.
        \       '"highlight": { "lsRanges" : true }'.
        \   '}'
        \ ],
        \ 'cquery' : [
        \   'cquery',
        \   '--log-file=' . os#tmp('cquery.log'),
        \   '--init={'.
        \       '"cache": {"directory": "' . os#cache() . '/cquery"},'.
        \       '"completion": {"filterAndSort": false},'.
        \       '"highlight": { "enabled" : true },'.
        \       '"emitInactiveRegions" : true'.
        \   '}'
        \ ],
        \ 'gopls'  : ['gopls'],
        \ 'texlab' : ['texlab'],
        \ 'bash-language-server': ['bash-language-server', 'start'],
        \ 'vim-language-server' : ['vim-language-server', '--stdio'],
        \ 'docker-langserver'   : ['docker-langserver', '--stdio'],
        \ }

    let l:servers = s:langservers[a:language]
    let l:cmd = []
    for l:server in l:servers
        if executable(l:server)
            let l:cmd = l:cmds[l:server]
            break
        endif
    endfor
    return l:cmd
endfunction

function! tools#CheckLanguageServer(...) abort
    let l:lang = (a:0 > 0) ? a:1 : ''

    if empty(l:lang)
        for [l:language, l:servers] in  items(s:langservers)
            for l:server in l:servers
                if executable(l:server)
                    return 1
                endif
            endfor
        endfor
    else
        let l:servers = get(s:langservers, l:lang, '')
        if !empty(l:servers)
            for l:server in l:servers
                if executable(l:server)
                    return 1
                endif
            endfor
        endif
    endif

    return 0
endfunction

function! tools#ignores(tool) abort
    let l:excludes = []

    if has('nvim-0.2') || v:version >= 800 || has#patch('7.4.2044')
        let l:excludes = map(split(copy(&backupskip), ','), {key, val -> substitute(val, '.*', "'\\0'", 'g') })
    endif

    let l:ignores = {
                \ 'fd'       : '',
                \ 'find'     : ' -regextype egrep ',
                \ 'ag'       : '',
                \ 'grep'     : '',
                \ }

    if !empty(l:excludes)
        if executable('ag')
            let l:ignores['ag'] .= ' --ignore ' . join(l:excludes, ' --ignore ' ) . ' '
        endif
        if executable('fd')
            if filereadable(vars#home() . '/.config/git/ignore')
                let l:ignores['fd'] .= ' --ignore-file '. vars#home() .'/.config/git/ignore'
            else
                let l:ignores['fd'] .= ' -E ' . join(l:excludes, ' -E ' ) . ' '
            endif
        endif
        if executable('find')
            let l:ignores['find'] .= ' ! \( -iwholename ' . join(l:excludes, ' -or -iwholename ' ) . ' \) '
        endif
        if executable('grep')
            let l:ignores['grep'] .= ' --exclude=' . join(l:excludes, ' --exclude=' ) . ' '
        endif
    endif

    return has_key(l:ignores, a:tool) ? l:ignores[a:tool] : ''
endfunction

" Small wrap to avoid change code all over the repo
function! tools#grep(tool, ...) abort
    if s:moderngit == -1
        let s:moderngit = tools#GitVersion(2, 19)
    endif

    let l:greplist = {
                \   'git': {
                \       'grepprg': 'git --no-pager grep '.(s:moderngit == 1 ? '--column' : '').' --no-color -Iin ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m',
                \    },
                \   'rg' : {
                \       'grepprg':  'rg -S --hidden --color never --no-search-zip --trim --vimgrep ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'ag' : {
                \       'grepprg': 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '.tools#ignores('ag'),
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'grep' : {
                \       'grepprg': 'grep -RHiIn --color=never ' . tools#ignores('grep') . ' ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \   'findstr' : {
                \       'grepprg': 'findstr -rspn ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m,%f:%l%m,%f  %l%m'
                \   },
                \}

    let l:property = (a:0 > 0) ? a:000[0] : 'grepprg'
    return l:greplist[a:tool][l:property]
endfunction

" Just like GrepTool but for listing files
function! tools#filelist(tool) abort
    let l:filelist = {
                \ 'git'  : 'git --no-pager ls-files -co --exclude-standard',
                \ 'fd'   : 'fd ' . tools#ignores('fd') . ' --type f --hidden --follow --color never . .',
                \ 'rg'   : 'rg --color never --no-search-zip --hidden --trim --files',
                \ 'ag'   : 'ag -l --follow --nocolor --nogroup --hidden ' . tools#ignores('ag'). '-g ""',
                \ 'find' : "find . -type f -iname '*' ".tools#ignores('find'),
                \}

    return l:filelist[a:tool]
endfunction

" Small wrap to avoid change code all over the repo
function! tools#select_grep(is_git, ...) abort
    let l:grepprg = ''
    let l:property = (a:0 > 0) ? a:000[0] : 'grepprg'
    if executable('git') && a:is_git
        let l:grepprg = tools#grep('git', l:property)
    elseif executable('rg')
        let l:grepprg = tools#grep('rg', l:property)
    elseif executable('ag')
        let l:grepprg = tools#grep('ag', l:property)
    elseif executable('grep')
        let l:grepprg = tools#grep('grep', l:property)
    elseif os#name('windows')
        let l:grepprg = tools#grep('findstr', l:property)
    endif

    return l:grepprg
endfunction

function! tools#set_grep(is_git, is_local) abort
    if a:is_local
        let &l:grepprg = tools#select_grep(a:is_git)
    else
        let &grepprg = tools#select_grep(a:is_git)
    endif
    let &grepformat = tools#select_grep(a:is_git, 'grepformat')
endfunction

function! tools#select_filelist(is_git, ...) abort
    let l:filelist = ''
    if executable('git') && a:is_git
        let l:filelist = tools#filelist('git')
    elseif executable('fd')
        let l:filelist = tools#filelist('fd')
    elseif executable('rg')
        let l:filelist = tools#filelist('rg')
    elseif executable('ag')
        let l:filelist = tools#filelist('ag')
    elseif os#name('unix')
        let l:filelist = tools#filelist('find')
    endif

    return l:filelist
endfunction

function! tools#abolish(lang) abort
    let l:abolish_lang = {}

    " WARN: This is already obsolete and may become out of sync with
    "       abbreviations in lua file
    "
    " TODO: consider take this out to a json file to simplify portability
    let l:abolish_lang['en'] = {
        \ 'flase'                                        : 'false',
        \ 'syntaxis'                                     : 'syntax',
        \ 'developement'                                 : 'development',
        \ 'identation'                                   : 'indentation',
        \ 'aligment'                                     : 'aliment',
        \ 'posible'                                      : 'possible',
        \ 'reproducable'                                 : 'reproducible',
        \ 'retreive'                                     : 'retrieve',
        \ 'compeletly'                                   : 'completely',
        \ 'movil'                                        : 'mobil',
        \ 'pro{j,y}ect{o}'                               : 'project',
        \ 'imr{pov,pvo}e'                                : 'improve',
        \ 'enviroment{,s}'                               : 'environment{}',
        \ 'sustition{,s}'                                : 'substitution{}',
        \ 'sustitution{,s}'                              : 'substitution{}',
        \ 'aibbreviation{,s}'                            : 'abbreviation{}',
        \ 'abbrevation{,s}'                              : 'abbreviation{}',
        \ 'avalib{ility,le}'                             : 'availab{ility,le}',
        \ 'seting{,s}'                                   : 'setting{}',
        \ 'settign{,s}'                                  : 'setting{}',
        \ 'subtitution{,s}'                              : 'substitution{}',
        \ '{despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}' : '{despe,sepa}rat{}',
        \ '{,in}consistant{,ly}'                         : '{}consistent{}',
        \ 'lan{gauge,gue,guege,guegae,ague,agueg}'       : 'language',
        \ 'delimeter{,s}'                                : 'delimiter{}',
        \ '{,non}existan{ce,t}'                          : '{}existen{}',
        \ 'd{e,i}screp{e,a}nc{y,ies}'                    : 'd{i}screp{a}nc{}',
        \ '{,un}nec{ce,ces,e}sar{y,ily}'                 : '{}nec{es}sar{}',
        \ 'persistan{ce,t,tly}'                          : 'persisten{}',
        \ '{,ir}releven{ce,cy,t,tly}'                    : '{}relevan{}',
        \ 'cal{a,e}nder{,s}'                             : 'cal{e}ndar{}'
        \ }

    let l:abolish_lang['es'] = {
        \ 'analisis'                                                            : 'análisis',
        \ 'artifial'                                                            : 'artificial',
        \ 'conexion'                                                            : 'conexión',
        \ 'autonomo'                                                            : 'autónomo',
        \ 'codigo'                                                              : 'código',
        \ 'teoricas'                                                            : 'teóricas',
        \ 'disminicion'                                                         : 'disminución',
        \ 'adminstracion'                                                       : 'administración',
        \ 'relacion'                                                            : 'relación',
        \ 'minimo'                                                              : 'mínimo',
        \ 'area'                                                                : 'área',
        \ 'imagenes'                                                            : 'imágenes',
        \ 'arificiales'                                                         : 'artificiales',
        \ 'actuan'                                                              : 'actúan',
        \ 'basicamente'                                                         : 'básicamente',
        \ 'acuardo'                                                             : 'acuerdo',
        \ 'carateristicas'                                                      : 'características',
        \ 'ademas'                                                              : 'además',
        \ 'asi'                                                                 : 'así',
        \ 'siguente'                                                            : 'siguiente',
        \ 'automatico'                                                          : 'automático',
        \ 'algun'                                                               : 'algún',
        \ 'dia{,s}'                                                             : 'día{}',
        \ 'pre{sici,cisi}on'                                                    : 'precisión',
        \ 'pro{j,y}ect{o}'                                                      : 'proyecto',
        \ 'logic{as,o,os}'                                                      : 'lógic{}',
        \ '{h,f}ernandez'                                                       : '{}ernández',
        \ 'electronico{,s}'                                                     : 'electrónico{}',
        \ 'algorimo{.s}'                                                        : 'algoritmo{}',
        \ 'podria{,n}'                                                          : 'podría{}',
        \ 'metodologia{,s}'                                                     : 'metodología{}',
        \ '{bibliogra}fia'                                                      : '{}fía',
        \ '{reflexi}on'                                                         : '{}ón',
        \ 'mo{b,v}il'                                                           : 'móvil',
        \ '{televi,explo}sion'                                                  : '{}sión',
        \ '{reac,disminu,interac,clasifica,crea,notifica,introduc,justifi}cion' : '{}ción',
        \ '{obten,ora,emo,valora,utilizap,modifica,sec,delimita,informa}cion'   : '{}ción',
        \ '{fun,administra,aplica,rala,aproxima,programa}cion'                  : '{}ción',
        \ }

    let l:current = &l:spelllang
    if has#plugin('vim-abolish') && has#cmd('Abolish') == 2
        if has_key(l:abolish_lang, l:current)
            for [l:key, l:val] in items(l:abolish_lang[l:current])
                execute 'Abolish -delete -buffer ' . l:key
            endfor
        endif
        if has_key(l:abolish_lang, a:lang)
            for [l:key, l:val] in items(l:abolish_lang[a:lang])
                execute 'Abolish -buffer ' . l:key . ' ' . l:val
            endfor
        endif
    else
        " TODO: Fix this crap
        " if has_key(l:abolish_lang, l:current)
        "     for [l:key, l:val] in items(l:abolish_lang[l:current])
        "         if l:key !~# '{\|}' || l:val !~# '{\|}'
        "             silent! execute 'iunabbrev <buffer> ' . l:key
        "             silent! execute 'iunabbrev <buffer> ' . substitute( l:key, '.*', '\U\0', 'g')
        "             silent! execute 'iunabbrev <buffer> ' . substitute( l:key, '^.', '\U\0', 'g')
        "         endif
        "     endfor
        " endif
        " if has_key(l:abolish_lang, a:lang)
        "     execute '!echo "' . string(items(l:abolish_lang[a:lang])) . '" >> echo.log'
        "     for [l:key, l:val] in items(l:abolish_lang[a:lang])
        "         execute '!echo ' . l:key . ' : '.l:val . '>> echo.log'
        "         if l:key !~# '{\|}' || l:val !~# '{\|}'
        "             execute 'iabbrev <buffer> ' . l:key . ' ' . l:val
        "             execute 'iabbrev <buffer> ' . substitute( l:key, '.*', '\U\0', 'g') . ' ' . substitute( l:val, '.*', '\U\0', 'g')
        "             execute 'iabbrev <buffer> ' . substitute( l:key, '^.', '\U\0', 'g') . ' ' . substitute( l:val, '^.', '\U\0', 'g')
        "         endif
        "     endfor
        " endif
    endif
endfunction

function! tools#spelllangs(lang) abort
    call tools#abolish(a:lang)
    execute 'setlocal spelllang='.a:lang
    execute 'setlocal spelllang?'
endfunction

function! tools#oldfiles(arglead, cmdline, cursorpos) abort
    let l:args = split(a:arglead, '\zs')
    let l:pattern = '.*' . join(l:args, '') . '.*'
    let l:candidates = filter(copy(v:oldfiles), 'v:val =~? "' . l:pattern . '"')
    let l:pattern = '.*' . join(l:args, '.*') . '.*'
    let l:candidates += filter(copy(v:oldfiles), 'v:val =~? "' . l:pattern . '"')
    return uniq(l:candidates)
endfunction

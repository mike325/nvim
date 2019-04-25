scriptencoding uft-8
" ############################################################################
"
"                               tools Setttings
"
"                                     -`
"                     ...            .o+`
"                  .+++s+   .h`.    `ooo/
"                 `+++%++  .h+++   `+oooo:
"                 +++o+++ .hhs++. `+oooooo:
"                 +s%%so%.hohhoo'  'oooooo+:
"                 `+ooohs+h+sh++`/:  ++oooo+:
"                  hh+o+hoso+h+`/++++.+++++++:
"                   `+h+++h.+ `/++++++++++++++:
"                            `/+++ooooooooooooo/`
"                           ./ooosssso++osssssso+`
"                          .oossssso-````/osssss::`
"                         -osssssso.      :ssss``to.
"                        :osssssss/  Mike  osssl   +
"                       /ossssssss/   8a   +sssslb
"                     `/ossssso+/:-        -:/+ossss'.-
"                    `+sso+:-`                 `.-/+oso:
"                   `++:.  github.com/mike325/.vim  `-/+/
"                   .`                                 `/
"
" ############################################################################

let s:gitversion = ''
let s:moderngit = -1

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

function! tools#CheckLanguageServer(...) abort
    let l:lang = (a:0 > 0) ? a:1 : ''

    let l:langservers = {
            \ 'python': ['pyls'],
            \ 'c'     : ['ccls', 'cquery', 'clangd'],
            \ 'cpp'   : ['ccls', 'cquery', 'clangd'],
            \ 'cuda'  : ['ccls'],
            \ 'objc'  : ['ccls'],
            \ 'sh'    : ['bash-language-server'],
            \ 'go'    : ['go-langerver'],
            \ }

    if empty(l:lang)
        for [l:language, l:servers] in  items(l:langservers)
            for l:server in l:servers
                if executable(l:server)
                    return 1
                endif
            endfor
        endfor
    else
        let l:servers = get(l:langservers, l:lang, '')
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
    let l:ignores = {
                \ 'git-grep' : '',
                \ 'git-ls'   : '',
                \ 'fd'       : '',
                \ 'find'     : '',
                \ 'rg'       : '',
                \ 'ag'       : '',
                \ 'grep'     : '',
                \ 'findstr'  : '',
                \ }

    let l:exludes = []

    if has('nvim') || v:version >= 800 || has('patch-7.4.2044')
        let l:exludes = map(split(copy(&backupskip), ','), {key, val -> substitute(val, '.*', '"\0"', 'g') })
    endif

    if !empty(l:exludes)
        if executable('ag') && a:tool ==# 'ag'
            let l:ignores['ag'] = ' --ignore ' . join(l:exludes, ' --ignore ' ) . ' '
        elseif executable('fd') && a:tool ==# 'fd'
            let l:ignores['fd'] = ' -E ' . join(l:exludes, ' -E ' ) . ' '
        endif
    endif

    return (exists('l:ignores[a:tool]')) ? l:ignores[a:tool] : ''
endfunction

" Small wrap to avoid change code all over the repo
function! tools#grep(tool, ...) abort
    let l:greplist = {
                \   'git': {
                \       'grepprg': 'git --no-pager grep '.(s:moderngit == 1 ? '--column' : '').' --no-color -Iin ',
                \       'grepformat': (s:moderngit == 1) ? '%f:%l:%c:%m,%f:%l:%m' : '%f:%l:%m',
                \    },
                \   'rg' : {
                \       'grepprg':  'rg -S -n --color never -H --no-search-zip --trim --vimgrep ',
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
                \   },
                \   'ag' : {
                \       'grepprg': 'ag -S --follow --nogroup --nocolor --hidden --vimgrep '.tools#ignores('ag'),
                \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
                \   },
                \   'grep' : {
                \       'grepprg': 'grep -RHiIn --color=never ',
                \       'grepformat': '%f:%l:%m'
                \   },
                \   'findstr' : {
                \       'grepprg': 'findstr -rspn ' . tools#ignores('findstr') . ' ',
                \       'grepformat': '%f:%l:%m'
                \   },
                \}

    if s:moderngit == -1
        let s:moderngit = 0
        if tools#GitVersion(2, 19)
            let l:greplist.git.grepprg    = 'git --no-pager grep --column --no-color -Iin '
            let l:greplist.git.grepformat = '%f:%l:%c:%m,%f:%l:%m'
            let s:moderngit = 1
        endif
    endif

    let l:properity = (a:0 > 0) ? a:000[0] : 'grepprg'
    return l:greplist[a:tool][l:properity]
endfunction

" Just like GrepTool but for listing files
function! tools#filelist(tool) abort
    let l:filelist = {
                \ 'git'  : 'git --no-pager ls-files -co --exclude-standard',
                \ 'fd'   : 'fd ' . tools#ignores('fd') . ' --type f --hidden --follow --color never . .',
                \ 'rg'   : 'rg --line-number --column --with-filename --color never --no-search-zip --hidden --trim --files',
                \ 'ag'   : 'ag -l --follow --nocolor --nogroup --hidden ' . tools#ignores('ag'). '-g ""',
                \ 'find' : "find . -iname '*'",
                \}

    return l:filelist[a:tool]
endfunction

" Small wrap to avoid change code all over the repo
function! tools#select_grep(is_git, ...) abort
    let l:grepprg = ''
    let l:properity = (a:0 > 0) ? a:000[0] : 'grepprg'
    if executable('git') && a:is_git
        let l:grepprg = tools#grep('git', l:properity)
    elseif executable('rg')
        let l:grepprg = tools#grep('rg', l:properity)
    elseif executable('ag')
        let l:grepprg = tools#grep('ag', l:properity)
    elseif os#name('unix') || ( os#name('windows') && executable('grep'))
        let l:grepprg = tools#grep('grep', l:properity)
    elseif os#name('windows')
        let l:grepprg = tools#grep('findstr', l:properity)
    endif

    return l:grepprg
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

    let l:abolish_lang['en'] = {
        \ 'flase'                                        : 'false',
        \ 'syntaxis'                                     : 'syntax',
        \ 'developement'                                 : 'development',
        \ 'identation'                                   : 'indentation',
        \ 'aligment'                                     : 'aliment',
        \ 'posible'                                      : 'possible',
        \ 'abbrevations'                                 : 'abbreviations',
        \ 'reproducable'                                 : 'reproducible',
        \ 'retreive'                                     : 'retrieve',
        \ 'compeletly'                                   : 'completely',
        \ 'movil'                                        : 'mobil',
        \ 'pro{j,y}ect{o}'                               : 'project',
        \ 'imr{pov,pvo}e'                                : 'improve',
        \ 'enviroment{s}'                                : 'environment{s}',
        \ 'sustition{s}'                                 : 'substitution{s}',
        \ 'sustitution{s}'                               : 'substitution{s}',
        \ 'aibbreviation{s}'                             : 'abbreviation{s}',
        \ 'abbrevation{s}'                               : 'abbreviations',
        \ 'avalib{ility,le}'                             : 'availab{ility,le}',
        \ 'seting{s}'                                    : 'setting{s}',
        \ 'settign{s}'                                   : 'setting{s}',
        \ 'subtitution{s}'                               : 'substitution{s}',
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
        \ 'disminicion'                                                         : 'disminución',
        \ 'autonomo'                                                            : 'autónomo',
        \ 'codigo'                                                              : 'código',
        \ 'teoricas'                                                            : 'teóricas',
        \ 'adminstracion'                                                       : 'administración',
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
        \ 'dia{s}'                                                             : 'día{}',
        \ 'pro{j,y}ect{o}'                                                      : 'proyecto',
        \ 'logic{as,o,os}'                                                      : 'lógic{}',
        \ '{h,f}ernandez'                                                       : '{}ernández',
        \ 'electronico{s}'                                                      : 'electrónico{}',
        \ 'algorimo{s}'                                                         : 'algoritmo{}',
        \ 'p{r}odria{n}'                                                        : 'podría{}',
        \ 'podria{n}'                                                           : 'podría{}',
        \ 'metodologia{s}'                                                      : 'metodología{}',
        \ '{bibliogra}fia'                                                      : '{}fía',
        \ '{reflexi}on'                                                         : '{}ón',
        \ 'mo{b,v}il'                                                           : 'móvil',
        \ '{televi,explo}sion'                                                  : '{}sión',
        \ '{reac,disminu,interac,clasifica,crea,notifica,introduc,justifi}cion' : '{}ción',
        \ '{obten,ora,emo,valora,utilizap,modifica,sec,delimita,informa}cion'   : '{}ción',
        \ '{fun,administra,aplica,rala,aproxima,programa}cion'                  : '{}ción',
        \ }

    let l:current = &spelllang
    if ( exists('g:plugs["vim-abolish"]') && exists(':Abolish') == 2) && l:current !=# a:lang
        if exists('l:abolish_lang[l:current]')
            for [l:key, l:val] in items(l:abolish_lang[l:current])
                execute 'Abolish -delete ' . l:key
            endfor
        endif
        if exists('l:abolish_lang[a:lang]')
            for [l:key, l:val] in items(l:abolish_lang[a:lang])
                execute 'Abolish ' . l:key . ' ' . l:val
            endfor
        endif
    elseif l:current !=# a:lang
        if exists('l:abolish_lang[l:current]')
            for [l:key, l:val] in items(l:abolish_lang[l:current])
                if l:key !~# '{|}'
                    silent! execute 'iunabbrev ' . l:key
                    silent! execute 'iunabbrev ' . substitute( l:key, '.*', '\U\0', 'g')
                    silent! execute 'iunabbrev ' . substitute( l:key, '^.', '\U\0', 'g')
                endif
            endfor
        endif
        if exists('l:abolish_lang[a:lang]')
            for [l:key, l:val] in items(l:abolish_lang[a:lang])
                if l:key !~# '{|}'
                    silent! execute 'iabbrev ' . l:key . ' ' . l:val
                    silent! execute 'iabbrev ' . substitute( l:key, '.*', '\U\0', 'g') . ' ' . substitute( l:val, '.*', '\U\0', 'g')
                    silent! execute 'iabbrev ' . substitute( l:key, '^.', '\U\0', 'g') . ' ' . substitute( l:val, '^.', '\U\0', 'g')
                endif
            endfor
        endif
    endif
endfunction

function! tools#spelllangs(lang) abort
    call tools#abolish(a:lang)
    execute 'set spelllang='.a:lang
    execute 'set spelllang?'
endfunction

function! tools#oldfiles(arglead, cmdline, cursorpos) abort
    let l:args = split(a:arglead, '\zs')
    let l:pattern = '.*' . join(l:args, '') . '.*'
    let l:candidates = filter(copy(v:oldfiles), 'v:val =~? "' . l:pattern . '"')
    let l:pattern = '.*' . join(l:args, '.*') . '.*'
    let l:candidates += filter(copy(v:oldfiles), 'v:val =~? "' . l:pattern . '"')
    return uniq(l:candidates)
endfunction

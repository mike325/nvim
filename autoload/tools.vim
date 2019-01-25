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

" Extracted from tpop's Fugitive plugin
function! tools#GitVersion(...) abort
    if !executable('git')
        return v:false
    endif

    let l:version = matchstr(system('git --version'), "\\S\\+\\ze\n")

    if !a:0
        return l:version
    endif

    let l:components = split(l:version, '\D\+')

    for i in range(len(a:000))
        if a:000[i] > +get(l:components, i)
            return 0
        elseif a:000[i] < +get(l:components, i)
            return 1
        endif
    endfor

    return a:000[i] ==# get(l:components, i)

endfunction

let s:greplist = {
            \   'git': {
            \       'grepprg': 'git --no-pager grep --no-color -Iin ',
            \       'grepformat': '%f:%l:%m'
            \    },
            \   'rg' : {
            \       'grepprg':  'rg -S -n --color never -H --no-search-zip --trim --vimgrep ',
            \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
            \   },
            \   'ag' : {
            \       'grepprg': 'ag -S -l --follow --nogroup --nocolor --hidden --vimgrep ' . vars#ignore_cmd('ag') . ' ',
            \       'grepformat': '%f:%l:%c:%m,%f:%l:%m'
            \   },
            \   'grep' : {
            \       'grepprg': 'grep -HiIn --color=never ' . vars#ignore_cmd('grep') . ' ',
            \       'grepformat': '%f:%l:%m'
            \   },
            \   'findstr' : {
            \       'grepprg': 'findstr -rspn ' . vars#ignore_cmd('findstr') . ' ',
            \       'grepformat': '%f:%l:%m'
            \   },
            \}

if tools#GitVersion(2, 19)
    let s:greplist.git.grepprg    = 'git --no-pager grep --no-color --column -Iin '
    let s:greplist.git.grepformat = '%f:%l:%c:%m,%f:%l:%m'
endif

let s:filelist = {
            \   'git': 'git --no-pager ls-files -co --exclude-standard',
            \   'rg' : 'rg --line-number --column --with-filename --color never --no-search-zip --hidden --trim --files',
            \   'ag' : 'ag -l --follow --nocolor --nogroup --hidden '. vars#ignore_cmd('ag') . ' -g ""',
            \}

if exists('g:plugs["vim-abolish"]')
    let s:lang = {}

    let s:lang['en'] = {
        \ 'avalib{ility,le}'                            : 'availab{ility,le}',
        \ 'seting{s}'                                   : 'setting{s}',
        \ 'settign{s}'                                  : 'setting{s}',
        \ 'subtitution{s}'                              : 'substitution{s}',
        \ 'flase'                                       : 'false',
        \ 'enviroment{s}'                               : 'environment{s}',
        \ 'syntaxis'                                    : 'syntax',
        \ 'developement'                                : 'development',
        \ 'sustition{s}'                                : 'substitution{s}',
        \ 'sustitution{s}'                              : 'substitution{s}',
        \ 'aibbreviation{s}'                            : 'abbreviation{s}',
        \ 'identation'                                  : 'indentation',
        \ 'aligment'                                    : 'aliment',
        \ 'posible'                                     : 'possible',
        \ 'imr{pov,pvo}e'                               : 'improve',
        \ 'abbrevations'                                : 'abbreviations',
        \ 'reproducable'                                : 'reproducible',
        \ 'retreive'                                    : 'retrieve',
        \ 'compeletly'                                  : 'completely',
        \ 'abbrevation{s}'                              : 'abbreviations',
        \ '{despa,sepe}rat{e,es,ed,ing,ely,ion,ions,or}': '{despe,sepa}rat{}',
        \ '{,in}consistant{,ly}'                        : '{}consistent{}',
        \ 'lan{gauge,gue,guege,guegae,ague,agueg}'      : 'language',
        \ 'delimeter{,s}'                               : 'delimiter{}',
        \ '{,non}existan{ce,t}'                         : '{}existen{}',
        \ 'd{e,i}screp{e,a}nc{y,ies}'                   : 'd{i}screp{a}nc{}',
        \ '{,un}nec{ce,ces,e}sar{y,ily}'                : '{}nec{es}sar{}',
        \ 'persistan{ce,t,tly}'                         : 'persisten{}',
        \ '{,ir}releven{ce,cy,t,tly}'                   : '{}relevan{}',
        \ 'cal{a,e}nder{,s}'                            : 'cal{e}ndar{}'
        \ }

    let s:lang['es'] = {
        \ '{h,f}ernandez'                                                     : '{}ernández',
        \ 'analisis'                                                          : 'análisis',
        \ 'electronico{s}'                                                    : 'electrónico{}',
        \ 'artifial'                                                          : 'artificial',
        \ 'algorimo{s}'                                                       : 'algoritmo{}',
        \ 'conexion'                                                          : 'conexión',
        \ 'disminicion'                                                       : 'disminución',
        \ 'p{r}odria{n}'                                                      : 'podría{}',
        \ 'podria{n}'                                                         : 'podría{}',
        \ 'autonomo'                                                          : 'autónomo',
        \ 'codigo'                                                            : 'código',
        \ 'teoricas'                                                          : 'teóricas',
        \ 'metodologia{s}'                                                    : 'metodología{}',
        \ 'adminstracion'                                                     : 'administración',
        \ 'area'                                                              : 'área',
        \ '{reflexi}on'                                                       : '{}ón',
        \ '{televi,explo}sion'                                                : '{}sión',
        \ '{reac,disminu,interac,clasifica,crea,notifica,introdu,justifi}cion': '{}ción',
        \ '{obten,ora,emo,valora,utilizap,modifica,sec,delimita,informa}cion' : '{}ción',
        \ '{administra,aplica,rala}cion'                                      : '{}ción',
        \ }
endif

" Small wrap to avoid change code all over the repo
function! tools#grep(tool, properity) abort
    return s:greplist[a:tool][a:properity]
endfunction

" Just like GrepTool but for listing files
function! tools#filelist(tool) abort
    return s:filelist[a:tool]
endfunction

function! tools#abolish(lang) abort
    let l:current = &spelllang
    if exists('g:plugs["vim-abolish"]') && l:current !=# a:lang
        for [l:key, l:val] in items(s:lang[l:current])
            execute 'Abolish -delete ' . l:key
        endfor
        for [l:key, l:val] in items(s:lang[a:lang])
            execute 'Abolish ' . l:key . ' ' . l:val
        endfor
    endif
endfunction

function! tools#spelllangs(lang) abort
    call tools#abolish(a:lang)
    execute 'set spelllang='.a:lang
    execute 'set spelllang?'
endfunction

function! tools#spells(...) abort
    return ['es', 'en']
endfunction

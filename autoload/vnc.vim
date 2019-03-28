" ############################################################################
"
"                               vnc Setttings
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

let s:vnc_jobs = get(g:, 'vnc#jobs', {})
" let vnc#knowhosts = get(g:, 'host#vnc#knowhosts', {})

function! vnc#CleanVNC(jobid, data, event) abort
    for [l:hostname, l:jobid] in items(s:vnc_jobs)
        if l:jobid == a:jobid
            unlet s:vnc_jobs[l:hostname]
            break
        endif
    endfor
endfunction

function! vnc#StopVNC(hostname) abort
    if has('nvim')
        if index(keys(s:vnc_jobs), a:hostname, 0) != -1
            silent! call jobstop(s:vnc_jobs[a:hostname])
        else
            echomsg 'Host ' . a:hostname . ' is not in use'
        endif
    endif
endfunction

function! vnc#RunVNC(hostname, bang) abort
    let l:host = a:hostname
    try
        let l:host = host#vnc#gethost(a:hostname)
    catch E117
    endtry

    if os#name('windows')
        let l:prg = executable('vncviewer') ? 'vncviewer.exe' :
                                            \ 'C:/Program Files/RealVNC/VNC Viewer/vncviewer.exe'
    else
        throw 'Other Systems ar WIP'
    endif

    let l:cmd = [
        \   l:prg,
        \   '-SingleSignOn',
        \   l:host,
        \ ]
    let l:args = {
        \   'detach': 1,
        \   'on_exit': function('vnc#CleanVNC'),
        \ }

    if has('nvim')
        if empty(s:vnc_jobs) || ( index(keys(s:vnc_jobs), a:hostname, 0) == -1 || a:bang)
            if a:bang && index(keys(s:vnc_jobs), a:hostname, 0) != -1
                call vnc#StopVNC(a:hostname)
            endif
            let s:vnc_jobs[a:hostname] = jobstart(l:cmd, l:args)
        else
            echomsg 'Host ' . a:hostname . ' is already in use'
        endif
    endif
endfunction

function! vnc#VNCSessions(arglead, cmdline, cursorpos) abort
    let l:candidates = keys(s:vnc_jobs)
    if !empty(l:candidates)
        let l:candidates = filter(copy(l:candidates), "v:val =~? join(split(a:arglead, '\zs'), '.*')")
    endif
    return l:candidates
endfunction

function! vnc#KnownHosts(arglead, cmdline, cursorpos) abort
    let l:candidates = []
    try
        let l:hosts = keys(host#vnc#knownhosts())
    catch E117
        let l:hosts = []
    endtry

    if !empty(l:hosts)
        let l:candidates = filter(l:hosts, "v:val =~? join(split(a:arglead, '\zs'), '.*')")
    endif

    return l:candidates
endfunction

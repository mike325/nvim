" ############################################################################
"
"                               plugin Setttings
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

function! plugin#fruzzy(info) abort
    if ( a:info.status ==# 'installed' || a:info.force ) && exists('*fruzzy#install()')
        call fruzzy#install()
    endif
endfunction

function! plugin#ctrlpmatcher(info) abort
    if a:info.status ==# 'installed' || a:info.force
        if os#name() ==# 'windows'
            !./install_windows.bat
        else
            !./install.sh
        endif
    endif
endfunction

" function! plugin#omnisharp(info)
"     if a:info.status == 'installed' || a:info.force
"         if os#name() ==# 'windows'
"             !cd server && msbuild
"         else
"             !cd server && xbuild
"         endif
"     endif
" endfunction

function! plugin#CheckLanguageServer(...) abort
    let l:langservers = {
    \   'python': ['pyls'],
    \   'c'     : ['cquery', 'clangd'],
    \   'cpp'   : ['cquery', 'clangd'],
    \   'go'    : ['go-langerver'],
    \ }

    for [l:language, l:servers] in  items(l:langservers)
        for l:server in l:servers
            if executable(l:server)
                return v:true
            endif
        endfor
    endfor

    return v:false
endfunction

function! plugin#InstallLanguageClient(info) abort
    if os#name() ==# 'windows'
        execute '!powershell -executionpolicy bypass -File ./install.ps1'
    else
        execute '!./install.sh'
    endif
    UpdateRemotePlugins
endfunction


function! plugin#GetGoCompletion(info) abort
    if !executable('gocode')
        if os#name() ==# 'windows'
            !go get -u -ldflags -H=windowsgui github.com/nsf/gocode
        else
            !go get -u github.com/nsf/gocode
        endif
    endif
    make
endfunction

function! plugin#YCM(info) abort
    if a:info.status ==# 'installed' || a:info.force
        " !./install.py --all

        " Since YCM download libclang there's no need to have clang install
        " FIX: ArchLinux users should run this first
        "  # sudo ln -s /lib64/libtinfo.so.6 /lib64/libtinfo.so.5
        "       or use --system-clang
        " https://github.com/Valloric/YouCompleteMe/issues/778#issuecomment-211452969
        let l:code_completion = ' --clang-completer'

        if executable('go') && (!empty($GOROOT))
            let l:code_completion .= ' --gocode-completer'
        endif

        if executable('mono')
            let l:code_completion .= ' --omnisharp-completer'
        endif

        if executable('racer') && executable('cargo')
            let l:code_completion .= ' --rust-completer'
        endif

        if executable('npm') && executable('node')
            let l:code_completion .= ' --js-completer'
        endif

        " TODO: Can't test in windows
        if !os#name() ==# 'windows' && executable('java')
            " JDK8 must be installed
            let l:java = system('java -version')
            if l:java =~# '^java.*"1\.8.*"'
                let l:code_completion .= ' --java-completer'
            endif
        endif

        let l:python = (exists('g:python3_host_prog')) ? g:python3_host_prog : g:python_host_prog

        execute '!' . l:python . ' ./install.py ' . l:code_completion
        " if os#name() ==# 'windows'
        "     execute '!' . l:python . ' ./install.py ' . l:code_completion
        " elseif executable('python3')
        "     " Force python3
        "     execute '!' . l:python . ' ./install.py ' . l:code_completion
        " else
        "     execute '!./install.py ' . l:code_completion
        " endif
    endif
endfunction

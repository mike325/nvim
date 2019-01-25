" ############################################################################
"
"                               vars Setttings
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


let s:ignore_cmd = {
            \   'git' : '',
            \   'ag' : '',
            \   'rg' : '',
            \   'find' : '',
            \   'grep' : '',
            \   'dir' : '',
            \   'findstr' : '',
            \}

let s:ignores_patterns = {
            \   'bin': [ 'exe', 'dat',],
            \   'vcs': [ 'hg', 'svn', 'git',],
            \   'compile' : ['obj', 'class', 'pyc', 'o', 'dll', 'a', 'moc',],
            \   'tmp_dirs': [ 'trash', 'tmp', '__pycache__', 'ropeproject'],
            \   'vim_dirs': [ 'backup', 'swap', 'sessions', 'cache', 'undos',],
            \   'tmp_file' : ['swp', 'bk',],
            \   'docs': ['docx', 'doc', 'xls', 'xlsx', 'odt', 'ppt', 'pptx', 'pdf',],
            \   'image': ['jpg', 'jpeg', 'png', 'gif', 'raw'],
            \   'video': ['mp4', 'mpeg', 'avi', 'mkv', '3gp'],
            \   'logs': ['log',],
            \   'compress': ['zip', 'tar', 'rar', '7z',],
            \   'full_name_files': ['tags', 'cscope', 'shada', 'viminfo', 'COMMIT_EDITMSG'],
            \}

" Set the default work dir
let s:basedir = ''
let s:homedir = ''

function! s:setupdirs() abort
    if !empty(s:homedir) && !empty(s:basedir)
        return
    endif

    if has('nvim')
        if os#name() ==# 'windows'
            let s:basedir = substitute( expand($USERPROFILE), '\', '/', 'g' ) . '/AppData/Local/nvim/'
            let s:homedir = substitute( expand($USERPROFILE), '\', '/', 'g' )
        else
            " TODO: Check $XDG_DATA_HOME
            let s:basedir = expand($HOME) . '/.config/nvim/'
            let s:homedir = expand($HOME)
        endif
    elseif os#name() ==# 'windows'
        " if $USERPROFILE and ~ expansions are different, then gVim may be running as portable
        let s:homedir = substitute( expand($USERPROFILE), '\', '/', 'g' )
        if  substitute( expand($USERPROFILE), '\', '/', 'g' ) ==# substitute( expand('~'), '\', '/', 'g' )
            let s:basedir =  substitute( expand($USERPROFILE), '\', '/', 'g' ) . '/vimfiles/'
        else
            let s:basedir =  substitute( expand('~'), '\', '/', 'g' ) . '/vimfiles/'
        endif
    else
        let s:basedir = expand($HOME) . '/.vim/'
        let s:homedir = expand($HOME)
    endif   " Statements
endfunction

function! vars#ignore_cmd(cmd) abort
    return s:ignore_cmd[a:cmd]
endfunction

function! vars#ignores_patterns() abort
    return s:ignores_patterns
endfunction

function! vars#basedir() abort
    if empty(s:basedir)
        call s:setupdirs()
    endif
    return s:basedir
endfunction

function! vars#home() abort
    if empty(s:homedir)
        call s:setupdirs()
    endif
    return s:homedir
endfunction

function! vars#libclang() abort

    let l:libclang = ''

    if os#name('windows')
        if filereadable(vars#home() . '/.local/bin/libclang.dll')
            let l:libclang = vars#home() . '/.local/bin/libclang.dll'
        elseif exists('g:plugs["YouCompleteMe"]')
            let l:libclang = vars#basedir() . 'plugged/YouCompleteMe/third_party/ycmd/libclang.dll'
        elseif filereadable('c:/Program Files/LLVM/bin/libclang.dll')
            let l:libclang = 'c:/Program Files/LLVM/bin/libclang.dll'
        elseif filereadable('c:/Program Files(x86)/LLVM/bin/libclang.dll')
            let l:libclang = 'c:/Program Files(x86)/LLVM/bin/libclang.dll'
        endif
    else
        if filereadable(vars#home() . '/.local/lib/libclang.so')
            let l:libclang = vars#home() . '/.local/lib/libclang.so'
        elseif exists('g:plugs["YouCompleteMe"]')
            for s:version in ['7', '6', '5', '4', '3']
                if filereadable(vars#basedir() . 'plugged/YouCompleteMe/third_party/ycmd/libclang.so.' . s:version)
                    let l:libclang = vars#basedir() . 'plugged/YouCompleteMe/third_party/ycmd/libclang.so.' . s:version
                    break
                endif
            endfor
            silent! unlet s:version
        endif
        let l:libclang = !empty(l:libclang) ? l:libclang : filereadable('/usr/lib/libclang.so') ? '/usr/lib/libclang.so' : ''
    endif

    return l:libclang
endfunction

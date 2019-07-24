" ############################################################################
"
"                               settings Setttings
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

function! set#initconfigs() abort " Vim's InitConfig {{{
    " Hidden path in `vars#basedir()` with all generated files
    if !exists('*mkdir')
        return
    endif

    let l:parent_dir = vars#datadir()

    if !isdirectory(l:parent_dir)
        call mkdir(fnameescape(l:parent_dir), 'p')
    endif

    let l:dirpaths = {
            \   '/backup' : 'backupdir',
            \   '/swap' : 'directory',
            \   '/undo' : 'undodir',
            \   '/cache' : '',
            \   '/sessions' : '',
            \}

    " Better backup, swap and undos storage
    set backup   " make backup files

    if exists('+undofile')
        set undofile " persistent undos - undo after you re-open the file
    endif

    " Config all
    for [l:dirname, l:dir_setting] in items(l:dirpaths)
        if !isdirectory(fnameescape( l:parent_dir . l:dirname ))
            call mkdir(fnameescape( l:parent_dir . l:dirname ), 'p')
        endif

        if l:dir_setting !=# '' && exists('+' . l:dir_setting)
            execute 'set ' . l:dir_setting . '=' . fnameescape(l:parent_dir . l:dirname)
        endif
    endfor

    let l:persistent_settings = (has('nvim')) ? 'shada' : 'viminfo'

    execute 'set ' . l:persistent_settings . "=!,/1000,'1000,<1000,:1000,s10000,h"
    if l:persistent_settings ==# 'viminfo'
        execute 'set ' . l:persistent_settings . '+=n' . fnameescape(l:parent_dir .'/'. l:persistent_settings)
    endif

    let l:wildignores = [
        \   '*.spl',
        \   '*.aux',
        \   '*.out',
        \   '*.o',
        \   '*.pyc',
        \   '*.gz',
        \   '*.pdf',
        \   '*.sw',
        \   '*.swp',
        \   '*.swap',
        \   '*.com',
        \   '*.exe',
        \   '*.so',
        \   '*/cache/*',
        \   '*/__pycache__/*',
        \ ]

    let l:no_backup = [
        \   '.git/*',
        \   '.svn/*',
        \   '.xml',
        \   '*.log',
        \   '*.bin',
        \   '*.7z',
        \   '*.dmg',
        \   '*.gz',
        \   '*.iso',
        \   '*.jar',
        \   '*.rar',
        \   '*.tar',
        \   '*.zip',
        \   'TAGS',
        \   'tags',
        \   'GTAGS',
        \   'COMMIT_EDITMSG',
        \]

    if os#name('windows') && &shellslash
        let l:wildignores += map(split(&backupskip, ','), 'substitute(v:val, "\\", "/", "g")')
    else
        let l:wildignores += split(&backupskip, ',')
    endif

    let &wildignore = join(l:wildignores, ',')
    let &backupskip = join(l:wildignores + l:no_backup, ',')

endfunction " }}} END Vim's InitConfig

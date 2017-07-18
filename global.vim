" HEADER {{{
"
"                             Small improvements
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
" }}} END HEADER

let g:base_path = ""

" Location of the plugins
if has("nvim")
    if has("win32") || has("win64")
        let g:base_path = '~/AppData/Local/nvim/'
    else
        let g:base_path = '~/.config/nvim/'
    endif
elseif has("win32") || has("win64")
    let g:base_path = '~/vimfiles/'
else
    let g:base_path = '~/.vim/'
endif


function! s:InitConfigs()
    set nocompatible

    " Files and dirs we want to ignore in searches and plugins
    if !exists("g:ignores")
        let g:ignores = [
                    \   "*.pyc",
                    \   "*.class",
                    \   "*.swp",
                    \   "*.moc",
                    \   "*.o",
                    \   "*.obj",
                    \   "*.bin",
                    \   "*.exe",
                    \   "*.log",
                    \   "*.dat",
                    \   "*.dll",
                    \   "*/.git/*",
                    \   "*/.svn/*",
                    \   "*/.hg/*",
                    \   "*/__pycache__/*",
                    \   "*/tmp/*",
                    \   "*trash/*",
                    \]
    endif

    " Hidden path in `g:base_path` with all generated files
    if !exists("g:parent_dir")
        let g:parent_dir = g:base_path . ".vimfiles/"
    endif

    if !exists("g:dirpaths")
        let g:dirpaths = {
                    \   "backup" : "backupdir",
                    \   "swap" : "directory",
                    \   "undo" : "undodir",
                    \   "cache" : "",
                    \   "sessions" : "",
                    \}
    endif

    " Better backup, swap and undos storage
    set backup   " make backup files
    set undofile " persistent undos - undo after you re-open the file

    " Config all
    for [dirname, dir_setting] in g:dirpaths

        if exists("*mkdir")
            if !isdirectory(fnameescape(g:parent_dir . dirname))
                call mkdir(g:parent_dir . dirname, "p")
            endif

            if dir_setting != ""
                execute "set " . dir_setting . "=" . fnameescape(g:parent_dir . dirname)
            endif
        else
            echom "The current dir " . fnameescape(g:parent_dir . dirname) . " could not be created"
        endif

    endfor

    " Set system ignores and skips
    for ignore in g:ignores
        execute "set backupdir+=" . fnameescape(ignore)
        execute "set wildignore+=" . fnameescape(ignore)
    endfor

    let l:persistent_settings = "viminfo"
    if has("nvim")
        let l:persistent_settings = "shada"
    endif

    " Remember things between sessions
    " !        + When included, save and restore global variables that start
    "            with an uppercase letter, and don't contain a lowercase letter.
    " 'n       + Marks will be remembered for the last 'n' files you edited.
    " <n       + Contents of registers (up to 'n' lines each) will be remembered.
    " sn       + Items with contents occupying more then 'n' KiB are skipped.
    " :n       + Save 'n' Command-line history entries
    " n/info   + The name of the file to use is "/info".
    " no /     + Since '/' is not specified, the default will be used, that is,
    "            save all of the search history, and also the previous search and
    "            substitute patterns.
    " no %     + The buffer list will not be saved nor read back.
    " h        + 'hlsearch' highlighting will not be restored.
    execute "set " . l:persistent_settings . "=!,'100,<500,:500,s100,h"
    execute "set " . l:persistent_settings . "+=n" .fnameescape(g:parent_dir . l:persistent_settings)

endfunction

call s:InitConfigs()

" Since we update our runtimepath here, we want to load it before anything else
execute 'source '.fnameescape(g:base_path .'plugins/plugins.vim')

let mapleader=" "

hi CursorLine term=bold cterm=bold guibg=Grey40

let g:netrw_liststyle=3

" Color columns
if exists('+colorcolumn')
    " This works but it tends to slowdown vim with big files
    " let &colorcolumn="80,".join(range(120,999),",")
    " Visual ruler
    let &colorcolumn="80"
endif

" Load special host configurations
" if filereadable(expand(fnameescape(g:os_editor.'extras.vim')))
"     execute 'source '.fnameescape(g:os_editor.'extras.vim')
" endif

scriptencoding utf-8
" ############################################################################
"
"                               autocmd Setttings
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

function! autocmd#CleanFile() abort
    " Sometimes we don't want to remove spaces
    let l:buftypes = 'nofile\|help\|quickfix\|terminal'
    let l:filetypes = 'bin\|hex\|log\|git\|man\|terminal'

    if b:trim != 1 || &buftype =~? l:buftypes || &filetype ==? l:filetypes || &filetype ==? ''
        return
    endif

    "Save last cursor position
    let l:savepos = getpos('.')
    " Save last search query
    let l:oldquery = getreg('/')

    " Cleaning line endings
    execute '%s/\s\+$//e'
    call histdel('search', -1)

    " Yep I some times I copy this things form the terminal
    silent! execute '%s/\(\s\+\)┊/\1 /ge'
    call histdel('search', -1)

    if &fileformat ==# 'unix'
        silent! execute '%s/\r$//ge'
        call histdel('search', -1)
    endif

    " Config dosini files must trim leading spaces
    if &filetype ==# 'dosini'
        silent! execute '%s/^\s\+//e'
        call histdel('search', -1)
    endif


    call setpos('.', l:savepos)
    call setreg('/', l:oldquery)
endfunction

function! autocmd#FileName(...) abort

    let l:file_name = expand('%:t:r')
    let l:extension = expand('%:e')

    let l:template = (a:0 > 0) ? a:1 : ''

    let l:skeletons_path = vars#basedir(). '/skeletons/'

    if !empty(l:template)
        let l:skeleton = fnameescape(l:skeletons_path . l:template)
    else
        let l:skeleton = fnameescape(l:skeletons_path . '/skeleton.' . l:extension)
        if l:file_name =~# '^main$' && filereadable(fnameescape(l:skeletons_path . l:file_name . '.' . l:extension))
            let l:skeleton = fnameescape(l:skeletons_path . l:file_name . '.' . l:extension)
        endif
    endif

    if filereadable(l:skeleton)
        execute '0r '. l:skeleton
        silent! execute '%s/\<NAME\>/'.l:file_name.'/e'
        call histdel('search', -1)
        silent! execute '%s/\<NAME\ze_H\(PP\)\?\>/\U'.l:file_name.'/g'
        call histdel('search', -1)
        execute 'bwipeout! #'
    endif

endfunction

function! autocmd#FindProjectRoot(file) abort
    let l:root = ''
    let l:project_root = ''
    let l:markers = ['.git', '.svn', '.hg']

    if exists('g:plugs["vim-fugitive"]') && exists('*fugitive#extract_git_dir')
        let l:root = fugitive#extract_git_dir(fnamemodify(a:file, ':p'))
        if empty(l:root)
            let l:markers = ['.svn', '.hg']
        endif
    endif

    if empty(l:root)
        let l:cwd = fnamemodify(a:file, ':h')
        for l:dir in l:markers
            let l:root = finddir(l:dir, l:cwd.';')
            if !empty(l:root)
                let l:project_root = fnamemodify(l:dir, ':p:h')
                break
            endif
        endfor
    endif

    return l:project_root
endfunction

function! autocmd#IsGitRepo(root) abort
    return (isdirectory(a:root . '/.git') || filereadable(a:root . '/.git'))
endfunction

function! autocmd#SetProjectConfigs() abort
    let l:project_root =  autocmd#FindProjectRoot(expand('%:p'))
    if !empty(l:project_root)
        let l:project_root = fnamemodify(l:project_root, ':h')

        if filereadable(l:project_root . '/project.vim')
            try
                execute 'source '. l:project_root . '/project.vim'
            catch /.*/
                if !has#gui()
                    echoerr 'There were errors with the project file in ' . l:project_root . '/project.vim'
                endif
            endtry
        endif

        if exists('g:plugs["ultisnips"]')
            command! UltiSnipsDir call mkdir(l:project_root . '/UltiSnips', 'p')

            let g:UltiSnipsSnippetsDir        = l:project_root . '/UltiSnips'
            let g:UltiSnipsSnippetDirectories = [
                        \   l:project_root . '/UltiSnips',
                        \   vars#basedir() . 'config/UltiSnips',
                        \   'UltiSnips'
                        \]
        endif

        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = 1
        endif

        if exists('g:plugs["projectile.nvim"]')
            if executable('git') && autocmd#IsGitRepo(l:project_root)
                let g:projectile#search_prog = 'git grep'
            elseif executable('ag')
                let g:projectile#search_prog = 'ag'
            elseif has('unix')
                let g:projectile#search_prog = 'grep'
            elseif os#name('windows') && !executable('grep')
                let g:projectile#search_prog = 'findstr '
            endif
        endif

        if exists('g:plugs["deoplete.nvim"]') && ( exists('g:plugs["deoplete-clang"]') || exists('g:plugs["deoplete-clang2"]') )
            if filereadable(l:project_root . '/compile_commands.json')
                let g:deoplete#sources#clang#clang_complete_database = l:project_root
            else
                if exists('g:deoplete#sources#clang#clang_complete_database')
                    unlet g:deoplete#sources#clang#clang_complete_database
                endif
            endif
        endif

        " If we don't have grepper variable, we have not done :PlugInstall
        if exists('g:plugs["vim-grepper"]') && exists('g:grepper')
            let g:grepper.tools = []
            let g:grepper.operator.tools = []

            if executable('git') && autocmd#IsGitRepo(l:project_root)
                let g:grepper.tools += ['git']
                let g:grepper.operator.tools += ['git']
            endif

            if executable('rg')
                let g:grepper.tools += ['rg']
                let g:grepper.operator.tools += ['rg']
            endif
            if executable('ag')
                let g:grepper.tools += ['ag']
                let g:grepper.operator.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
                let g:grepper.operator.tools += ['grep']
            endif
            if executable('findstr')
                let g:grepper.tools += ['findstr']
                let g:grepper.operator.tools += ['findstr']
            endif
        else
            if executable('git') && autocmd#IsGitRepo(l:project_root)
                let &grepprg = tools#grep('git', 'grepprg')
            elseif executable('rg')
                let &grepprg = tools#grep('rg', 'grepprg')
            elseif executable('ag')
                let &grepprg = tools#grep('ag', 'grepprg')
            elseif executable('grep')
                let &grepprg = tools#grep('grep', 'grepprg')
            elseif executable('findstr')
                let &grepprg = tools#grep('findstr', 'grepprg')
            endif
        endif

        if exists('g:plugs["gonvim-fuzzy"]')
            if executable('git') && autocmd#IsGitRepo(l:project_root)
                let g:gonvim_fuzzy_ag_cmd = tools#grep('git', 'grepprg')
            elseif executable('rg')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('rg', 'grepprg')
            elseif executable('ag')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('ag', 'grepprg')
            elseif executable('grep')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('grep', 'grepprg')
            elseif executable('findstr')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('findstr', 'grepprg')
            endif
        endif


    else
        let l:project_root = fnamemodify(getcwd(), ':p')

        if filereadable(l:project_root . '/project.vim')
            try
                execute 'source '. l:project_root . '/project.vim'
            catch /.*/
                if !has#gui()
                    echoerr 'There were errors with the project file in ' . l:project_root . '/project.vim'
                endif
            endtry
        endif

        if exists('g:plugs["ultisnips"]')
            silent! delcommand UltiSnipsDir
            let g:UltiSnipsSnippetsDir        = vars#basedir() . 'config/UltiSnips'
            let g:UltiSnipsSnippetDirectories = [vars#basedir() . 'config/UltiSnips', 'UltiSnips']
        endif

        if exists('g:plugs["ctrlp"]')
            let g:ctrlp_clear_cache_on_exit = (g:ctrlp_user_command.fallback =~# '^ag ')
        endif

        if exists('g:plugs["projectile.nvim"]')
            if executable('ag')
                let g:projectile#search_prog = 'ag'
            elseif has('unix')
                let g:projectile#search_prog = 'grep'
            elseif os#name() ==# 'windows' && !executable('grep')
                let g:projectile#search_prog = 'findstr '
            endif
        endif

        if exists('g:plugs["deoplete.nvim"]') && ( exists('g:plugs["deoplete-clang"]') || exists('g:plugs["deoplete-clang2"]') )
            if filereadable(l:project_root . '/compile_commands.json')
                let g:deoplete#sources#clang#clang_complete_database = l:project_root
            else
                if exists('g:deoplete#sources#clang#clang_complete_database')
                    unlet g:deoplete#sources#clang#clang_complete_database
                endif
            endif
        endif

        " If we don't have grepper variable, we have not done :PlugInstall
        if exists('g:plugs["vim-grepper"]') && exists('g:grepper')
            let g:grepper.tools = []
            let g:grepper.operator.tools = []

            if executable('rg')
                let g:grepper.tools += ['rg']
                let g:grepper.operator.tools += ['rg']
            endif
            if executable('ag')
                let g:grepper.tools += ['ag']
                let g:grepper.operator.tools += ['ag']
            endif
            if executable('grep')
                let g:grepper.tools += ['grep']
                let g:grepper.operator.tools += ['grep']
            endif
            if executable('findstr')
                let g:grepper.tools += ['findstr']
                let g:grepper.operator.tools += ['findstr']
            endif
        else
            if executable('rg')
                let &grepprg = tools#grep('rg', 'grepprg')
            elseif executable('ag')
                let &grepprg = tools#grep('ag', 'grepprg')
            elseif executable('grep')
                let &grepprg = tools#grep('grep', 'grepprg')
            elseif executable('findstr')
                let &grepprg = tools#grep('findstr', 'grepprg')
            endif
        endif

        if exists('g:plugs["gonvim-fuzzy"]')
            if executable('rg')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('rg', 'grepprg')
            elseif executable('ag')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('ag', 'grepprg')
            elseif executable('grep')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('grep', 'grepprg')
            elseif executable('findstr')
                let g:gonvim_fuzzy_ag_cmd = tools#grep('findstr', 'grepprg')
            endif
        endif

    endif
    return l:project_root
endfunction

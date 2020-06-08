scriptencoding 'utf-8'
" Autocmd Setttings
" github.com/mike325/.vim

function! autocmd#CleanFile() abort
    " Sometimes we don't want to remove spaces
    let l:buftypes = 'nofile\|help\|quickfix\|terminal'
    let l:filetypes = 'bin\|hex\|log\|git\|man\|terminal'

    if mode() !=# 'n' && ( b:trim != 1 || &buftype =~? l:buftypes || &filetype ==? l:filetypes || &filetype ==? '' )
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

    call setpos('.', l:savepos)
    call setreg('/', l:oldquery)
endfunction

function! autocmd#FileName(...) abort
    let l:filename = expand('%:t:r')
    let l:extension = empty(expand('%:e')) ? '*' : expand('%:e')

    let l:skeleton = ''
    let l:template = (a:0 > 0) ? a:1 : ''

    let l:skeletons_path = vars#basedir(). '/skeletons/'

    let l:known_names = {
    \   '*': [ 'clang-format', 'clang-tidy' ],
    \   'py': [ 'ycm_extra_conf' ],
    \   'json': [ 'projections' ],
    \   'c': [ 'main' ],
    \   'cpp': [ 'main' ],
    \ }

    if !empty(l:template)
        let l:skeleton = fnameescape(l:skeletons_path . l:template)
    else
        if get(l:known_names, l:extension, []) != []
            let l:names = l:known_names[l:extension]
            for l:name in l:names
                if l:filename =~? l:name
                    let l:template_file = l:skeletons_path . l:name

                    if filereadable(fnameescape(l:template_file))
                        let l:skeleton = fnameescape(l:template_file)
                        break
                    elseif filereadable(fnameescape(l:template_file . '.' . l:extension))
                        let l:skeleton = fnameescape(l:template_file . '.' . l:extension)
                        break
                    endif
                endif
            endfor
        endif

        if empty(l:skeleton)
            let l:skeleton = fnameescape(l:skeletons_path . '/skeleton.' . l:extension)
        endif

    endif

    if filereadable(l:skeleton)
        execute 'keepalt read '. l:skeleton
        silent! execute '%s/\<NAME\>/'.l:filename.'/e'
        call histdel('search', -1)
        silent! execute '%s/\<NAME\ze_H\(PP\)\?\>/\U'.l:filename.'/g'
        call histdel('search', -1)
        execute 'bwipeout! ' . l:skeleton
        execute '1delete_'
    endif
endfunction

function! autocmd#FindProjectRoot(path) abort
    let l:project_root = ''
    let l:markers = ['.git', '.svn', '.hg']
    let l:dir = fnamemodify(a:path, ':p')

    for l:marker in l:markers
        let l:project_root = finddir(l:marker, l:dir.';')
        if l:marker =~# '\.git' && empty(l:project_root)
            let l:project_root = findfile(l:marker, l:dir.';')
            if !empty(l:project_root)
                let l:project_root = l:project_root . '/'
            endif
        endif

        if !empty(l:project_root)
            let l:project_root = fnamemodify(l:project_root, ':p:h:h')
            break
        endif
    endfor

    return l:project_root
endfunction

function! autocmd#getProjectRoot() abort
    let b:project_root = get(b:, 'project_root', autocmd#FindProjectRoot(getcwd()))
    return b:project_root
endfunction

function! autocmd#IsGitRepo(root) abort
    return (isdirectory(a:root . '/.git') || filereadable(a:root . '/.git'))
endfunction

function! autocmd#SetProjectConfigs(event) abort
    let l:cwd = exists('a:event["cwd"]') ? a:event['cwd'] : getcwd()

    let l:project_root =  autocmd#FindProjectRoot(l:cwd)

    if empty(l:project_root)
        let l:project_root = fnamemodify(getcwd(), ':p')
    endif

    let b:project_root = get(b:, 'project_root', '')

    if l:project_root == b:project_root
        return b:project_root
    endif

    let b:project_root = l:project_root

    let l:is_git = autocmd#IsGitRepo(b:project_root)

    let &l:grepprg = tools#select_grep(l:is_git)

    let l:project = findfile('.project.vim', l:cwd.';')

    if !empty(l:project)
        execute 'source '. l:project
    endif

    if exists('g:plugs["ctrlp"]')
        let l:fallback = g:ctrlp_user_command.fallback
        let g:ctrlp_clear_cache_on_exit = is_git ? 1 : (fallback =~# '^\(ag\|rg\|fd\) ')
    endif

    " If we don't have grepper variable, we have not done :PlugInstall
    if exists('g:plugs["vim-grepper"]') && exists('g:grepper')
        let g:grepper.tools = []
        let g:grepper.operator.tools = []

        if executable('git') && l:is_git
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
    endif

    if exists('g:plugs["gonvim-fuzzy"]')
        let g:gonvim_fuzzy_ag_cmd = tools#select_grep(l:is_git)
    endif


    return b:project_root
endfunction

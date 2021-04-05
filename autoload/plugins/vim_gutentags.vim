" gutentags Settings
" github.com/mike325/.vim

if !has#plugin('vim-gutentags') || exists('g:config_gutentags')
    finish
endif

let g:config_gutentags = 1

let g:gutentags_enabled = 1
let g:gutentags_modules = get(g:, 'gutentags_modules', [])
let g:gutentags_cache_dir = os#cache()

let g:gutentags_exclude_filetypes = [
    \   'text',
    \   'conf',
    \   'markdown',
    \   'help',
    \   'man',
    \   'git',
    \   'log',
    \   'Telescope',
    \   'TelescopePrompt',
    \   'fugitive',
    \]

if executable('ctags')
    let g:gutentags_modules += ['ctags']

    let g:gutentags_ctags_extra_args = [
        \  '--append',
        \  '--c-kinds=+p',
        \  '--c++-kinds=+pl',
        \  '--recurse=yes',
        \  '--fields=+i',
        \  '--fields=+a',
        \  '--fields=+m',
        \  '--fields=+S',
        \  '--fields=+l',
        \  '--fields=+n',
        \  '--fields=+t',
        \  '--exclude=.svn',
        \  '--exclude=.hg',
        \  '--exclude=.git',
        \  '--exclude=dist',
        \  '--exclude=user-data',
        \  '--exclude=venv',
        \  '--exclude=virtualenv',
        \  '--exclude=static-cache',
        \  '--exclude=closure-library',
        \  '--exclude=.ropeproject/*',
        \  '--exclude=__pycache__/*',
        \  '--exclude=_build/*',
        \  '--exclude=build/*',
        \  '--exclude=cache/*',
        \  '--exclude=node_modules/*',
        \  '--exclude=lib/*',
        \  '--exclude=log/*',
        \  '--exclude=tmp/*',
        \  '--exclude=*.xml',
        \ ]
endif

if executable('gtags-cscope')
    let g:gutentags_modules += ['gtags_cscope']
elseif executable('cscope')
    let g:gutentags_modules += ['cscope']
endif

let g:gutentags_exclude_project_root = get(g:, 'gutentags_exclude_project_root', [])

if os#name('windows')
    let g:gutentags_exclude_project_root += ['C:/Program Files', 'C:/Program Files (x86)']
else
    let g:gutentags_exclude_project_root += ['/opt', '/mnt', '/media', '/usr/local']
endif

let g:gutentags_file_list_command = {
    \ 'default': tools#select_filelist(0),
    \ 'markers': {
        \ '.git': tools#select_filelist(1),
        \ },
    \ }

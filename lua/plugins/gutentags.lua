local sys = require'sys'
local executable = require'utils.files'.executable
local has_attrs = require'utils.tables'.has_attrs

local gutentags_modules = vim.g.gutentags_modules or {}

vim.g.gutentags_enabled = 1
vim.g.gutentags_cache_dir = sys.cache

vim.g.gutentags_exclude_filetypes = {
    'text',
    'conf',
    'markdown',
    'help',
    'man',
    'git',
    'log',
    'Telescope',
    'TelescopePrompt',
    'fugitive',
}

if executable('ctags') then
    if not has_attrs(gutentags_modules, 'ctags') then
        gutentags_modules[#gutentags_modules + 1] = 'ctags'
    end

    vim.g.gutentags_ctags_extra_args = {
        '--append',
        '--c-kinds=+p',
        '--c++-kinds=+pl',
        '--recurse=yes',
        '--fields=+i',
        '--fields=+a',
        '--fields=+m',
        '--fields=+S',
        '--fields=+l',
        '--fields=+n',
        '--fields=+t',
        '--exclude=.svn',
        '--exclude=.hg',
        '--exclude=.git',
        '--exclude=dist',
        '--exclude=user-data',
        '--exclude=venv',
        '--exclude=virtualenv',
        '--exclude=static-cache',
        '--exclude=closure-library',
        '--exclude=.ropeproject/*',
        '--exclude=__pycache__/*',
        '--exclude=_build/*',
        '--exclude=build/*',
        '--exclude=cache/*',
        '--exclude=node_modules/*',
        '--exclude=lib/*',
        '--exclude=log/*',
        '--exclude=tmp/*',
        '--exclude=*.xml',
    }
end

-- if executable('gtags-cscope') then
--     gutentags_modules[#gutentags_modules + 1] = 'gtags_cscope'
-- elseif executable('cscope') then
if executable('cscope') and not has_attrs(gutentags_modules, 'cscope') then
    gutentags_modules[#gutentags_modules + 1] = 'cscope'
end

vim.g.gutentags_modules = gutentags_modules

local gutentags_exclude_project_root = vim.g.gutentags_exclude_project_root or {}

if sys.name == 'windows' then
    vim.list_extend(gutentags_exclude_project_root, {'C:/Program Files', 'C:/Program Files (x86)'})
else
    vim.list_extend(gutentags_exclude_project_root, {'/opt', '/mnt', '/media', '/usr/local'})
end

vim.g.gutentags_exclude_project_root = gutentags_exclude_project_root

-- let g:gutentags_file_list_command = {
--     \ 'default': tools#select_filelist(0),
--     \ 'markers': {
--         \ '.git': tools#select_filelist(1),
--         \ },
--     \ }

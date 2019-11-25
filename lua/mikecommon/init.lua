-- local nvim = require('mikecommon/nvim')
local sys = require('mikecommon/sys')

local function isempty(s)
    return s == nil or s == ''
end

local function init()

    local parent = sys.data

    if not vim.api.nvim_call_function('isdirectory', {parent}) then
        vim.api.nvim_call_function('mkdir', {parent, 'p'})
    end

    local dirpaths = {
        backup   = 'backupdir',
        swap     = 'directory',
        undo     = 'undodir',
        cache    = '',
        sessions = '',
    }

    for dirname,dir_setting in pairs(dirpaths) do
        if not vim.api.nvim_call_function('isdirectory', {parent .. '/' .. dirname}) then
            vim.api.nvim_call_function('mkdir', {parent .. '/' .. dirname, 'p'})
        end

        if not isempty(dir_setting) then
            vim.api.nvim_set_option(dir_setting, parent .. '/' .. dirname)
        end
    end

    vim.api.nvim_set_option('shada', "!,/1000,'1000,<1000,:1000,s10000,h")

    vim.api.nvim_set_option('backup', true)
    vim.api.nvim_set_option('undofile', true)
    vim.api.nvim_set_option('signcolumn', 'auto')
    vim.api.nvim_set_option('inccommand', 'split')

    vim.api.nvim_set_var('terminal_scrollback_buffer_size', 100000)

    local ok, _ = pcall(vim.api.nvim_get_var, 'gonvim_running')

    if ok then
        vim.api.nvim_set_option('showmode', false)
        vim.api.nvim_set_option('ruler', false)
    else
        vim.api.nvim_set_option('titlestring', '%t (%f)')
        vim.api.nvim_set_option('title', true)
    end

    local wildignores = {
        '*.spl',
        '*.aux',
        '*.out',
        '*.o',
        '*.pyc',
        '*.gz',
        '*.pdf',
        '*.sw',
        '*.swp',
        '*.swap',
        '*.com',
        '*.exe',
        '*.so',
        '*/cache/*',
        '*/__pycache__/*',
    }

    local no_backup = {
        '.git/*',
        '.svn/*',
        '.xml',
        '*.log',
        '*.bin',
        '*.7z',
        '*.dmg',
        '*.gz',
        '*.iso',
        '*.jar',
        '*.rar',
        '*.tar',
        '*.zip',
        'TAGS',
        'tags',
        'GTAGS',
        'COMMIT_EDITMSG',
    }

    vim.api.nvim_set_option('wildignore', table.concat(wildignores, ','))
    vim.api.nvim_set_option('backupskip', table.concat(no_backup, ',') .. ',' .. table.concat(wildignores, ',') )

    -- if nvim.has_version('0.5') and nvimFuncWrapper('tools#CheckLanguageServer') then
    --     nvimFuncWrapper('nvim#lsp')
    -- end

    if vim.loop.os_getenv('SSH_CONNECTION') == nil then
        vim.api.nvim_set_option('clipboard', 'unnamedplus,unnamed')
    end

end

init()

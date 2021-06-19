-- luacheck: globals unpack vim
local nvim = require'nvim'

-- local has     = nvim.has
-- local plugins = nvim.plugins

local set_autocmd = nvim.autocmds.set_autocmd
-- local set_command = nvim.commands.set_command
-- local set_mapping = nvim.mappings.set_mapping

if require'sys'.name ~= 'windows' then
    set_autocmd{
        event   = 'BufNewFile',
        pattern = '*',
        cmd     = [[lua require'utils'.functions.make_executable()]],
        group   = 'LuaAutocmds',
    }

    set_autocmd{
        event   = 'Filetype',
        pattern = 'python,lua,sh,bash,zsh,tcsh,csh,ruby,perl',
        cmd     = [[lua require'utils'.functions.make_executable()]],
        group   = 'LuaAutocmds',
    }
end

set_autocmd{
    event   = {'BufNewFile', 'BufReadPre', 'BufEnter'},
    pattern = '*',
    cmd     = "if !exists('b:trim') | let b:trim = v:true | endif",
    group   = 'CleanFile'
}

set_autocmd{
    event   = 'BufWritePre',
    pattern = '*',
    cmd     = 'lua require"utils".files.clean_file()',
    group   = 'CleanFile'
}

set_autocmd{
    event   = 'TextYankPost',
    pattern = '*',
    cmd     = [[silent! lua require'vim.highlight'.on_yank({higroup = "IncSearch", timeout = 1000})]],
    group   = 'YankHL'
}

set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'setlocal noswapfile nobackup noundofile bufhidden=',
    group   = 'TerminalAutocmds'
}

set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'setlocal norelativenumber nonumber nocursorline',
    group   = 'TerminalAutocmds'
}

set_autocmd{
    event   = 'VimResized',
    pattern = '*',
    cmd     = 'wincmd =',
    group   = 'AutoResize'
}

set_autocmd{
    event   = 'BufRead',
    pattern = '*',
    cmd     = 'lua require"utils".buffers.last_position()',
    group   = 'LastEditPosition'
}

set_autocmd{
    event   = 'BufNewFile',
    pattern = '*',
    cmd     = 'lua require"utils".files.skeleton_filename()',
    group   = 'Skeletons'
}

set_autocmd{
    event   = {'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter'},
    pattern = '*',
    cmd     = 'lua require"utils".helpers.project_config(vim.fn.deepcopy(vim.v.event))',
    group   = 'ProjectConfig'
}

set_autocmd{
    event   = 'CmdwinEnter',
    pattern = '*',
    cmd     = 'nnoremap <CR> <CR>',
    group   = 'LocalCR'
}

set_autocmd{
    event   = {'BufEnter','BufReadPost'},
    pattern = '__LanguageClient__',
    cmd     = 'nnoremap <silent> <nowait> <buffer> q :q!<CR>',
    group   = 'QuickQuit'
}

set_autocmd{
    event   = {'BufEnter','BufWinEnter'},
    pattern = '*',
    cmd     = 'if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif',
    group   = 'QuickQuit'
}

set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'nnoremap <silent><nowait><buffer> q :q!<CR>',
    group   = 'QuickQuit'
}

set_autocmd{
    event   = {'BufNewFile', 'BufReadPre', 'BufEnter'},
    pattern = '/tmp/*',
    cmd     = 'setlocal noswapfile nobackup noundofile',
    group   = 'DisableTemps'
}

set_autocmd{
    event   = {'InsertLeave', 'CompleteDone'},
    pattern = '*',
    cmd     = 'if pumvisible() == 0 | pclose | endif',
    group   = 'CloseMenu'
}

set_autocmd{
    event   = 'Filetype',
    pattern = 'lua',
    cmd     = [[nnoremap <buffer><silent> <leader><leader>r :luafile %<cr>:echo "File reloaded"<cr>]],
    group   = 'Reload',
}

set_autocmd{
    event   = 'BufWritePost',
    pattern = 'lua/plugins/setup.lua',
    cmd     = 'PackerCompile',
    group   = 'Reload',
}

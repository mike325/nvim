-- luacheck: globals unpack vim

local has              = require'nvim'.has
local plugins          = require'nvim'.plugins
local nvim_set_autocmd = require'nvim'.nvim_set_autocmd

-- local sys = require'sys'

nvim_set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'setlocal noswapfile nobackup noundofile bufhidden=',
    group   = 'TerminalAutocmds'
}

nvim_set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'setlocal norelativenumber nonumber nocursorline',
    group   = 'TerminalAutocmds'
}

nvim_set_autocmd{
    event   = 'VimResized',
    pattern = '*',
    cmd     = 'wincmd =',
    group   = 'AutoResize'
}

nvim_set_autocmd{
    event   = 'BufRead',
    pattern = '*',
    cmd     = 'lua require"tools".last_position()',
    group   = 'LastEditPosition'
}

nvim_set_autocmd{
    event   = 'BufNewFile',
    pattern = '*',
    cmd     = 'lua require"tools".file_name()',
    group   = 'Skeletons'
}

nvim_set_autocmd{
    event   = {'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter'},
    pattern = '*',
    cmd     = 'lua require"tools.helpers".project_config(require"nvim".fn.deepcopy(require"nvim".v.event))',
    group   = 'ProjectConfig'
}

nvim_set_autocmd{
    event   = 'CmdwinEnter',
    pattern = '*',
    cmd     = 'nnoremap <CR> <CR>',
    group   = 'LocalCR'
}

nvim_set_autocmd{
    event   = {'BufEnter','BufReadPost'},
    pattern = '__LanguageClient__',
    cmd     = 'nnoremap <silent> <nowait> <buffer> q :q!<CR>',
    group   = 'QuickQuit'
}

nvim_set_autocmd{
    event   = {'BufEnter','BufWinEnter'},
    pattern = '*',
    cmd     = 'if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif',
    group   = 'QuickQuit'
}

nvim_set_autocmd{
    event   = 'TermOpen',
    pattern = '*',
    cmd     = 'nnoremap <silent><nowait><buffer> q :q!<CR>',
    group   = 'QuickQuit'
}

nvim_set_autocmd{
    event   = {'BufNewFile', 'BufReadPre', 'BufEnter'},
    pattern = '/tmp/*',
    cmd     = 'setlocal noswapfile nobackup noundofile',
    group   = 'DisableTemps'
}

nvim_set_autocmd{
    event   = {'InsertLeave', 'CompleteDone'},
    pattern = '*',
    cmd     = 'if pumvisible() == 0 | pclose | endif',
    group   = 'CloseMenu'
}

if has('nvim-0.5') then
    nvim_set_autocmd{
        event   = 'TextYankPost',
        pattern = '*',
        cmd     = [[silent! lua require'vim.highlight'.on_yank("IncSearch", 3000)]],
        group   = 'YankHL'
    }
end

if plugins['completor.vim'] == nil then
    nvim_set_autocmd{
        event   = {'BufNewFile', 'BufReadPre', 'BufEnter'},
        pattern = '*',
        cmd     = "if !exists('b:trim') | let b:trim = v:true | endif",
        group   = 'CleanFile'
    }

    nvim_set_autocmd{
        event   = 'BufWritePre',
        pattern = '*',
        cmd     = 'lua require"tools".clean_file()',
        group   = 'CleanFile'
    }
end

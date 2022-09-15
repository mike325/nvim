local nvim = require 'neovim'
local executable = require('utils.files').executable

if require('sys').name ~= 'windows' then
    nvim.autocmd.MakeExecutable = {
        {
            event = 'BufReadPost',
            pattern = '*',
            callback = function()
                require('utils.functions').make_executable()
            end,
        },
        {
            event = 'FileType',
            pattern = 'python,lua,sh,bash,zsh,tcsh,csh,ruby,perl',
            callback = function()
                require('utils.functions').make_executable()
            end,
        },
    }
end

nvim.autocmd.CleanFile = {
    {
        event = { 'BufNewFile', 'BufReadPre', 'BufEnter' },
        pattern = '*',
        callback = function()
            if vim.b.trim == nil then
                vim.b.trim = true
            end
        end,
    },
    {
        event = 'BufWritePre',
        pattern = '*',
        callback = function()
            require('utils.files').clean_file()
        end,
    },
}

nvim.autocmd.YankHL = {
    event = 'TextYankPost',
    pattern = '*',
    command = [[silent! lua vim.highlight.on_yank{higroup = "IncSearch", timeout = 1000}]],
}

nvim.autocmd.TerminalAutocmds = {
    event = 'TermOpen',
    pattern = '*',
    command = 'setlocal noswapfile nobackup noundofile norelativenumber nonumber nocursorline',
}

nvim.autocmd.AutoResize = {
    event = 'VimResized',
    pattern = '*',
    command = 'wincmd =',
}

nvim.autocmd.LastEditPosition = {
    event = 'BufReadPost',
    pattern = '*',
    callback = function()
        require('utils.buffers').last_position()
    end,
}

nvim.autocmd.Skeletons = {
    event = 'BufNewFile',
    pattern = '*',
    callback = function()
        require('utils.files').skeleton_filename()
    end,
}

nvim.autocmd.ProjectConfig = {
    event = { 'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter' },
    pattern = '*',
    callback = function()
        require('utils.functions').project_config(vim.deepcopy(vim.v.event))
    end,
}

nvim.autocmd.LocalCR = {
    event = 'CmdwinEnter',
    pattern = '*',
    command = 'nnoremap <CR> <CR>',
}

nvim.autocmd.QuickQuit = {
    {
        event = { 'BufEnter', 'BufReadPost' },
        pattern = '__LanguageClient__',
        command = 'nnoremap <silent> <nowait> <buffer> q :q!<CR>',
    },
    {
        event = { 'BufEnter', 'BufWinEnter' },
        pattern = '*',
        command = 'if &previewwindow | nnoremap <silent> <nowait> <buffer> q :q!<CR>| endif',
    },
    {
        event = 'TermOpen',
        pattern = '*',
        command = 'nnoremap <silent><nowait><buffer> q :q!<CR>',
    },
}

nvim.autocmd.DisableTemps = {
    event = { 'BufNewFile', 'BufReadPre', 'BufEnter' },
    pattern = '/tmp/*',
    command = 'setlocal noswapfile nobackup noundofile',
}

nvim.autocmd.CloseMenu = {
    event = { 'InsertLeave', 'CompleteDone' },
    pattern = '*',
    command = 'if pumvisible() == 0 | pclose | endif',
}

nvim.autocmd.Reload = {
    {
        event = 'BufWritePost',
        pattern = 'lua/plugins/init.lua',
        command = 'source lua/plugins/init.lua | PackerCompile',
    },
    -- {
    --     event = 'FileType',
    --     pattern = 'lua',
    --     command = [[nnoremap <buffer><silent> <leader><leader>r :luafile %<cr>:echo "File reloaded"<cr>]],
    -- },
}

nvim.autocmd.FoldText = {
    event = 'FileType',
    pattern = '*',
    command = [[setlocal foldtext=luaeval('require\"utils\".functions.foldtext()')]],
}

-- BufReadPost is triggered after FileType detection, TS may not be attatch yet after
-- FileType event, but should be fine to use BufReadPost
nvim.autocmd.Indent = {
    event = 'BufReadPost',
    pattern = '*',
    callback = function()
        RELOAD('utils.buffers').detect_indent()
    end,
}

-- TODO: Autoenable autoformat when any autoformatter is present
local function autoformat(cmd, args)
    if vim.b.disable_autoformat then
        return
    end

    local formatter = require('jobs'):new {
        cmd = cmd,
        args = args,
        silent = true,
    }
    formatter:callback_on_success(function()
        nvim.ex.checktime()
        -- nvim.ex.edit()
    end)
    formatter:start()
end

nvim.augroup.del 'ImportFix'
if executable 'goimports' then
    nvim.autocmd.add('BufWritePost', {
        group = 'ImportFix',
        pattern = '*.go',
        callback = function(args)
            autoformat('goimports', { '-w', args.file })
        end,
    })
end

if executable 'isort' then
    nvim.autocmd.add('BufWritePost', {
        group = 'ImportFix',
        pattern = '*.{py,ipy}',
        callback = function(args)
            autoformat('isort', { '--profile=black', args.file }) -- '-l', '120', '-tc'
        end,
    })
end

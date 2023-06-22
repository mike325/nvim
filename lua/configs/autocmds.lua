local nvim = require 'nvim'
local executable = require('utils.files').executable

if require('sys').name ~= 'windows' then
    nvim.autocmd.MakeExecutable = {
        {
            event = 'BufReadPost',
            pattern = '*',
            callback = function()
                RELOAD('utils.files').make_executable()
            end,
        },
        {
            event = 'FileType',
            pattern = 'python,lua,sh,bash,zsh,tcsh,csh,ruby,perl',
            callback = function()
                RELOAD('utils.files').make_executable()
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
            RELOAD('utils.files').clean_file()
        end,
    },
}

nvim.autocmd.YankHL = {
    event = 'TextYankPost',
    pattern = '*',
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 1000 }
    end,
}

nvim.autocmd.TerminalAutocmds = {
    event = 'TermOpen',
    pattern = '*',
    callback = function()
        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.undofile = false
        vim.opt.relativenumber = false
        vim.opt.number = false
        vim.opt.cursorline = false
    end,
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
        RELOAD('utils.buffers').last_position()
    end,
}

nvim.autocmd.Skeletons = {
    event = 'BufNewFile',
    pattern = '*',
    callback = function()
        RELOAD('utils.files').skeleton_filename()
    end,
}

nvim.autocmd.ProjectConfig = {
    event = { 'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter' },
    pattern = '*',
    callback = function()
        RELOAD('utils.functions').project_config(vim.deepcopy(vim.v.event))
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

nvim.autocmd.FoldText = {
    event = 'FileType',
    pattern = '*',
    command = [[setlocal foldtext=luaeval('RELOAD\"utils\".functions.foldtext()')]],
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

-- TODO: should this check if the filea actually change before fixing imports?
nvim.augroup.del 'ImportFix'
if executable 'goimports' then
    nvim.autocmd.add('BufWritePost', {
        group = 'ImportFix',
        pattern = '*.go',
        callback = function(args)
            RELOAD('utils.functions').autoformat('goimports', { '-w', args.file })
        end,
    })
end

if executable 'isort' then
    nvim.autocmd.add('BufWritePost', {
        group = 'ImportFix',
        pattern = '*.{py,ipy}',
        callback = function(args)
            local format_args = RELOAD('filetypes.python').formatprg.isort
            table.insert(format_args, args.file)
            RELOAD('utils.functions').autoformat('isort', format_args)
        end,
    })
end

nvim.autocmd.add('User', {
    pattern = 'FlagsParsed',
    callback = function()
        local extensions = {
            c = true,
            h = true,
            cc = true,
            cpp = true,
            cxx = true,
            hpp = true,
            hxx = true,
        }

        local cpp = RELOAD 'filetypes.cpp'
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(buf)
            local ext = vim.fn.fnamemodify(bufname, ':e')
            if extensions[ext] then
                if ext == 'c' or ext == 'h' then
                    cpp.set_opts(cpp.get_compiler 'c', buf)
                else
                    cpp.set_opts(cpp.get_compiler 'cpp', buf)
                end
            end
        end
    end,
})

nvim.autocmd.LspMappings = {
    event = 'LspAttach',
    pattern = '*',
    callback = function(args)
        local bufnr = args.buf
        local client = vim.lsp.get_client_by_id(args.data.client_id)

        local null_ls = vim.F.npcall(require, 'null-ls')
        if null_ls and client.name ~= 'null-ls' then
            local null_configs = require 'configs.lsp.null'

            local ft = vim.bo.filetype
            local has_formatting = client.server_capabilities.documentFormattingProvider
                or client.server_capabilities.documentRangeFormattingProvider

            if not has_formatting and null_ls and null_configs[ft] and null_configs[ft].formatter then
                if not null_ls.is_registered(null_configs[ft].formatter.name) then
                    null_ls.register { null_configs[ft].formatter }
                end
            end
        end

        RELOAD('configs.lsp.config').lsp_mappings(client, bufnr)
    end,
}

nvim.autocmd.Alternate = {
    event = 'FileType',
    pattern = 'c,cpp',
    callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- NOTE: should this look in the local path instead of the whole directory?
        if bufname ~= '' and not vim.g.alternates[bufname] then
            RELOAD('threads.related').async_lookup_alternate()
        end
    end,
}

nvim.autocmd.SSHParser = {
    event = 'BufWritePost',
    pattern = '*/.ssh/config,*\\.ssh\\config',
    callback = function()
        RELOAD('threads.parse').ssh_hosts()
    end,
}

nvim.autocmd.ApplyColorscheme = {
    event = 'VimEnter',
    pattern = '*',
    callback = function()
        local ok, _ = pcall(vim.cmd.colorscheme, 'catppuccin')
        if not ok then
            vim.cmd.colorscheme 'torte'
        end
    end,
}

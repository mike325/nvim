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
    command = "setlocal foldtext=v:lua.RELOAD('utils.functions').foldtext()",
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
        if not vim.g.fix_inlay_hl then
            local comment_hl = vim.api.nvim_get_hl(0, { name = 'Comment' })
            comment_hl.bold = true
            comment_hl.underline = false
            comment_hl.italic = true
            comment_hl.fg = comment_hl.fg + 26 -- color #6C70a0
            comment_hl.cterm = comment_hl.cterm or {}
            comment_hl.cterm.bold = true
            comment_hl.cterm.italic = true
            vim.api.nvim_set_hl(0, 'LspInlayHint', comment_hl)
            vim.g.fix_inlay_hl = true
        end

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

nvim.autocmd.CleanHelps = {
    event = 'WinClosed',
    pattern = '*',
    callback = function(args)
        if vim.bo[args.buf].filetype == 'help' then
            local clean_helps = true
            for _, tab in ipairs(vim.api.nvim_list_tabpages()) do
                for _, win in ipairs(vim.api.nvim_tabpage_list_wins(tab)) do
                    local buf = vim.api.nvim_win_get_buf(win)
                    if vim.bo[buf].filetype == 'help' and args.buf ~= buf then
                        clean_helps = false
                        break
                    end
                end
                if not clean_helps then
                    break
                end
            end

            if clean_helps then
                for _, buf in ipairs(vim.api.nvim_list_bufs()) do
                    if vim.bo[buf].filetype == 'help' then
                        vim.api.nvim_buf_delete(buf, { force = true })
                    end
                end
            end
        end
    end,
}

nvim.autocmd.ApplyColorscheme = {
    event = 'VimEnter',
    pattern = '*',
    callback = function()
        local ok = false
        if not vim.g.bare then
            ok = pcall(vim.cmd.colorscheme, 'catppuccin')
        end
        if vim.g.bare or not ok then
            vim.cmd.colorscheme 'slate'
        end
    end,
}

nvim.autocmd.CustomUI = {
    event = 'UIEnter',
    pattern = '*',
    callback = function(event)
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == 'Firenvim' then
            vim.o.laststatus = 0
            vim.api.nvim_set_keymap('n', '<C-z>', '<cmd>call firenvim#hide_frame()<CR>', { noremap = true })
        end
    end,
}

-- NOTE: Default TMUX clipboard provider support setting system clipboard using OSC 52
if vim.env.SSH_CONNECTION and not vim.env.TMUX then
    nvim.autocmd.OSCYank = {
        event = 'TextYankPost',
        pattern = '*',
        callback = function(args)
            local clipboard_reg = {
                ['+'] = true,
                ['*'] = true,
            }
            local reg = vim.v.register
            if vim.v.event.operator == 'y' and (reg == '' or clipboard_reg[reg]) then
                require('utils.functions').send_osc52(vim.split(nvim.reg[reg], '\n'))
            end
        end,
    }
end

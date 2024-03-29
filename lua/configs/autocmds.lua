local nvim = require 'nvim'
local executable = require('utils.files').executable

if require('sys').name ~= 'windows' then
    local make_executable = vim.api.nvim_create_augroup('MakeExecutable', { clear = true })

    vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
        desc = "Check if the file is executable and add autocmds to make it executable if it's not",
        group = make_executable,
        pattern = '*',
        callback = function()
            RELOAD('utils.files').make_executable()
        end,
    })

    vim.api.nvim_create_autocmd({ 'Filetype' }, {
        desc = "Check if the file is executable and add autocmds to make it executable if it's not",
        group = make_executable,
        pattern = 'python,lua,sh,bash,zsh,tcsh,csh,ruby,perl',
        callback = function()
            RELOAD('utils.files').make_executable()
        end,
    })
end

local clean_file = vim.api.nvim_create_augroup('CleanFile', { clear = true })
vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre', 'BufEnter' }, {
    desc = 'Initialize trim variable',
    group = clean_file,
    pattern = '*',
    callback = function()
        if vim.b.trim == nil then
            vim.b.trim = true
        end
    end,
})
vim.api.nvim_create_autocmd({ 'BufWritePre' }, {
    desc = 'Remove trailing spaces and some other artifacts',
    group = clean_file,
    pattern = '*',
    callback = function()
        RELOAD('utils.files').clean_file()
    end,
})

vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    desc = 'Initialize terminal buffer and disable certains local options',
    group = vim.api.nvim_create_augroup('TerminalAutocmds', { clear = true }),
    pattern = '*',
    callback = function()
        vim.opt.swapfile = false
        vim.opt.backup = false
        vim.opt.undofile = false
        vim.opt.relativenumber = false
        vim.opt.number = false
        vim.opt.cursorline = false
    end,
})

vim.api.nvim_create_autocmd({ 'VimResized' }, {
    desc = 'Auto rezise windows to equalize sizes',
    group = vim.api.nvim_create_augroup('AutoResize', { clear = true }),
    pattern = '*',
    command = 'wincmd =',
})

vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    desc = 'Move the cursor to the last known location',
    group = vim.api.nvim_create_augroup('LastEditPosition', { clear = true }),
    pattern = '*',
    callback = function()
        RELOAD('utils.buffers').last_position()
    end,
})

vim.api.nvim_create_autocmd({ 'BufNewFile' }, {
    desc = 'Initialize buffer with skeleton template',
    group = vim.api.nvim_create_augroup('Skeletons', { clear = true }),
    pattern = '*',
    callback = function()
        RELOAD('utils.files').skeleton_filename()
    end,
})

vim.api.nvim_create_autocmd({ 'DirChanged', 'BufNewFile', 'BufReadPre', 'BufEnter', 'VimEnter' }, {
    desc = 'Setup project specific configs',
    group = vim.api.nvim_create_augroup('ProjectConfig', { clear = true }),
    pattern = '*',
    callback = function()
        RELOAD('utils.functions').project_config(vim.deepcopy(vim.v.event))
    end,
})

vim.api.nvim_create_autocmd({ 'CmdwinEnter' }, {
    desc = 'Revert <CR> value to default behavior in command line window',
    group = vim.api.nvim_create_augroup('LocalCR', { clear = true }),
    pattern = '*',
    command = 'nnoremap <CR> <CR>',
})

vim.api.nvim_create_autocmd({ 'TermOpen' }, {
    desc = 'Map q to quick exit terminal buffers',
    group = vim.api.nvim_create_augroup('QuickQuit', { clear = true }),
    pattern = '*',
    command = 'nnoremap <silent><nowait><buffer> q :q!<CR>',
})

vim.api.nvim_create_autocmd({ 'BufNewFile', 'BufReadPre', 'BufEnter' }, {
    desc = 'Disable swap, backup and undofiles on all buffers under /tmp/*',
    group = vim.api.nvim_create_augroup('DisableTemps', { clear = true }),
    pattern = '/tmp/*',
    command = 'setlocal noswapfile nobackup noundofile',
})

vim.api.nvim_create_autocmd({ 'InsertLeave', 'CompleteDone' }, {
    desc = 'Auto close completion window',
    group = vim.api.nvim_create_augroup('CloseMenu', { clear = true }),
    pattern = '*',
    command = 'if pumvisible() == 0 | pclose | endif',
})

-- BufReadPost is triggered after FileType detection, TS may not be attach yet after
-- FileType event, but should be fine to use BufReadPost
vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
    desc = 'Tries to detect indentation level of the newly opened buffer',
    group = vim.api.nvim_create_augroup('Indent', { clear = true }),
    pattern = '*',
    callback = function()
        RELOAD('utils.buffers').detect_indent()
    end,
})

local import_fix = vim.api.nvim_create_augroup('ImportFix', { clear = true })
if executable 'goimports' then
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        desc = 'Fix go imports after saving',
        group = import_fix,
        pattern = '*.go',
        callback = function(args)
            RELOAD('utils.functions').autoformat('goimports', { '-w', args.file })
        end,
    })
end

if executable 'isort' then
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        desc = 'Fix python imports before saving',
        group = import_fix,
        pattern = '*.{py,ipy}',
        callback = function(args)
            local format_args = RELOAD('filetypes.python').formatprg.isort
            table.insert(format_args, args.file)
            RELOAD('utils.functions').autoformat('isort', format_args)
        end,
    })
end

vim.api.nvim_create_autocmd('LspAttach', {
    desc = 'Setup LPS mappings and hint highlights',
    group = vim.api.nvim_create_augroup('LspMappings', { clear = true }),
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

        local lsp_utils = RELOAD 'configs.lsp.utils'
        lsp_utils.check_null_format(client)
        lsp_utils.check_null_diagnostics(client)

        RELOAD('configs.lsp.config').lsp_mappings(client, bufnr)
    end,
})

vim.api.nvim_create_autocmd('FileType', {
    desc = 'Setup header/source alternate',
    group = vim.api.nvim_create_augroup('Alternate', { clear = true }),
    pattern = 'c,cpp',
    callback = function()
        local bufname = vim.api.nvim_buf_get_name(0)
        -- NOTE: should this look in the local path instead of the whole directory?
        if bufname ~= '' and not vim.g.alternates[bufname] then
            RELOAD('threads.related').async_lookup_alternate()
        end
    end,
})

vim.api.nvim_create_autocmd('WinClosed', {
    desc = 'Wipe all help files once there are no more elp buffers assign to any window',
    group = vim.api.nvim_create_augroup('CleanHelps', { clear = true }),
    pattern = '*',
    callback = function(args)
        if vim.bo[args.buf].filetype == 'help' then
            local clean_helps = true
            for _, win in ipairs(vim.api.nvim_list_wins()) do
                local buf = vim.api.nvim_win_get_buf(win)
                if vim.bo[buf].filetype == 'help' and args.buf ~= buf then
                    clean_helps = false
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
})

vim.api.nvim_create_autocmd('VimEnter', {
    desc = 'Apply colorscheme after all initialization',
    group = vim.api.nvim_create_augroup('ApplyColorscheme', { clear = true }),
    pattern = '*',
    callback = function()
        if not vim.g.bare then
            pcall(vim.cmd.colorscheme, 'catppuccin')
        end
    end,
})

vim.api.nvim_create_autocmd('UIEnter', {
    desc = 'Overwrite <c-z> for firenvim',
    group = vim.api.nvim_create_augroup('CustomUI', { clear = true }),
    pattern = '*',
    callback = function(_)
        local client = vim.api.nvim_get_chan_info(vim.v.event.chan).client
        if client ~= nil and client.name == 'Firenvim' then
            vim.o.laststatus = 0
            vim.api.nvim_set_keymap('n', '<C-z>', '<cmd>call firenvim#hide_frame()<CR>', { noremap = true })
        end
    end,
})

if executable 'typos' then
    vim.api.nvim_create_autocmd({ 'BufWritePost' }, {
        desc = 'Check for typos on safe',
        group = vim.api.nvim_create_augroup('TyposCheck', { clear = true }),
        pattern = '*',
        callback = function(args)
            args = args or {}
            args.buf = args.buf or vim.api.nvim_get_current_buf()
            RELOAD('utils.functions').typos_check(args.buf)
        end,
    })
end

vim.api.nvim_create_autocmd({ 'TextYankPost' }, {
    desc = 'Highlight yanked text',
    group = vim.api.nvim_create_augroup('HighlightYank', { clear = true }),
    pattern = '*',
    callback = function()
        vim.highlight.on_yank { higroup = 'IncSearch', timeout = 1000 }
    end,
})

-- NOTE: Default TMUX clipboard provider support setting system clipboard using OSC 52
if vim.env.SSH_CONNECTION and not vim.env.TMUX then
    vim.api.nvim_create_autocmd('TextYankPost', {
        desc = 'Send yanked text to system clipboard using OSC 52 sequences',
        group = vim.api.nvim_create_augroup('OSCYank', { clear = true }),
        pattern = '*',
        callback = function(_)
            local clipboard_reg = {
                ['+'] = true,
                ['*'] = true,
            }
            local reg = vim.v.register
            if vim.v.event.operator == 'y' and (reg == '' or clipboard_reg[reg]) then
                require('utils.functions').send_osc52(vim.split(nvim.reg[reg], '\n'))
            end
        end,
    })
end

vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Load debug keymaps',
    pattern = 'TermdebugStartPre',
    callback = function(_)
        vim.keymap.set('n', '<F5>', '<cmd>Continue<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '=c', '<cmd>Continue<CR>', { noremap = true, silent = true })

        vim.keymap.set('n', '<F4>', '<cmd>Stop<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '=C', '<cmd>Stop<CR>', { noremap = true, silent = true })

        -- vim.keymap.set('n', 'gK', require('dap.ui.widgets').hover, { noremap = true, silent = true })

        vim.keymap.set('n', ']s', '<cmd>Over<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '[s', '<cmd>Finish<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', ']S', '<cmd>Step<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '[S', '<cmd>Finish<CR>', { noremap = true, silent = true })

        vim.keymap.set('n', '=b', '<cmd>Break<CR>', { noremap = true, silent = true })
        vim.keymap.set('n', '=B', '<cmd>Clear<CR>', { noremap = true, silent = true })

        -- vim.keymap.set('n', '=r', dap.repl.toggle, { noremap = true, silent = true })
        -- vim.keymap.set('n', '<leader>L', list_breakpoints, { noremap = true, silent = true })
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Cleanup debug keymaps',
    pattern = 'TermdebugStopPost',
    callback = function(_)
        vim.keymap.del('n', '<F5>')
        vim.keymap.del('n', '=c')

        vim.keymap.del('n', '<F4>')
        vim.keymap.del('n', '=C')

        -- vim.keymap.del('n', 'gK')

        vim.keymap.del('n', ']s')
        vim.keymap.del('n', '[s')
        vim.keymap.del('n', ']S')
        vim.keymap.del('n', '[S')

        vim.keymap.del('n', '=b')
        vim.keymap.del('n', '=B')

        -- vim.keymap.del('n', '=r')
        -- vim.keymap.del('n', '<leader>L')
    end,
})

local watcher = vim.api.nvim_create_augroup('Watcher', { clear = true })
vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Trigger ssh config reparse',
    group = watcher,
    pattern = 'ParseSSH',
    callback = function(event)
        local fname = event.data.fname
        local err = event.data.err
        local status = event.data.status

        if not err or err == '' then
            -- NOTE: Could be that the file got removed or move, verify it does exist
            if require('utils.files').is_file(fname) then
                RELOAD('threads.parse').ssh_hosts()
            end
        else
            vim.notify(
                string.format(
                    'fs_event failed!\n fname: %s\nErr: %s\nStatus: %s',
                    fname,
                    vim.inspect(err),
                    vim.inspect(status)
                ),
                vim.log.levels.ERROR,
                { title = event.match }
            )
        end
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Parse compiler flags and set C/C++ options based on them',
    group = watcher,
    pattern = 'ParseFlags',
    callback = function(event)
        local fname = event.data.fname
        local err = event.data.err
        local status = event.data.status

        if not err or err == '' then
            -- NOTE: Could be that the file got removed or move, verify it does exist
            if require('utils.files').is_file(fname) then
                RELOAD('threads.parse').compile_flags { flags_file = fname }
            end
        else
            vim.notify(
                string.format(
                    'fs_event failed!\n fname: %s\nErr: %s\nStatus: %s',
                    fname,
                    vim.inspect(err),
                    vim.inspect(status)
                ),
                vim.log.levels.ERROR,
                { title = event.match }
            )
        end
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Reload lua configs',
    group = watcher,
    pattern = 'ConfigReloader',
    callback = function(event)
        local fname = event.data.fname
        local err = event.data.err
        local status = event.data.status

        if not err or err == '' then
            -- NOTE: Could be that the file got removed or move, verify it does exist
            if require('utils.files').is_file(fname) then
                RELOAD('mappings').reload_configs(fname)
            end
        else
            vim.notify(
                string.format(
                    'fs_event failed!\n fname: %s\nErr: %s\nStatus: %s',
                    fname,
                    vim.inspect(err),
                    vim.inspect(status)
                ),
                vim.log.levels.ERROR,
                { title = event.match }
            )
        end
    end,
})

vim.api.nvim_create_autocmd({ 'User' }, {
    desc = 'Compile flags are already parsed, this autocmd sets/resets C/C++ options for all buffers',
    group = vim.api.nvim_create_augroup('ParseCompileFlags', { clear = true }),
    pattern = 'FlagsParsed',
    callback = function(event)
        local extensions = {
            c = true,
            h = true,
            cc = true,
            cpp = true,
            cxx = true,
            hpp = true,
            hxx = true,
        }

        local flags_file = event.data.flags_file
        local cpp = RELOAD 'filetypes.cpp'
        for _, buf in ipairs(vim.api.nvim_list_bufs()) do
            local bufname = vim.api.nvim_buf_get_name(buf)
            local ext = vim.fn.fnamemodify(bufname, ':e')
            if extensions[ext] then
                cpp.set_file_opts(flags_file, buf)
            end
        end
    end,
})

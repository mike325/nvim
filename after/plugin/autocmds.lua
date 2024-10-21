local nvim = require 'nvim'

if not nvim.plugins['nvim-lspconfig'] then
    vim.api.nvim_create_autocmd('FileType', {
        desc = 'Basic LSP setup when lspconfig is not install',
        group = vim.api.nvim_create_augroup('StartLSP', { clear = true }),
        pattern = '*',
        callback = function(_)
            local ft = vim.bo.filetype
            local server_idx = RELOAD('configs.lsp.utils').check_language_server(ft)
            if server_idx then
                local server = RELOAD('configs.lsp.servers')[ft][server_idx]
                local cmd, name

                if server.options and server.options.cmd then
                    cmd = server.options.cmd
                elseif server.cmd then
                    cmd = server.cmd
                elseif server.exec then
                    cmd = server.exec
                else
                    -- missing server startup cmd
                    return
                end
                if type(cmd) ~= type {} then
                    cmd = { cmd }
                end

                if server.config then
                    name = server.config
                elseif server.exec then
                    name = server.exec
                else
                    name = cmd[1]
                end

                -- TODO: Add especific ft markers, like cargo, pyproject, etc
                local markers = { '.git' }
                if server.markers then
                    vim.list_extend(markers, server.markers)
                end

                local root_dir = vim.fs.dirname(vim.fs.find(markers, { upward = true })[1]) or vim.loop.cwd()

                local opts = {
                    name = name,
                    cmd = cmd,
                    root_dir = root_dir,
                }

                local neodev = vim.F.npcall(require, 'neodev.lsp')
                if neodev and ft == 'lua' then
                    opts.before_init = neodev.before_init
                    opts.settings = { Lua = {} }
                end

                vim.lsp.start(opts)
            end
        end,
    })
end

if not nvim.plugins['nvim-treesitter'] then
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'Basic TS setup when nvim-treesitter is not install',
        group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true }),
        pattern = 'c,lua,vim,vimdoc,help,query,markdown',
        callback = function(args)
            local ft_mapping = {}
            local filetype = vim.bo[args.buf].filetype
            if nvim.has { 0, 9 } then
                ft_mapping.help = 'vimdoc'
            end
            vim.treesitter.start(args.buf, ft_mapping[filetype] or filetype)
        end,
    })
end

if not nvim.plugins['nvim-bqf'] then
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'Setup Qf mappings to navigate old/new lists',
        group = vim.api.nvim_create_augroup('QuickfixMappings', { clear = true }),
        pattern = 'qf',
        callback = function(_)
            local is_loclist = vim.fn.getwininfo(vim.api.nvim_get_current_win())[1].loclist == 1
            local cmd_prefix = is_loclist and 'l' or 'c'
            vim.keymap.set(
                'n',
                '<',
                ('<cmd>%solder<CR>'):format(cmd_prefix),
                { noremap = true, silent = true, nowait = true, buffer = true }
            )
            vim.keymap.set(
                'n',
                '>',
                ('<cmd>%snewer<CR>'):format(cmd_prefix),
                { noremap = true, silent = true, nowait = true, buffer = true }
            )
        end,
    })
end

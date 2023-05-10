local nvim = require 'nvim'
local lsp = vim.F.npcall(require, 'lspconfig')
local treesitter = vim.F.npcall(require, 'nvim-treesitter.configs')

if not lsp then
    nvim.autocmd.StartLSP = {
        event = 'FileType',
        pattern = '*',
        callback = function(args)
            local ft = vim.opt_local.filetype:get()
            local server_idx = RELOAD('plugins.lsp.utils').check_language_server(ft)
            if server_idx then
                local server = RELOAD('plugins.lsp.servers')[ft][server_idx]
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

                vim.lsp.start {
                    name = name,
                    cmd = cmd,
                    root_dir = root_dir,
                }
            end
        end,
    }
end

if not treesitter then
    nvim.autocmd.add('FileType', {
        group = 'TreesitterAutocmds',
        -- NOTE: This parsers come bundle with recent neovim releases
        pattern = 'c,viml,lua,help',
        callback = function(args)
            local ft_mapping = {}
            if nvim.has { 0, 10 } then
                ft_mapping.help = 'vimdoc'
            end
            local filetype = vim.bo[args.buf].filetype
            vim.treesitter.start(args.buf, ft_mapping[filetype] or filetype)
            -- vim.bo[args.buf].syntax = 'on'  -- only if additional legacy syntax is needed
        end,
    })
end

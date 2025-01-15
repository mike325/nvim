local nvim = require 'nvim'

if not nvim.plugins['nvim-lspconfig'] then
    vim.api.nvim_create_autocmd('FileType', {
        desc = 'Basic LSP setup when lspconfig is not install',
        group = vim.api.nvim_create_augroup('StartLSP', { clear = true }),
        pattern = '*',
        callback = function(_)
            local ft = vim.bo.filetype
            local utils = RELOAD 'configs.lsp.utils'

            local function setup_server(server)
                local opts = {}
                if server.options and type(server.options) == type {} then
                    opts = vim.deepcopy(server.options)
                    if not opts.cmd then
                        opts.cmd = utils.get_cmd(server)
                        if not opts.cmd then
                            return
                        end
                    end

                    if not opts.name then
                        opts.name = utils.get_name(server) or opts.cmd[1]
                    end

                    if not opts.root_dir then
                        opts.root_dir = utils.get_root(server)
                    end
                else
                    opts.cmd = utils.get_cmd(server)
                    if not opts.cmd then
                        return
                    end
                    opts.name = utils.get_name(server)
                    opts.root_dir = utils.get_root(server)
                end

                if ft == 'lua' then
                    local neodev = vim.F.npcall(require, 'neodev.lsp')
                    if neodev then
                        opts.before_init = neodev.before_init
                        opts.settings = { Lua = {} }
                    end
                end

                return opts
            end

            local servers = {}
            local server = utils.check_language_server(ft)
            if server then
                table.insert(servers, setup_server(server))
                if ft == 'python' and vim.fs.basename(utils.get_name(server)) ~= 'ruff' and nvim.executable 'ruff' then
                    server = utils.get_server_config(ft, 'ruff')
                    table.insert(servers, setup_server(server))
                end
            end

            if #servers > 0 then
                for _, server_config in ipairs(servers) do
                    vim.lsp.start(server_config)
                end
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

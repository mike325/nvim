local nvim = require 'nvim'

if not nvim.plugins['nvim-treesitter'] then
    vim.api.nvim_create_autocmd({ 'FileType' }, {
        desc = 'Basic TS setup when nvim-treesitter is not install',
        group = vim.api.nvim_create_augroup('TreesitterSetup', { clear = true }),
        pattern = 'c,lua,vim,vimdoc,help,query,markdown',
        callback = function(args)
            local ft_mapping = {}
            local filetype = vim.bo[args.buf].filetype
            if vim.version.ge(vim.version(), { 0, 9 }) then
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

local nvim = require 'nvim'

-- TODO: Lazy check for mini
local has_mini = nvim.plugins['mini.nvim'] ~= nil or (vim.g.minimal and vim.F.npcall(require, 'mini.git') ~= nil)

if not has_mini and not nvim.plugins['vim-fugitive'] then
    nvim.command.set('Git', function(opts) end, { bang = true, nargs = '*' })

    nvim.command.set('Gwrite', function(opts)
        local filename = (not opts.args or opts.args == '') and vim.api.nvim_buf_get_name(0) or opts.args
        if filename == '' or filename:match '^%w+://' then
            return
        end

        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        filename = (filename:gsub('^' .. cwd, ''))

        vim.cmd.write { filename, bang = opts.bang }
        require('utils.git').exec.add(filename)
    end, { bang = true, nargs = '?', complete = 'file' })
end

-- TODO: Add support to change between local and osc/remote open
-- NOTE: Override Netrw command
nvim.command.set('Open', function(opts)
    vim.ui.open(opts.args)
end, {
    nargs = 1,
    complete = 'file',
    desc = 'Open file in the default OS external program',
})

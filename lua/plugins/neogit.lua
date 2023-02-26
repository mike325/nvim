local neogit = vim.F.npcall(require, 'neogit')

if neogit == nil then
    return false
end

local nvim = require 'nvim'
local has_diffview = vim.F.npcall(require, 'diffview')

neogit.setup {
    -- disable_signs = true,
    signs = {
        --        {CLOSED, OPENED}
        section = { '❯', 'v' },
        item = { '❯', 'v' },
        -- hunk = { "", "" },
    },
    disable_commit_confirmation = true,
    integrations = {
        diffview = has_diffview ~= nil,
    },
    mappings = {
        status = {
            ['='] = 'Toggle',
        },
    },
}

if not nvim.plugins['vim-fugitive'] then
    nvim.command.set('G', function()
        require('neogit').open { kind = 'vsplit' }
    end)
end

vim.keymap.set('n', '=n', '<cmd>lua require"neogit".open({ kind = "vsplit" })<cr>', { silent = true, noremap = true })

return true

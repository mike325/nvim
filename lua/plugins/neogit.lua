local load_module = require('utils.helpers').load_module

local neogit = load_module 'neogit'

if neogit == nil then
    return false
end

local plugins = require('neovim').plugins

local set_command = require('neovim.commands').set_command
local set_mapping = require('neovim.mappings').set_mapping

local has_diffview = load_module 'diffview'

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

if not plugins['vim-fugitive'] then
    set_command {
        lhs = 'G',
        rhs = 'lua require"neogit".open({ kind = "vsplit" })',
        args = { force = true },
    }
end

set_mapping {
    mode = 'n',
    lhs = '=n',
    rhs = '<cmd>lua require"neogit".open({ kind = "vsplit" })<cr>',
    args = { silent = true, noremap = true },
}

return true

-- local nvim        = require'nvim'
-- local has_attrs   = require'tools'.tables.has_attrs
local load_module = require'tools'.helpers.load_module
-- local get_icon = require'tools'.helpers.get_icon
-- local get_separators = require'tools'.helpers.get_separators

local pears = load_module'pears'
local autopairs = load_module'nvim-autopairs'

if pears then
    pears.setup(function(conf)
        conf.expand_on_enter(false)
    end)
elseif autopairs then
    local ts_langs = require'plugins/treesitter'
    autopairs.setup{
        disable_filetype = {'TelescopePrompt', 'log'},
        check_ts = type(ts_langs) == 'table',
    }
    if ts_langs then
        require('nvim-treesitter.configs').setup {
            autopairs = {enable = true}
        }
        -- local ts_conds = require('nvim-autopairs.ts-conds')
        -- npairs.add_rules({
        --     Rule("%", "%", "lua")
        --         :with_pair(ts_conds.is_ts_node({'string','comment'})),
        --     Rule("$", "$", "lua")
        --         :with_pair(ts_conds.is_not_ts_node({'function'}))
        -- })
    end
else
    return false
end

return true

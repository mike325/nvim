local pears = vim.F.npcall(require, 'pears')
local autopairs = vim.F.npcall(require, 'nvim-autopairs')

if pears then
    pears.setup(function(conf)
        conf.expand_on_enter(false)
    end)
elseif autopairs then
    local ts_langs = require 'plugins.treesitter'
    autopairs.setup {
        disable_filetype = { 'TelescopePrompt', 'log' },
        check_ts = type(ts_langs) == 'table',
    }
    if ts_langs then
        require('nvim-treesitter.configs').setup {
            autopairs = { enable = true },
        }

        -- local endwise = require('nvim-autopairs.ts-rule').endwise
        -- autopairs.add_rules({
        --     endwise('then$', 'end', 'lua', 'if_statement'),
        --     endwise('do$', 'end', 'lua', 'for_in_statement'),
        --     endwise('do$', 'end', 'lua', 'for_statement'),
        --     endwise('^function', 'end', 'lua', 'function'),
        --     endwise('^local function', 'end', 'lua', 'local_function'),
        -- })
    end
else
    return false
end

return true

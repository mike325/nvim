local nvim = require('nvim')
local sys = require('sys')
local floating = require('floating').window

local configs = {
    iron = function(m)

        m.core.add_repl_definitions{
            python = {
                django = {
                    command = {'python3', './manage.py', 'shell'},
                },
            },
        }

        m.core.set_config({
            repl_open_cmd = 'botright split',
        })

        nvim.g.iron_map_defaults = 0
        nvim.g.iron_map_extended = 0

        nvim.nvim_set_mapping('n', 'gs', '<Plug>(iron-send-motion)')
        nvim.nvim_set_mapping('v', 'gs', '<Plug>(iron-visual-send)')
        nvim.nvim_set_mapping('n', 'gr', '<Plug>(iron-repeat-cmd)')
        nvim.nvim_set_mapping('n', '<leader><leader>l', '<Plug>(iron-send-line)')

        nvim.nvim_set_mapping('n', 'gs<CR>', '<Plug>(iron-cr)')
        nvim.nvim_set_mapping('n', 'gsq', '<Plug>(iron-exit)')

        nvim.nvim_set_mapping('n', '=r', ':IronRepl<CR><ESC>', {noremap = true, silent = true})

    end,
}

for name,setup in pairs(configs) do
    local ok, rc = pcall(require, name)
    if ok then
        setup(rc)
    end
end

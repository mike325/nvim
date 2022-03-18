local nvim = require 'neovim'
-- local sys = require 'sys'

local load_module = require('utils.helpers').load_module

-- local is_windows = sys.name == 'windows'

local lualine = load_module 'lualine'
if not lualine then
    return false
end

lualine.setup {
    globalstatus = nvim.has { 0, 7 },
    tabline = {
        lualine_a = { 'tabs' },
        lualine_b = {},
        lualine_c = { 'buffers' },
        -- lualine_z = {'buffers'},
        -- lualine_c = {'filename'},
        -- lualine_x = {},
        -- lualine_y = {},
        -- lualine_z = {'tabs'}
    },
}

local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
-- local utils = require 'lualine.utils.utils'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.trailspace =
        hl.create_component_highlight_group({ fg = palette.crust, bg = palette.peach }, 'trailspace', self.options)
end

function M:update_status()
    local space = vim.fn.search([[\s\+$]], 'nwc')
    if space ~= 0 then
        return ('%sTS'):format(
            hl.component_format_highlight(self.trailspace)
            -- hl.component_format_highlight(self.separator)
        )
    end
    return ''
end

return M

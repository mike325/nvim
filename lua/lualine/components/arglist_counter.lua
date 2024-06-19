local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.arglistcounter = hl.create_component_highlight_group({ fg = palette.sapphire }, 'arglistcounter', self.options)
end

function M:update_status()
    local arglist = statusline.arglist.component()
    if arglist ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.arglistcounter), arglist)
    end
    return ''
end

return M

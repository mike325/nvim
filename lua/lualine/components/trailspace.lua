local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.trailspace = hl.create_component_highlight_group({
        fg = palette.crust,
        bg = palette.peach,
    }, 'trailspace', self.options)
end

function M:update_status()
    local space = statusline.trailspace.component()
    if space ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.trailspace), space)
    end
    return ''
end

return M

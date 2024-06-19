local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.loc_counter = hl.create_component_highlight_group({ fg = palette.yellow }, 'loc_counter', self.options)
end

function M:update_status()
    local loc_values = statusline.loc_counter.component()
    if loc_values ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.loc_counter), loc_values)
    end
    return ''
end

return M

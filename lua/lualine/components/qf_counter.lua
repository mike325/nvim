local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.qf_counter = hl.create_component_highlight_group({ fg = palette.red }, 'qf_counter', self.options)
end

function M:update_status()
    local qf_values = statusline.qf_counter.component()
    if qf_values ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.qf_counter), qf_values)
    end
    return ''
end

return M

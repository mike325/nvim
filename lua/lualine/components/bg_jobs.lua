local M = require('lualine.component'):extend()

local statusline = require 'statusline'
local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'

function M:init(options)
    M.super.init(self, options)
    self.tasks_hl = hl.create_component_highlight_group({ fg = palette.peach }, 'tasks_hl', self.options)
end

function M:update_status()
    local text = statusline.tasks.component()
    if text ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.tasks_hl), text)
    end
    return ''
end

return M

local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'
local statusline = require 'statusline'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.mixindent = hl.create_component_highlight_group({
        fg = palette.mantle,
        bg = palette.red,
    }, 'mixindent', self.options)
end

function M:update_status()
    local mix = statusline.mixindent.component()
    if mix ~= '' then
        return ('%s%s'):format(hl.component_format_highlight(self.mixindent), mix)
    end
    return ''
end

return M

local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'
-- local utils = require 'lualine.utils.utils'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.loc_counter = hl.create_component_highlight_group({ fg = 'yellow' }, 'loc_counter', self.options)
end

function M:update_status()
    local loc_values = #vim.fn.getloclist(vim.api.nvim_get_current_win())
    if loc_values > 0 then
        return ('%s%s: %s'):format(hl.component_format_highlight(self.loc_counter), '', loc_values)
    end
    return ''
end

return M

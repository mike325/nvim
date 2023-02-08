local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'
-- local utils = require 'lualine.utils.utils'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.qf_counter = hl.create_component_highlight_group({ fg = 'orange' }, 'qf_counter', self.options)
end

function M:update_status()
    local qf_values = #vim.fn.getqflist()
    if qf_values > 0 then
        return ('%s%s: %s'):format(hl.component_format_highlight(self.qf_counter), 'QF', qf_values)
    end
    return ''
end

return M

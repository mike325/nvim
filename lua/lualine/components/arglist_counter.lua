local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'
-- local utils = require 'lualine.utils.utils'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.arglistcounter = hl.create_component_highlight_group({ fg = 'cyan' }, 'arglistcounter', self.options)
end

function M:update_status()
    local arglist_size = vim.fn.argc()
    if arglist_size > 0 then
        return ('%s%s %s:%s'):format(hl.component_format_highlight(self.arglistcounter), 'Arglist', vim.fn.argidx() + 1, arglist_size)
    end
    return ''
end

return M

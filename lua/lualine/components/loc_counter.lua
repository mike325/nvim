local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'
-- local utils = require 'lualine.utils.utils'

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.loc_counter = hl.create_component_highlight_group({ fg = 'yellow' }, 'loc_counter', self.options)
end

function M:update_status()
    local loc_values = vim.fn.getloclist(vim.api.nvim_get_current_win(), { items = 0, idx = 0 })
    if #loc_values.items > 0 then
        local valid = 0
        for _, item in ipairs(loc_values.items) do
            if item.valid == 1 then
                valid = valid + 1
            end
        end
        if valid > 0 then
            return ('%s%s %s:%s'):format(hl.component_format_highlight(self.loc_counter), 'Loc', loc_values.idx, valid)
        end
    end
    return ''
end

return M

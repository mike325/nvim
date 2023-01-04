local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'

function M:init(options)
    M.super.init(self, options)
    self.jobs_hl = hl.create_component_highlight_group({ fg = 'orange' }, 'jobs_hl', self.options)
end

function M:update_status()
    local keys = vim.tbl_keys(STORAGE.jobs) or {}
    if #keys > 0 then
        -- local icon = vim.env.NO_COOL_FONTS and 'Jobs' or require('utils.functions').get_icon('perf')
        return ('%sJobs: %s'):format(hl.component_format_highlight(self.jobs_hl), #keys)
    end
    return ''
end

return M

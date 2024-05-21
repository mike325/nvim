local M = require('lualine.component'):extend()

local palette = require('catppuccin.palettes').get_palette()
local hl = require 'lualine.highlight'

function M:init(options)
    M.super.init(self, options)
    self.jobs_hl = hl.create_component_highlight_group({ fg = palette.peach }, 'jobs_hl', self.options)
end

function M:update_status()
    local procs = #vim.api.nvim_get_proc_children(vim.loop.os_getpid())
    if procs > 0 then
        -- local icon = vim.env.NO_COOL_FONTS and 'Jobs' or require('utils.functions').get_icon('perf')
        return ('%sJobs: %s'):format(hl.component_format_highlight(self.jobs_hl), procs)
    end
    return ''
end

return M

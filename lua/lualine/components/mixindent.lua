local M = require('lualine.component'):extend()

local hl = require 'lualine.highlight'
local utils = require 'lualine.utils.utils'

-- local colors = RELOAD 'colors'
-- local tokyio = require('tokyonight.colors').setup()

function M:init(options)
    M.super.init(self, options)
    self.colors = {}
    self.mixindent = hl.create_component_highlight_group(
        { fg = 'black', bg = utils.extract_highlight_colors('ErrorMsg', 'fg') },
        'mixindent',
        self.options
    )
end

function M:update_status()
    local mix = vim.fn.search([[\v( \t|\t )]], 'nwc')
    if mix ~= 0 then
        return ('%sMix indent'):format(
            hl.component_format_highlight(self.mixindent)
            -- hl.component_format_highlight(self.separator)
        )
    end
    return ''
end

return M

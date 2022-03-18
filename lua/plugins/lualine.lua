-- local sys = require 'sys'
local nvim = require 'neovim'

local load_module = require('utils.helpers').load_module
local get_icon = require('utils.helpers').get_icon

-- local is_windows = sys.name == 'windows'

local lualine = load_module 'lualine'
if not lualine then
    return false
end

lualine.setup {
    options = {
        -- icons_enabled = true,
        -- theme = 'auto',
        component_separators = { left = '', right = '' },
        section_separators = { left = '', right = '' },
        -- component_separators = { left = ')', right = '(' },
        -- section_separators = { left = '', right = '' },
        -- component_separators = { left = '/', right = '\\' },
        -- section_separators = { left = '', right = '' },
        -- disabled_filetypes = {},
        -- always_divide_middle = true,
        -- globalstatus = false,
        globalstatus = nvim.has { 0, 7 }, -- Test how this works, not having the bufname in the window may be confusing
    },
    sections = {
        lualine_a = {
            {
                'mode',
                fmt = function(str)
                    return str:sub(1, 1):upper()
                end,
            },
        },
        lualine_b = {
            'branch',
            'diff',
            {
                'diagnostics',
                symbols = {
                    error = get_icon 'error',
                    warn = get_icon 'warn',
                    info = get_icon 'info',
                    hint = get_icon 'hint',
                },
            },
        },
        -- TODO: Add current function/class/module using TS
        lualine_c = {
            {
                'filename',
                symbols = {
                    modified = '[+]',
                    readonly = ' ' .. get_icon 'readonly',
                    unnamed = '[No Name]',
                },
            },
            'lsp_progress',
        },
        -- lualine_x = { 'encoding', 'fileformat', 'filetype' },
        -- lualine_y = { 'progress' },
        -- lualine_z = { 'location' },
    },
    -- inactive_sections = {
    --     lualine_a = {},
    --     lualine_b = {},
    --     lualine_c = { 'filename' },
    --     lualine_x = { 'location' },
    --     lualine_y = {},
    --     lualine_z = {},
    -- },
    -- -- TODO: Improve tabline to make it look more like "airline"
    tabline = {
        lualine_a = {
            {
                'tabs',
                mode = 0,
            },
        },
        lualine_b = { 'buffers' },
        -- lualine_b = {},
        -- lualine_x = {},
        -- lualine_y = {},
        -- lualine_z = {'tabs'}
    },
    extensions = {},
}

local nvim = require 'nvim'
local get_icon = require('utils.functions').get_icon
local get_separators = require('utils.functions').get_separators

local section = RELOAD 'plugins.lualine.sections'

-- TODO: Add support to live reload these functions
local lualine = vim.F.npcall(require, 'lualine')
if not lualine or vim.g.started_by_firenvim then
    return false
end

local noice = vim.F.npcall(require, 'noice')
local has_winbar = nvim.has.option 'winbar'

local noice_component
if noice then
    noice_component = {
        noice.api.statusline.mode.get,
        cond = noice.api.statusline.mode.has,
        color = { fg = '#ff9e64' },
    }
end

-- TODO: Enable auto shrink components and remove sections
-- TODO: Missing sections I would like to add
-- Improve code location with TS, module,class,function,definition,etc.
-- Backgroup Job status counter
-- Count "BUG/TODO/NOTE" indications ?

local tabline = {}
local winbar = {}
if not vim.g.started_by_firenvim then
    tabline = {
        lualine_a = {
            -- project_root,
            {
                'tabs',
                mode = 0,
                cond = function()
                    return #vim.api.nvim_list_tabpages() > 1
                end,
            },
        },
        lualine_b = {
            {
                'buffers',
                cond = function()
                    return #vim.api.nvim_list_tabpages() == 1
                end,
            },
            {
                'windows',
                cond = function()
                    return #vim.api.nvim_list_tabpages() > 1
                end,
            },
        },
        lualine_c = {},
        -- lualine_x = {},
        lualine_y = {},
        lualine_z = {
            section.project_root,
        },
    }
    if has_winbar then
        winbar = {
            lualine_a = {},
            lualine_b = {},
            lualine_c = {},
            -- lualine_x = {},
            lualine_y = {},
            lualine_z = {
                {
                    section.filename,
                    color = function()
                        return vim.bo.modified and { bg = 'orange' } or nil
                    end,
                },
            },
        }
    end
end

local component_separators = vim.env.NO_COOL_FONTS == nil and get_separators 'parenthesis' or get_icon 'bar'
local section_separators = vim.env.NO_COOL_FONTS == nil and get_separators 'circle' or ''

lualine.setup {
    options = {
        icons_enabled = vim.env.NO_COOL_FONTS == nil,
        -- theme = 'auto',
        component_separators = component_separators,
        section_separators = section_separators,
        -- disabled_filetypes = {},
        -- always_divide_middle = true,
        globalstatus = has_winbar, -- false
    },
    sections = {
        lualine_a = {
            {
                'mode',
                separator = { left = section_separators.right, right = section_separators.left },
                fmt = function(str)
                    if str:match '^%w%-%w' then
                        return str:sub(1, 1) .. str:sub(3, 3)
                    end
                    return str:sub(1, 1)
                end,
            },
            {
                section.paste,
            },
            {
                section.spell,
            },
        },
        lualine_b = {
            'cc_view',
            {
                'branch',
                fmt = function(branch)
                    local shrink
                    if #branch > 15 then
                        local patterns = {
                            '^(%w+[/-]%w+[/-]%d+[/-])',
                            '^(%w+[/-]%d+[/-])',
                            '^(%w+[/-])',
                        }
                        for _, pattern in ipairs(patterns) do
                            shrink = branch:match(pattern)
                            if shrink then
                                break
                            end
                        end
                    end
                    return shrink and branch:gsub(shrink:gsub('%-', '%%-'), '') or branch
                end,
            },
            {
                section.session,
                fmt = function(str)
                    if str ~= '' then
                        return ('S: %s'):format((str:gsub('^.+/', '')))
                    end
                    return ''
                end,
            },
            {
                'qf_counter',
                on_click = function(clicks, button, modifiers)
                    RELOAD('utils.functions').toggle_qf()
                end,
            },
            {
                'loc_counter',
                on_click = function(clicks, button, modifiers)
                    RELOAD('utils.functions').toggle_qf { win = vim.api.nvim_get_current_win() }
                end,
            },
            {
                'diff',
                on_click = function(clicks, button, modifiers)
                    local ok, gitsigns = pcall(require, 'gitsigns')
                    -- TODO: check if qf or trouble are open
                    if ok then
                        gitsigns.setqflist 'attached'
                    end
                end,
            },
            {
                -- TODO: Add support to ignore disabled namespaces
                'diagnostics',
                symbols = {
                    error = get_icon 'error',
                    warn = get_icon 'warn',
                    info = get_icon 'info',
                    hint = get_icon 'hint',
                },
                on_click = function(clicks, button, modifiers)
                    vim.diagnostic.setqflist()
                    vim.cmd.wincmd 'J'
                end,
            },
            {
                'bg_jobs',
                on_click = function(clicks, button, modifiers)
                    RELOAD('mappings').show_background_jobs()
                end,
            },
        },
        lualine_c = {
            {
                section.filename,
                color = function()
                    return vim.bo.modified and { fg = 'orange' } or nil
                end,
                fmt = function(name)
                    -- TODO: May add other pattens to avoid truncate other special names
                    if not name:match '^%w+://' then
                        return vim.fs.basename(name)
                    end
                    return name
                end,
            },
            -- where_ami,
        },
        lualine_y = {
            {
                'trailspace',
                separator = { left = section_separators.right, right = '' },
                cond = function()
                    local ft = vim.opt_local.filetype:get()
                    local ro = vim.opt_local.readonly:get()
                    local mod = vim.opt_local.modifiable:get()
                    local disable = {
                        help = true,
                        log = true,
                    }
                    return not disable[ft] and not ro and mod
                end,
            },
            {
                'mixindent',
                separator = { left = section_separators.right, right = '' },
                cond = function()
                    local ft = vim.opt_local.filetype:get()
                    local ro = vim.opt_local.readonly:get()
                    local mod = vim.opt_local.modifiable:get()
                    local disable = {
                        help = true,
                        log = true,
                    }
                    return not disable[ft] and not ro and mod
                end,
            },
            {
                section.wordcount,
                cond = function()
                    local ft = vim.opt_local.filetype:get()
                    local count = {
                        latex = true,
                        tex = true,
                        markdown = true,
                        vimwiki = true,
                    }
                    return count[ft] ~= nil
                end,
            },
            {
                'progress',
                separator = { left = section_separators.right, right = '' },
            },
        },
        lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            -- 'lsp_progress',
            noice_component,
        },
        lualine_z = {
            {
                'location',
                separator = { left = section_separators.right, right = section_separators.left },
            },
        },
    },
    tabline = tabline,
    winbar = winbar,
    extensions = { 'fugitive' }, -- 'quickfix'
}

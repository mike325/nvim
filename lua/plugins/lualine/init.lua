local nvim = require 'nvim'
local get_icon = require('utils.functions').get_icon
local get_separators = require('utils.functions').get_separators

local section = RELOAD 'plugins.lualine.sections'

-- TODO: Add support to live reload these functions
local lualine = vim.F.npcall(require, 'lualine')
if not lualine or vim.g.started_by_firenvim then
    return false
end

local has_winbar = nvim.has.option 'winbar'

-- TODO: Winbar should hold current buffer information while the statusline manage repository/workspace stuff
-- winbar info ideas
--  file path
--  local git changes (add/delete/modified lines)
--  Filetype?
--  Readonly
--  unsaved changed
--  Modifiable
--  Buffer diagnostics

-- TODO: Enable auto shrink components and remove sections
-- statusline info ideas
--  Mode
--  Spell
--  PASTE
--  Repo info: changed/untracked/staged files, stashes, current branch, pending push/pull
--  Repo diagnostics
--  Repo passed/failed tests
--  Local server status (django?)
--  Build/Compilation status
--  LSP status

-- TODO: Stuff that is buffer/window local but may go in the statusline since winbar maybe too small for this
--  File encoding
--  Cursor position
--  Line ending
--  Filetype?
-- Cursor context (TS or LSP)?
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
                    local patterns = {
                        '^(%w+[/-]%w+[/-]%d+[/-])',
                        '^(%w+[/-]%d+[/-])',
                        '^(%w+[/-])',
                    }
                    if #branch > 30 and vim.g.short_branch_name then
                        for _, pattern in ipairs(patterns) do
                            shrink = branch:match(pattern)
                            if shrink then
                                branch = shrink:sub(1, #shrink - 1)
                                break
                            end
                        end
                    elseif #branch > 15 then
                        for _, pattern in ipairs(patterns) do
                            shrink = branch:match(pattern)
                            if shrink then
                                branch = branch:gsub(vim.pesc(shrink), '')
                                break
                            end
                        end
                    end
                    return branch
                end,
                on_click = function(clicks, button, modifiers)
                    vim.g.short_branch_name = not vim.g.short_branch_name
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
            'lsp_progress',
        },
        -- lualine_x = { 'encoding', 'fileformat', 'filetype' },
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

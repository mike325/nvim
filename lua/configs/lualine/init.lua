local nvim = require 'nvim'
local get_icon = require('utils.functions').get_icon
local get_separators = require('utils.functions').get_separators
local palette = require('catppuccin.palettes').get_palette()

-- TODO: Add support to live reload these functions
local lualine = vim.F.npcall(RELOAD, 'lualine')
if not lualine or vim.g.started_by_firenvim then
    return false
end

local statusline = require 'statusline'

local noice = vim.F.npcall(require, 'noice')
local has_winbar = nvim.has.option 'winbar'

-- TODO: Winbar should hold current buffer information while the statusline manage repository/workspace stuff
-- Winbar info ideas
--  - local git changes (add/delete/modified lines)
--  - Filetype?
--  - Readonly
--  - unsaved changed
--  - Modifiable
--  - Buffer diagnostics

-- TODO: Enable auto shrink components and remove sections
-- Statusline info ideas
-- - Repo info: changed/untracked/staged files, stashes, current branch, pending push/pull
-- - Repo diagnostics
-- - Repo passed/failed tests
-- - Local server status (django?)
-- - Build/Compilation status
-- - LSP status

-- TODO: Stuff that is buffer/window local but may go in the statusline since winbar maybe too small for this
-- - File encoding
-- - Cursor position
-- - Line ending
-- - Filetype?
-- - Cursor context (TS or LSP)?
-- - Count "BUG/TODO/NOTE" indications ?

local ns = vim.api.nvim_create_namespace 'lualine_diff'
vim.api.nvim_set_hl(ns, 'StatusLineDiffAdd', { fg = palette.green, bg = palette.surface1 })
vim.api.nvim_set_hl(ns, 'StatusLineDiffChange', { fg = palette.yellow, bg = palette.surface1 })
vim.api.nvim_set_hl(ns, 'StatusLineDiffRemove', { fg = palette.red, bg = palette.surface1 })
vim.api.nvim_set_hl_ns(ns)

local noice_component
if noice then
    noice_component = {
        noice.api.statusline.mode.get,
        cond = noice.api.statusline.mode.has,
        color = { fg = palette.peach },
    }
end

local tabline = {
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
        statusline.project_root(),
    },
}

local winbar = {}
if has_winbar then
    winbar = {
        lualine_a = {},
        lualine_b = {},
        lualine_c = {},
        -- lualine_x = {},
        lualine_y = {},
        lualine_z = {
            {
                statusline.filename(),
                color = function()
                    return vim.bo.modified and { bg = palette.peach } or nil
                end,
            },
        },
    }
end

local component_separators = vim.env.NO_COOL_FONTS == nil and get_separators 'tag' or get_icon 'bar'
local section_separators = vim.env.NO_COOL_FONTS == nil and get_separators 'arrow' or ''

lualine.setup {
    options = {
        icons_enabled = vim.env.NO_COOL_FONTS == nil,
        theme = 'catppuccin', -- 'auto',
        component_separators = component_separators,
        section_separators = section_separators,
        -- disabled_filetypes = {},
        -- always_divide_middle = true,
        globalstatus = has_winbar, -- false
    },
    sections = {
        lualine_a = {
            {
                statusline.mode(),
                separator = { left = section_separators.right, right = section_separators.left },
            },
            {
                statusline.spell(),
            },
        },
        lualine_b = {
            'cc_view',
            {
                'branch',
                fmt = function(branch)
                    return statusline.git_branch.component(branch)
                end,
                on_click = function()
                    vim.g.short_branch_name = not vim.g.short_branch_name
                end,
            },
            {
                statusline.session(),
                cond = statusline.session.cond,
            },
            {
                statusline.dap(),
                cond = statusline.dap.cond,
            },
            {
                'qf_counter',
                cond = statusline.cond,
                on_click = function()
                    RELOAD('utils.qf').toggle()
                end,
            },
            {
                'loc_counter',
                cond = statusline.loc_counter.cond,
                on_click = function()
                    RELOAD('utils.qf').toggle { win = vim.api.nvim_get_current_win() }
                end,
            },
            {
                'arglist_counter',
                cond = statusline.arglist.cond,
            },
            {
                'diff',
                diff_color = {
                    added = 'StatusLineDiffAdd',
                    modified = 'StatusLineDiffChange',
                    removed = 'StatusLineDiffRemove',
                },
                on_click = function()
                    local gitsigns = vim.F.npcall(require, 'gitsigns')
                    if gitsigns then
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
                on_click = function()
                    vim.diagnostic.setqflist()
                    vim.cmd.wincmd 'J'
                end,
            },
            {
                'bg_jobs',
                on_click = function()
                    RELOAD('mappings').show_background_jobs()
                end,
            },
        },
        lualine_c = {
            {
                statusline.filename(),
                color = function()
                    return vim.bo.modified and { fg = palette.peach } or nil
                end,
                fmt = function(name)
                    -- TODO: May add other patterns to avoid truncate other special names
                    if not name:match '^%w+://' then
                        return vim.fs.basename(name)
                    end
                    return name
                end,
            },
            -- where_ami,
            'lsp_progress',
        },
        lualine_x = {
            'encoding',
            'fileformat',
            'filetype',
            'searchcount',
            noice_component,
        },
        lualine_y = {
            {
                statusline.trailspace(),
                cond = statusline.trailspace.cond,
                separator = { left = section_separators.right, right = '' },
            },
            {
                'mixindent',
                cond = statusline.mixindent.cond,
                separator = { left = section_separators.right, right = '' },
            },
            {
                statusline.wordcount(),
                cond = statusline.wordcount.cond,
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

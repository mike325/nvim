-- local sys = require 'sys'
-- local nvim = require 'neovim'

local load_module = require('utils.helpers').load_module
local get_icon = require('utils.helpers').get_icon

-- local is_windows = sys.name == 'windows'

local lualine = load_module 'lualine'
if not lualine then
    return false
end

local has_gps, gps = pcall(require, 'nvim-gps')

local function where_ami()
    if has_gps then
        return gps.is_available() and gps.get_location() or ''
    end

    local class = require('utils.treesitter').get_current_class()
    local func = require('utils.treesitter').get_current_func()
    local location = ''

    if class then
        location = location .. '  ' .. class[1]
    end

    if func then
        location = location .. ' ƒ ' .. func[1]
    end

    return location
end

local function filename()
    local buf = vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(buf)

    local modified = require('utils.buffers').is_modified(buf)
    local readonly = vim.bo[buf].readonly
    local ft = vim.bo[buf].filetype
    local buftype = vim.bo[buf].buftype

    -- TODO: Improve fugitve and other plugin support
    local plugins = {
        fugitive = 'Fugitive',
        telescope = 'Telescope',
        telescopeprompt = 'Telescope',
    }

    local filetypes = {
        gitcommit = 'COMMIT_MSG',
        GV = 'GV',
    }

    local name

    if plugins[ft:lower()] then
        return ('[%s]'):format(plugins[ft:lower()])
    elseif filetypes[ft] then
        name = filetypes[ft]
    elseif buftype == 'terminal' then
        name = 'term://' .. (bufname:gsub('term://.*:', ''))
    elseif buftype == 'help' then
        name = require('utils.files').basename(bufname)
    elseif buftype == 'prompt' then
        name = '[Prompt]'
    elseif bufname == '' then
        name = '[No Name]'
    else
        local cwd = require('utils.files').getcwd():gsub('%.', '%%.'):gsub('%-', '%%-')
        local separator = require('utils.files').separator()
        -- TODO: Cut this to respect the size
        name = vim.fn.bufname(buf)
        if name:match('^' .. cwd) then
            name = name:gsub('^' .. cwd, '')
            name = name:sub(1, 1) == separator and name:sub(2, #name) or name
        end
    end

    return name .. (modified and '[+]' or '') .. (readonly and ' ' .. get_icon 'readonly' or '')
end

local function wordcount()
    local words = vim.fn.wordcount()['words']
    return 'Words: ' .. words
end

local function trailspace()
    local space = vim.fn.search([[\s\+$]], 'nwc')
    return space ~= 0 and 'TW:' .. space or ''
end

-- TODO: Missing secctions I would like to add
-- Improve tab support to make it behave more like "airline"
-- Mixed indent (spaces with tabs)
-- Improve code location with TS, module,class,function,definition,etc.
-- Add support to indicate async job is been run in the backgroud
-- Count "BUG/TODO/NOTE" indications ?

local tabline = {}
if not vim.g.started_by_firenvim then
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
    }
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
        globalstatus = false, -- nvim.has { 0, 7 },
    },
    sections = {
        lualine_a = {
            {
                'mode',
                fmt = function(str)
                    if str:match '^%w%-%w' then
                        return str:sub(1, 1) .. str:sub(3, 3)
                    end
                    return str:sub(1, 1)
                end,
            },
            function()
                if vim.opt_local.spell:get() then
                    local lang = vim.opt_local.spelllang:get()[1] or 'en'
                    return ('Spell[%s]'):format(lang:upper())
                end
                return ''
            end,
            function()
                return vim.opt_local.paste:get() and 'PASTE' or ''
            end,
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
        lualine_c = {
            filename,
            where_ami,
            'lsp_progress',
        },
        -- lualine_x = { 'encoding', 'fileformat', 'filetype' },
        lualine_y = {
            {
                trailspace,
                cond = function()
                    local ft = vim.opt_local.filetype:get()
                    local ro = vim.opt_local.readonly:get()
                    local mod = vim.opt_local.modifiable:get()
                    local disable = {
                        help = true,
                        log = true,
                    }
                    return disable[ft] == nil and not ro and mod
                end,
            },
            {
                wordcount,
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
            'progress',
        },
        -- lualine_z = { 'location', },
    },
    -- inactive_sections = {
    --     lualine_a = {},
    --     lualine_b = {},
    --     lualine_c = { 'filename' },
    --     lualine_x = { 'location' },
    --     lualine_y = {},
    --     lualine_z = {},
    -- },
    tabline = tabline,
    extensions = { 'quickfix', 'fugitive' },
}

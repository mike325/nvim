local sys = require 'sys'
local getcwd = require('utils.files').getcwd
local get_icon = require('utils.functions').get_icon

local M = {}

-- local has_gps, gps = pcall(require, 'nvim-gps')
-- local function where_ami()
--     if has_gps then
--         return gps.is_available() and gps.get_location() or ''
--     end
--
--     local class = require('utils.treesitter').get_current_class()
--     local func = require('utils.treesitter').get_current_func()
--     local location = ''
--
--     if class then
--         location = location .. '  ' .. class[1]
--     end
--
--     if func then
--         location = location .. ' ƒ ' .. func[1]
--     end
--
--     return location
-- end

function M.filename()
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
        name = vim.fs.basename(bufname)
    elseif buftype == 'prompt' then
        name = '[Prompt]'
    elseif bufname == '' then
        name = '[No Name]'
    else
        local cwd = vim.pesc(getcwd())
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

function M.wordcount()
    local words = vim.fn.wordcount()['words']
    return 'Words: ' .. words
end

function M.project_root()
    local cwd = getcwd():gsub('\\', '/')
    return cwd:gsub(sys.home, '~')
end

function M.paste()
    return vim.opt_local.paste:get() and 'PASTE' or ''
end

function M.spell()
    if vim.opt_local.spell:get() then
        local lang = vim.opt_local.spelllang:get()[1] or 'en'
        return ('[%s]'):format(lang:upper())
    end
    return ''
end

function M.session()
    return vim.v.this_session or ''
end

return M

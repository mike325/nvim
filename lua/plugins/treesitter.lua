local nvim = require('nvim')
local plugins = require('nvim').plugins
-- local sys = require('sys')
-- local executable = require('nvim').fn.executable
-- local isdirectory = require('nvim').fn.isdirectory
-- local nvim_set_autocmd = require('nvim').nvim_set_autocmd

local function load_module(name)
    local ok, M = pcall(require, name)

    if not ok then
        return nil
    end
    return M
end

local treesitter = load_module('nvim-treesitter.configs')

if treesitter == nil then
    return nil
end

local ensure_installed = {
    'c',
    'cpp',
    'lua',
    'bash',
    'python',
}

local disable = nil
if plugins.semshi ~= nil then
    disable = {'python'}
end


treesitter.setup{
    ensure_installed = ensure_installed,
    textobjects = { enable = true },
    highlight = {
        enable = true,
        disable = disable,
    },
    refactor = {
        -- highlight_current_scope = { enable = true },
        smart_rename = {
            enable = true,
            keymaps = {
                smart_rename = "<leader>r",
            },
        },
        highlight_definitions = {
            enable = true,
            disable = disable,
        },
        navigation = {
            enable = true,
            keymaps = {
                goto_definition = "gnd",  -- TODO: Change this mappings
                list_definitions = "gnD", -- TODO: Change this mappings
                -- goto_next_usage = "<a-*>",
                -- goto_previous_usage = "<a-#>",
            },
        },
    },
}

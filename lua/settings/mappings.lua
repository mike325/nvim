local api = vim.api

local sys  = require('sys')
local nvim = require('nvim')

local parent      = require('sys').data
local mkdir       = require('nvim').fn.mkdir
local isdirectory = require('nvim').fn.isdirectory

nvim.nvim_set_mapping('n', ',', ':')
nvim.nvim_set_mapping('x', ',', ':')

nvim.nvim_set_mapping('n', 'Y', 'y$')
nvim.nvim_set_mapping('x', '$', '$h')

nvim.nvim_set_mapping('n', 'Q', 'o<ESC>')

nvim.nvim_set_mapping('n', 'J', 'm`J``')

nvim.nvim_set_mapping('n', 'jj', '<ESC>')

nvim.nvim_set_mapping('n', '<BS>', ':call mappings#bs()<CR>', {silent = true})
nvim.nvim_set_mapping('x', '<BS>', '<ESC>')

-- TODO: Check for GUIs
if sys.name == 'windows' then
    nvim.nvim_set_mapping('n', '<C-h>', ':call mappings#bs()<CR>', {silent = true})
    nvim.nvim_set_mapping('x', '<C-h>', ':<ESC>')
    nvim.nvim_set_mapping('n', '<C-z>', '<nop>')
end

if nvim.nvim_get_mapping('n', '<C-L>') == nil then
    nvim.nvim_set_mapping('n', '<C-L>', ':nohlsearch|diffupdate<CR>', {silent = true})
end

nvim.nvim_set_mapping('i', '<C-U>', '<C-G>u<C-U>')

nvim.nvim_set_mapping('n', '<C-w>o'    , ':diffoff!<BAR>only<CR>', {silent = true})
nvim.nvim_set_mapping('n', '<C-w><C-o>', ':diffoff!<BAR>only<CR>', {silent = true})

nvim.nvim_set_mapping('n', '<S-tab>', '<C-o>')

nvim.nvim_set_mapping('x', '<', '<gv')
nvim.nvim_set_mapping('x', '>', '>gv')

-- nvim.nvim_set_mapping('n', 'k', 'v:count ? (v:count > 3 ? "'.."m'"..'". v:count : "") . "k" : "gk"', {silent = true, expr = true})
-- nvim.nvim_set_mapping('n', 'j', 'v:count ? (v:count > 3 ? "'.."m'"..'". v:count : "") . "j" : "gj"', {silent = true, expr = true})

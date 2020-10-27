local nvim        = require('nvim')
local sys         = require('sys')
local load_module = require('tools').load_module

local plugins          = nvim.plugins
local isdirectory      = nvim.isdirectory
local nvim_set_autocmd = nvim.nvim_set_autocmd
local nvim_set_mapping = nvim.nvim_set_mapping
local nvim_set_command = nvim.nvim_set_command

local telescope = load_module('telescope')

if telescope == nil then
    return false
end

local lsp_languages = require('plugins/lsp')
local treesitter_languages = require('plugins/treesitter')

telescope.setup{
    defaults = {
        shorten_path = true,
    },
}

local noremap = {noremap = true}

nvim_set_mapping{
    mode = 'n',
    lhs = '<C-b>',
    rhs = [[<cmd>lua require'telescope.builtin'.buffers{}<CR>]],
    args = noremap,
}
nvim_set_mapping{
    mode = 'n',
    lhs = '<C-q>',
    rhs = [[<cmd>lua require'telescope.builtin'.quickfix{}<CR>]],
    args = noremap,
}

-- nvim_set_mapping{
--     mode = 'n',
--     lhs = '<C-l>',
--     rhs = [[<cmd>lua require'telescope.builtin'.loclist{}<CR>]],
--     args = noremap,
-- }

-- require'telescope.builtin'.command_history{}

nvim_set_command{
    lhs = 'Grep',
    rhs = [[lua require'telescope.builtin'.live_grep{}]],
    args = {force=true}
}

nvim_set_command{
    lhs = 'Oldfiles',
    rhs = [[lua require'telescope.builtin'.oldfiles{}]],
    args = {force=true}
}

nvim.nvim_set_command{
    lhs = 'GetVimFiles',
    rhs = [[lua require'telescope.builtin'.find_files{cwd = require'sys'.base, find_command = tools.to_clean_tbl(tools.select_filelist(false))}]],
    args = {force=true}
}

if isdirectory(sys.home..'/dotfiles') then
    nvim.nvim_set_command{
        lhs  = 'GetDotfiles',
        rhs  = [[lua require'telescope.builtin'.find_files{cwd = require'sys'.home..'/dotfiles', find_command = tools.to_clean_tbl(tools.select_filelist(false))}]],
        args = {force = true},
    }
end

if lsp_languages ~= nil then
    nvim_set_autocmd{
        event   = 'FileType',
        pattern = lsp_languages,
        cmd     = [[command! -buffer LSPReferences lua require'telescope.builtin'.lsp_references{}]],
        group   = 'LSPAutocmds'
    }

    nvim_set_autocmd{
        event   = 'FileType',
        pattern = lsp_languages,
        cmd     = [[command! -buffer LSPDocSymbols lua require'telescope.builtin'.lsp_document_symbols{}]],
        group   = 'LSPAutocmds'
    }

    nvim_set_autocmd{
        event   = 'FileType',
        pattern = lsp_languages,
        cmd     = [[command! -buffer LSPWorkSymbols lua require'telescope.builtin'.lsp_workspace_symbols{}]],
        group   = 'LSPAutocmds'
    }
end

if treesitter_languages ~= nil then
    nvim_set_autocmd{
        event   = 'FileType',
        pattern = treesitter_languages,
        cmd     = [[command! -buffer TSSymbols lua require'telescope.builtin'.treesitter{}]],
        group   = 'TreesitterAutocmds'
    }
end

return true

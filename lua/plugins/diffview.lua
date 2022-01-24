local load_module = require('utils.helpers').load_module

local diffview = load_module 'diffview'

if diffview == nil then
    return false
end

local nvim = require 'neovim'

-- local set_command = require'neovim.commands'.set_command
local get_mapping = require('neovim.mappings').get_mapping

local cb = require('diffview.config').diffview_callback
local has_devicons = load_module 'nvim-web-devicons'

local M = {}

local mappings = {
    ['<leader>c'] = {
        rhs = '<cmd>DiffviewClose<CR>',
        args = { noremap = true, silent = true, nowait = true },
    },
    ['<leader>q'] = {
        rhs = '<cmd>DiffviewClose<CR>',
        args = { noremap = true, silent = true, nowait = true },
    },
}

local function is_diffview()
    local ft = vim.opt_local.filetype:get()
    local tab_diffview = (ft == 'DiffviewFiles' or ft == 'DiffFileHistory')

    if not tab_diffview then
        local current_tab = nvim.get_current_tabpage()
        local wins = nvim.tab.list_wins(current_tab)

        for _, win in pairs(wins) do
            local buf_win_ft = nvim.buf.get_option(nvim.win.get_buf(win), 'filetype')
            tab_diffview = buf_win_ft == 'DiffviewFiles' or buf_win_ft == 'DiffFileHistory'
            if tab_diffview then
                break
            end
        end
    end

    return tab_diffview
end

function M.set_mappings()
    if is_diffview() and not vim.g.restore_diffview_maps then
        local diff_mappings = {}

        for map, args in pairs(mappings) do
            table.insert(diff_mappings, get_mapping { mode = 'n', lhs = map })
            pcall(vim.keymap.del, 'n', map)
            vim.keymap.set('n', map, args.rhs, args.args)
        end

        vim.g.restore_diffview_maps = diff_mappings
        local diff_ft = vim.opt_local.filetype:get()
        if diff_ft == 'DiffviewFiles' or diff_ft == 'DiffFileHistory' then
            pcall(vim.keymap.del, 'n', 'q')
            vim.keymap.set(
                'n',
                'q',
                '<cmd>DiffviewClose<CR>',
                { noremap = true, silent = true, nowait = true, buffer = true }
            )
        end
    elseif vim.g.restore_diffview_maps then
        for _, map in pairs(vim.g.restore_diffview_maps) do
            local args = {
                noremap = map.noremap,
                expr = map.expr,
                nowait = map.nowait,
                silent = map.silent,
                script = map.script,
            }
            pcall(vim.keymap.del, map.mode, map.lhs)
            vim.keymap.set(map.mode, map.lhs, map.rhs, args)
        end
        vim.g.restore_diffview_maps = nil
    end
end

diffview.setup {
    diff_binaries = false, -- Show diffs for binaries
    use_icons = has_devicons ~= nil, -- Requires nvim-web-devicons
    file_panel = {
        width = 35,
    },
    key_bindings = {
        disable_defaults = false, -- Disable the default key bindings
        -- The `view` bindings are active in the diff buffers, only when the current
        -- tabpage is a Diffview.
        -- stylua: ignore
        view = {
            ['<tab>'] = cb 'select_next_entry', -- Open the diff for the next file
            ['<s-tab>'] = cb 'select_prev_entry', -- Open the diff for the previous file
            ['<C-j>'] = cb 'select_next_entry',
            ['<C-k>'] = cb 'select_prev_entry',
            ['<leader>p'] = cb 'focus_files', -- Bring focus to the files panel
            ['<leader>f'] = cb 'toggle_files', -- Toggle the files panel.
        },
        -- stylua: ignore
        file_panel = {
            ['j'] = cb 'next_entry', -- Bring the cursor to the next file entry
            ['<down>'] = cb 'next_entry',
            ['k'] = cb 'prev_entry', -- Bring the cursor to the previous file entry.
            ['<up>'] = cb 'prev_entry',
            ['<cr>'] = cb 'select_entry', -- Open the diff for the selected entry.
            ['o'] = cb 'select_entry',
            ['<2-LeftMouse>'] = cb 'select_entry',
            ['-'] = cb 'toggle_stage_entry', -- Stage / unstage the selected entry.
            ['S'] = cb 'stage_all', -- Stage all entries.
            ['U'] = cb 'unstage_all', -- Unstage all entries.
            ['R'] = cb 'refresh_files', -- Update stats and entries in the file list.
            ['<tab>'] = cb 'select_next_entry',
            ['<s-tab>'] = cb 'select_prev_entry',
            ['<bs>'] = cb 'select_prev_entry',
            ['<C-j>'] = cb 'select_next_entry',
            ['<C-k>'] = cb 'select_prev_entry',
            ['<leader>p'] = cb 'focus_files', -- Bring focus to the files panel
            ['<leader>f'] = cb 'toggle_files', -- Toggle the files panel.
        },
    },
}

return M

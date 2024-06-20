local nvim = require 'nvim'

local sys = require 'sys'
local telescope = vim.F.npcall(require, 'telescope')

if not telescope then
    return false
end

local builtin = require 'telescope.builtin'
-- local themes = require 'telescope.themes'

local noremap = { noremap = true, silent = true }

-- local lsp_langs = require'plugins.lsp'
-- local ts_langs = require 'plugins.treesitter'
local actions = require 'telescope.actions'
-- local has_sqlite = sys.has_sqlite

local extensions = {}
local fzf = vim.F.npcall(require, 'fzf_lib')
if fzf then
    extensions.fzf = {
        fuzzy = true, -- false will only do exact matching
        override_generic_sorter = true, -- override the generic sorter
        override_file_sorter = true, -- override the file sorter
        case_mode = 'smart_case', -- or "ignore_case" or "respect_case"
    }
end

telescope.setup {
    extensions = extensions,
    layout_config = {
        prompt_position = 'bottom',
        prompt_prefix = '>',
    },
    defaults = {
        -- history = history,
        vimgrep_arguments = require('utils.functions').select_grep(false, 'grepprg', true),
        selection_strategy = 'reset',
        sorting_strategy = 'descending',
        layout_strategy = 'horizontal',
        -- file_ignore_patterns = {},
        file_sorter = not fzf and require('telescope.sorters').get_fzy_sorter or nil,
        generic_sorter = not fzf and require('telescope.sorters').get_fzy_sorter or nil,
        -- shorten_path = true,
        winblend = 0,
        set_env = { ['COLORTERM'] = 'truecolor' },
        mappings = {
            i = {
                ['<ESC>'] = actions.close,
                -- ["<CR>"]  = actions.goto_file_selection_edit + actions.center,
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
                ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            },
            n = {
                ['<ESC>'] = actions.close,
                ['<C-q>'] = actions.smart_send_to_qflist + actions.open_qflist,
            },
        },
    },
}

if vim.F.npcall(require, 'harpoon') then
    require('telescope').load_extension 'harpoon'
end

if fzf then
    require('telescope').load_extension 'fzf'
end

vim.keymap.set('n', '<C-q>', builtin.quickfix, noremap)

vim.keymap.set('n', '<leader><C-r>', function()
    builtin.resume()
end, noremap)

vim.keymap.set('n', '<leader>g', function()
    local grepprg = vim.tbl_filter(function(k)
        return not k:match '^%s*$'
    end, vim.split(vim.bo.grepprg or vim.o.grepprg, '%s+'))
    builtin.live_grep(grepprg)
end, noremap)

vim.keymap.set('n', '<C-p>', function()
    local is_git = vim.t.is_in_git
    builtin.find_files {
        find_command = RELOAD('utils.functions').select_filelist(is_git, true),
    }
end, noremap)

vim.keymap.set('n', '<leader><C-p>', function()
    local finder = RELOAD('utils.functions').select_filelist(false, true)
    if finder[1] == 'fd' or finder[1] == 'fdfind' or finder[1] == 'rg' then
        table.insert(finder, '-uuu')
    end
    builtin.find_files { find_command = finder }
end, noremap)

vim.keymap.set('n', '<C-b>', function()
    builtin.buffers {}
end, noremap)

nvim.command.set('Registers', function()
    require('telescope.builtin').registers(require('telescope.themes').get_dropdown {})
end)

nvim.command.set('Marks', function()
    require('telescope.builtin').marks()
end)

nvim.command.set('Manpages', function()
    require('telescope.builtin').man_pages {}
end)

nvim.command.set('NeovimConfig', function()
    builtin.find_files {
        cwd = sys.base,
        find_command = RELOAD('utils.functions').select_filelist(false, true),
    }
end)

local host_plugins = sys.data .. '/site/pack/host'
if require('utils.files').is_dir(host_plugins) then
    nvim.command.set('HostFiles', function()
        builtin.find_files {
            cwd = host_plugins,
            find_command = RELOAD('utils.functions').select_filelist(false, true),
        }
    end)
end

nvim.command.set('LuaReloaded', function()
    require('telescope.builtin').reloader()
end)

nvim.command.set('HelpTags', function()
    builtin.help_tags {}
end)

-- if executable 'git' then
--     vim.keymap.set('n', '<leader>c', builtin.git_bcommits, noremap)
--     vim.keymap.set('n', '<leader>C', builtin.git_commits, noremap)
--     vim.keymap.set('n', '<leader>b', builtin.git_branches, noremap)
-- end

return true

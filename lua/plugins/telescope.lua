local nvim = require 'neovim'

local sys = require 'sys'
local executable = require('utils.files').executable
local load_module = require('utils.functions').load_module

local telescope = load_module 'telescope'

if not telescope then
    return false
end

-- local plugins = require('neovim').plugins
local builtin = require 'telescope.builtin'
-- local themes = require 'telescope.themes'

local noremap = { noremap = true, silent = true }

if load_module 'harpoon' then
    require('telescope').load_extension 'harpoon'
end

-- local lsp_langs = require'plugins.lsp'
-- local ts_langs = require 'plugins.treesitter'
local actions = require 'telescope.actions'
-- local has_sqlite = sys.has_sqlite
-- local extensions = {}

telescope.setup {
    -- extensions = extensions,
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
        file_sorter = require('telescope.sorters').get_fzy_sorter,
        generic_sorter = require('telescope.sorters').get_fzy_sorter,
        -- shorten_path = true,
        winblend = 0,
        set_env = { ['COLORTERM'] = 'truecolor' },
        mappings = {
            i = {
                ['<ESC>'] = actions.close,
                -- ["<CR>"]  = actions.goto_file_selection_edit + actions.center,
                ['<C-j>'] = actions.move_selection_next,
                ['<C-k>'] = actions.move_selection_previous,
            },
            n = {
                ['<ESC>'] = actions.close,
            },
        },
    },
}

vim.keymap.set('n', '<leader>g', builtin.live_grep, noremap)
vim.keymap.set('n', '<C-q>', builtin.quickfix, noremap)

vim.keymap.set('n', '<C-p>', function()
    local is_git = vim.b.project_root and vim.b.project_root.is_git or false
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

nvim.command.set('Oldfiles', function()
    require('telescope.builtin').oldfiles {}
end)

nvim.command.set('Registers', function()
    require('telescope.builtin').registers(require('telescope.themes').get_dropdown {})
end)

nvim.command.set('Marks', function()
    require('telescope.builtin').marks(require('telescope.themes').get_dropdown {})
end)

nvim.command.set('Manpages', function()
    require('telescope.builtin').man_pages {}
end)

nvim.command.set('GetVimFiles', function()
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

if executable 'git' then
    vim.keymap.set('n', '<leader>c', builtin.git_bcommits, noremap)
    vim.keymap.set('n', '<leader>C', builtin.git_commits, noremap)
    vim.keymap.set('n', '<leader>b', builtin.git_branches, noremap)
end

return true

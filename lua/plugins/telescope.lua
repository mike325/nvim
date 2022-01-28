local sys = require 'sys'
local executable = require('utils.files').executable
local load_module = require('utils.helpers').load_module

-- local set_autocmd = require('neovim.autocmds').set_autocmd
local set_command = require('neovim.commands').set_command

local telescope = load_module 'telescope'

if not telescope then
    return false
end

local plugins = require('neovim').plugins
local builtin = require 'telescope.builtin'
-- local themes = require 'telescope.themes'

local noremap = { noremap = true, silent = true }

-- local lsp_langs = require'plugins.lsp'
-- local ts_langs = require 'plugins.treesitter'
local actions = require 'telescope.actions'
local has_sqlite = sys.has_sqlite
local extensions = {}
local history
if has_sqlite then
    if plugins['telescope-smart-history.nvim'] then
        history = {
            path = sys.db_root .. '/telescope_history.sqlite3',
            limit = 100,
        }
    end

    if plugins['telescope-frecency.nvim'] then
        extensions.frecency = {
            -- disable_devicons = false,
            db_root = sys.db_root,
            workspaces = {
                ['nvim'] = sys.base,
                ['dotfiles'] = sys.home .. '/dotfiles/',
            },
        }
        vim.keymap.set('n', '<leader>x', require('telescope').extensions.frecency.frecency, noremap)
    end
end

telescope.setup {
    extensions = extensions,
    layout_config = {
        prompt_position = 'bottom',
        prompt_prefix = '>',
    },
    defaults = {
        history = history,
        vimgrep_arguments = require('utils.helpers').select_grep(false, 'grepprg', true),
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

set_command {
    lhs = 'LuaReloaded',
    rhs = [[lua require'telescope.builtin'.reloader()]],
    args = { force = true },
}

set_command {
    lhs = 'HelpTags',
    rhs = function()
        builtin.help_tags {}
    end,
    args = { force = true },
}

vim.keymap.set('n', '<C-p>', function()
    local is_git = vim.b.project_root and vim.b.project_root.is_git or false
    builtin.find_files {
        find_command = require('utils.helpers').select_filelist(is_git, true),
    }
end, noremap)

vim.keymap.set('n', '<C-b>', function()
    builtin.current_buffer_fuzzy_find {}
end, noremap)
vim.keymap.set('n', '<leader>g', builtin.live_grep, noremap)
vim.keymap.set('n', '<C-q>', builtin.quickfix, noremap)

set_command {
    lhs = 'Oldfiles',
    rhs = [[lua require'telescope.builtin'.oldfiles{}]],
    args = { force = true },
}

set_command {
    lhs = 'Registers',
    rhs = [[lua require'telescope.builtin'.registers(require'telescope.themes'.get_dropdown{})]],
    args = { force = true },
}

set_command {
    lhs = 'Marks',
    rhs = [[lua require'telescope.builtin'.marks(require'telescope.themes'.get_dropdown{})]],
    args = { force = true },
}

set_command {
    lhs = 'Manpages',
    rhs = [[lua require'telescope.builtin'.man_pages{}]],
    args = { force = true },
}

set_command {
    lhs = 'GetVimFiles',
    rhs = function()
        builtin.find_files {
            cwd = sys.base,
            find_command = require('utils.helpers').select_filelist(false, true),
        }
    end,
    args = { force = true },
}

if executable 'git' then
    vim.keymap.set('n', '<leader>c', builtin.git_bcommits, noremap)
    vim.keymap.set('n', '<leader>C', builtin.git_commits, noremap)
    vim.keymap.set('n', '<leader>b', builtin.git_branches, noremap)
end

return true

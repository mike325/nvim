local nvim             = require('nvim')
local load_module      = require('tools').load_module
-- local sys = require('sys')

local plugins          = nvim.plugins
local nvim_set_autocmd = nvim.nvim_set_autocmd
-- local executable       = nvim.executable
-- local isdirectory      = nvim.isdirectory

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

if plugins['vim-lsp-cxx-highlight'] ~= nil then
    disable = disable == nil and {'c', 'cpp'} or vim.list_extend(disable, {'c', 'cpp'})
end

local commet_txtobj = nil
if plugins['vim-textobj-comment'] == nil then
    commet_txtobj = '@comment.outer'
end

treesitter.setup{
    ensure_installed = ensure_installed,
    highlight = {
        enable = true,
        -- disable = disable,
    },
    textobjects = {
        -- enable = true,
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@function.outer",
                ["if"] = "@function.inner",
                ["as"] = "@class.outer",
                ["is"] = "@class.inner",
                ["ia"] = "@parameter.inner",
                ["aa"] = "@parameter.inner",
                ["ir"] = "@loop.inner",
                ["ar"] = "@loop.outer",
                ["ac"] = commet_txtobj,
                ["ic"] = commet_txtobj,
            },
        },
        move = {
            enable = true,
            goto_next_start = {
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
                ["]r"] = "@loop.outer",
                ["]a"] = "@parameter.inner",
                ["]c"] = "@comment.outer",
            },
            goto_next_end = {
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
                ["]R"] = "@loop.outer",
                ["]A"] = "@parameter.inner",
                ["]C"] = "@comment.outer",
            },
            goto_previous_start = {
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
                ["[r"] = "@loop.outer",
                ["[a"] = "@parameter.inner",
                ["[c"] = "@comment.outer",
            },
            goto_previous_end = {
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
                ["[R"] = "@loop.outer",
                ["[A"] = "@parameter.inner",
                ["[C"] = "@comment.outer",
            },
        },
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
                goto_definition     = "<A-d>",
                list_definitions    = "<A-l>",
                goto_next_usage     = "<A-*>",
                goto_previous_usage = "<A-#>",
            },
        },
    },
}

if ensure_installed.bash ~= nil then
    ensure_installed[#ensure_installed + 1] = 'sh'
end

nvim_set_autocmd(
    'FileType',
    ensure_installed,
    'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
    {group = 'TreesitterAutocmds', create = true}
)

return ensure_installed

local nvim        = require'nvim'
local load_module = require'tools'.helpers.load_module
local has_attrs   = require'tools'.tables.has_attrs

local plugins          = nvim.plugins
local nvim_set_autocmd = nvim.nvim_set_autocmd

local treesitter = load_module('nvim-treesitter.configs')

if treesitter == nil then
    return false
end

local ensure_installed = {
    'c',
    'cpp',
    'lua',
    'bash',
    'python',
    -- 'query',
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
    indent = {
        enable = true
    },
    highlight = {
        enable = true,
        disable = disable,
    },
    textobjects = {
        swap = {
            enable = true,
            swap_next = {
                ["<leader>a"] = "@parameter.inner",
                ["<leader>m"] = "@function.outer",
            },
            swap_previous = {
                ["<leader><leader>a"] = "@parameter.inner",
                ["<leader><leader>m"] = "@function.outer",
            },
        },
        select = {
            enable = true,
            keymaps = {
                ["af"] = "@conditional.outer",
                ["if"] = "@conditional.inner",
                ["am"] = "@function.outer",    -- Same as [m, ]m "method"
                ["im"] = "@function.inner",
                ["as"] = "@class.outer",
                ["is"] = "@class.inner",
                ["ia"] = "@parameter.inner",
                ["aa"] = "@parameter.inner",
                ["ir"] = "@loop.inner",        -- "repeat" mnemonic
                ["ar"] = "@loop.outer",
                ["ac"] = commet_txtobj,
                ["ic"] = commet_txtobj,
            },
        },
        move = {
            enable = true,
            goto_next_start = {
                ["]f"] = "@conditional.outer",
                ["]m"] = "@function.outer",
                ["]]"] = "@class.outer",
                ["]r"] = "@loop.outer",
                ["]a"] = "@parameter.inner",
                ["]c"] = "@comment.outer",
            },
            goto_next_end = {
                ["]F"] = "@conditional.outer",
                ["]M"] = "@function.outer",
                ["]["] = "@class.outer",
                ["]R"] = "@loop.outer",
                ["]A"] = "@parameter.inner",
                ["]C"] = "@comment.outer",
            },
            goto_previous_start = {
                ["[f"] = "@conditional.outer",
                ["[m"] = "@function.outer",
                ["[["] = "@class.outer",
                ["[r"] = "@loop.outer",
                ["[a"] = "@parameter.inner",
                ["[c"] = "@comment.outer",
            },
            goto_previous_end = {
                ["[F"] = "@conditional.outer",
                ["[M"] = "@function.outer",
                ["[]"] = "@class.outer",
                ["[R"] = "@loop.outer",
                ["[A"] = "@parameter.inner",
                ["[C"] = "@comment.outer",
            },
        },
        -- lsp_interop = {
        --     enable = true,
        --     peek_definition_code = {
        --         ["df"] = "@function.outer",
        --         ["dF"] = "@class.outer",
        --     },
        -- },
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
                goto_definition      = "<A-d>",
                list_definitions     = "<A-l>",
                -- list_definitions_toc = "<A-t>",
                goto_next_usage      = "<A-n>",
                goto_previous_usage  = "<A-N>",
            },
        },
    },
}

if has_attrs(ensure_installed, 'bash') then
    ensure_installed[#ensure_installed + 1] = 'sh'
end

nvim_set_autocmd{
    event   = 'FileType',
    pattern = ensure_installed,
    cmd     = 'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
    group   = 'TreesitterAutocmds',
}

return ensure_installed

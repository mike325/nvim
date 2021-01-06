local nvim        = require'nvim'
local load_module = require'tools'.helpers.load_module

local plugins          = nvim.plugins
local nvim_set_autocmd = nvim.nvim_set_autocmd

local treesitter = load_module'nvim-treesitter.configs'

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
        enable = false
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

local parsers = require'nvim-treesitter.parsers'

local fts = {}

for lang,opts in pairs(parsers.list) do
    if parsers.has_parser(lang) then
        if opts.filetype ~= nil then
            lang = opts.filetype
        end
        fts[#fts + 1] = lang
        if opts.used_by ~= nil then
            vim.list_extend(fts, opts.used_by)
        end
    end
end

if #fts > 0 then
    -- TODO: Check module availability for each language
    nvim_set_autocmd{
        event   = 'FileType',
        pattern = fts,
        cmd     = 'setlocal foldmethod=expr foldexpr=nvim_treesitter#foldexpr()',
        group   = 'TreesitterAutocmds',
    }
end

return fts

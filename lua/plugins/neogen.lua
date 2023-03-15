-- local nvim = require 'nvim'

local neogen = vim.F.npcall(require, 'neogen')
if not neogen then
    return false
end

neogen.setup {
    enabled = true,
    snippet_engine = 'luasnip',
    input_after_comment = true,
    languages = {
        lua = {
            template = {
                annotation_convention = vim.g.lua_annotation or 'emmylua',
            },
        },
        python = {
            template = {
                annotation_convention = vim.g.python_annotation or 'google_docstrings',
            },
        },
    },
}

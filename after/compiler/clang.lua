local nvim = require'neovim'

-- if vim.fn.exists(":CompilerSet") ~= 2 then
--     vim.cmd[[command! -nargs=* CompilerSet setlocal <args>]]
-- end

local cmd = {
    'clang'
}

vim.list_extend(cmd, RELOAD'filetypes.cpp'.default_flags.clang)
table.insert(cmd, '%')

nvim.ex.CompilerSet('makeprg='..table.concat(cmd, '\\ '))

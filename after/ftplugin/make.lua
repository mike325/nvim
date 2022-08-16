local executable = require('utils.files').executable

vim.opt_local.expandtab = true

if executable 'make' then
    RELOAD('filetypes.make').setup()
end

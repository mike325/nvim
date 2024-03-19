local executable = require('utils.files').executable

if executable 'make' then
    local ft = vim.opt_local.filetype:get()
    require('utils.buffers').setup(ft, {
        expandtab = true,
    })
end

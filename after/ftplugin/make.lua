local executable = require('utils.files').executable

if executable 'make' then
    local ft = vim.bo.filetype
    require('utils.buffers').setup(ft, {
        expandtab = true,
    })
end

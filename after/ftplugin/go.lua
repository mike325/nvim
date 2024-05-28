local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    expandtab = false,
    tabstop = 4,
    shiftwidth = 0,
    softtabstop = -1,
})

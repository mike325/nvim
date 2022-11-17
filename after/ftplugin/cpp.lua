-- local nvim = require 'neovim'

local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    commentstring = '// %s',
})

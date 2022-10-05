local nvim = require 'neovim'

local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    commentstring = '// %s',
})

if nvim.has { 0, 8 } then
    local related_utils = RELOAD 'threads.related'
    related_utils.async_lookup_alternate()
end

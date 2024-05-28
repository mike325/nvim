local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    commentstring = '// %s',
})

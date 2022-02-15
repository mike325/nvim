local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\(#\s*define\|[a-z]*\s*const\(expr\)\?\s*[a-z]*\)]],
    includeexpr = [[substitute(v:fname,'\.','/','g')]],
    commentstring = '// %s',
})

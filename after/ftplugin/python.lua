vim.opt_local.suffixesadd:prepend '.py'
vim.opt_local.suffixesadd:prepend '__init__.py'

local ft = vim.bo.filetype
require('utils.buffers').setup(ft, {
    define = [[^\s*\<\(def\|class\)\>]],
    makeprg = [[python3 -c "import py_compile,sys; sys.stderr=sys.stdout; py_compile.compile(r'%')"]],
    errorformat = '%C %.%#,%A  File "%f", line %l%.%#,%Z%[%^ ]%@=%m',
})

vim.keymap.set('ia', 'false', 'False', { buffer = true })
vim.keymap.set('ia', 'true', 'True', { buffer = true })

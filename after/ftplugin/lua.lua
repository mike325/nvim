vim.opt_local.suffixesadd:prepend '.lua'
vim.opt_local.suffixesadd:prepend 'init.lua'
vim.opt_local.path:prepend(require('sys').base .. '/lua')

local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]],
    includeexpr = [[substitute(v:fname,'\.','/','g')]],
})

vim.opt_local.suffixesadd:prepend '.lua'
vim.opt_local.suffixesadd:prepend 'init.lua'

local lua_runtime = vim.split(package.path, ';')
lua_runtime = vim.tbl_map(function(p)
    return p:gsub('\\', '/'):gsub('%?.*', '')
end, lua_runtime)

local runtimepaths = vim.api.nvim_get_runtime_file('', true)
runtimepaths = vim.tbl_map(function(p)
    return p:gsub('\\', '/') .. '/lua'
end, runtimepaths)

vim.opt_local.path:prepend { './lua/', '.' }
vim.opt_local.path:prepend(require('utils.tables').merge_uniq_list(runtimepaths, lua_runtime))

local ft = vim.opt_local.filetype:get()
require('utils.buffers').setup(ft, {
    define = [[^\s*\(local\s\+\)\?\(function\s\+\(\i\+[.:]\)\?\|\ze\i\+\s*=\s*\|\(\i\+[.:]\)\?\ze\s*=\s*\)]],
    -- TODO: this includeexpr does not include /init.lua files
    includeexpr = [[substitute(v:fname,'\.','/','g')]],
})

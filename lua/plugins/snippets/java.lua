local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

if not ls.snippets.c then
    require 'plugins.snippets.c'
end

ls.filetype_extend('java', { 'c' })

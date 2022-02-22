local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

if not ls.snippets.c then
    require 'plugins.snippets.c'
end

ls.filetype_extend('cpp', { 'c' })

-- local clike = RELOAD 'plugins.snippets.c_like'
-- for _, csnip in ipairs(clike) do
--     local has_snip = false
--     for _, snip in ipairs(ls.snippets.c) do
--         if snip.dscr == csnip.dscr then
--             has_snip = true
--             break
--         end
--     end
--     if not has_snip then
--         table.insert(ls.snippets.c, csnip)
--     end
-- end

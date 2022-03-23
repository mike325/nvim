local load_module = require('utils.helpers').load_module
local ls = load_module 'luasnip'
if not ls then
    return false
end

local snippets = {}

local clike = RELOAD 'plugins.snippets.c_like'
for _, csnip in ipairs(clike) do
    local has_snip = false
    for _, snip in ipairs(snippets) do
        if snip.dscr == csnip.dscr then
            has_snip = true
            break
        end
    end
    if not has_snip then
        table.insert(snippets, csnip)
    end
end

ls.add_snippets('java', snippets, { key = 'java_init' })

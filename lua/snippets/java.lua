local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

local snippets = {}

local clike = RELOAD 'configs.luasnip.c_like'
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

-- ls.add_snippets('java', snippets, { key = 'java_init' })
return snippets

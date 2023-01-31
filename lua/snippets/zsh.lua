local ls = vim.F.npcall(require, 'luasnip')
if not ls then
    return false
end

if #ls.get_snippets 'sh' == 0 then
    ls.add_snippets('sh', require 'snippets.sh')
end

ls.filetype_extend('zsh', { 'sh' })
return

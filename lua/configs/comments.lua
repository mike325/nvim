local comment = vim.F.npcall(require, 'Comment')
if not comment then
    return false
end

comment.setup {}

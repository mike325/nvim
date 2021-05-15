local load_module = require'tools'.helpers.load_module

local todo = load_module'todo-comments'

if not todo then
    return false
end

todo.setup{
    signs = false,
    highlight = {
        keyword = "bg",
    },
}

return true

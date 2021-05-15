local load_module = require'tools'.helpers.load_module

local todo = load_module'todo-comments'

if not todo then
    return false
end

local nvim  = require'nvim'
local set_mapping = nvim.mappings.set_mapping
local has_trouble = load_module'trouble'

todo.setup{
    signs = false,
    highlight = {
        keyword = "bg",
    },
}

if has_trouble then
    set_mapping{
        mode = 'n',
        lhs = '=T',
        rhs = function()
            local trouble_open = false
            for _,win in pairs(nvim.tab.list_wins(0)) do
                local buf = nvim.win.get_buf(win)
                if nvim.buf.get_option(buf, 'filetype') == 'Trouble' then
                    trouble_open = true
                    nvim.ex.TroubleClose()
                    break
                end
            end
            if not trouble_open then
                nvim.ex.TodoTrouble()
            end
        end,
        args = {noremap = true, silent = true}
    }
end

return true

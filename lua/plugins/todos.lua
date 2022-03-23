local load_module = require('utils.helpers').load_module

local todo = load_module 'todo-comments'

if not todo then
    return false
end

local nvim = require 'neovim'
local has_trouble = load_module 'trouble'

todo.setup {
    signs = false,
    highlight = {
        keyword = 'bg',
    },
}

if has_trouble then
    vim.keymap.set('n', '=t', function()
        local trouble_open = false
        for _, win in pairs(nvim.tab.list_wins(0)) do
            local buf = nvim.win.get_buf(win)
            if vim.bo[buf].filetype == 'Trouble' then
                trouble_open = true
                nvim.ex.TroubleClose()
                break
            end
        end
        if not trouble_open then
            nvim.ex.TodoTrouble()
        end
    end, { noremap = true, silent = true })
end

return true

local nvim = require 'neovim'

local utils = RELOAD 'utils.functions'
local load_module = utils.load_module
local get_icon = utils.get_icon

local todo = load_module 'todo-comments'

if not todo then
    return false
end

todo.setup {
    signs = false,
    highlight = {
        keyword = 'bg',
    },
    keywords = {
        FIX = {
            icon = get_icon 'bug', -- icon used for the sign, and in search results
            color = 'error', -- can be a hex color, or a named color (see below)
            alt = { 'FIXME', 'BUG', 'FIXIT', 'ISSUE' }, -- a set of other keywords that all map to this FIX keywords
            -- signs = false, -- configure signs for some keywords individually
        },
        TODO = { icon = get_icon 'todo', color = 'info', alt = { '8AC0FFEE', 'BEBECAFE' } },
        HACK = { icon = get_icon 'hack', color = 'warning' },
        WARN = { icon = get_icon 'warn', color = 'warning', alt = { 'WARNING', 'XXX' } },
        PERF = { icon = get_icon 'perf', color = 'hint', alt = { 'OPTIM', 'PERFORMANCE', 'OPTIMIZE' } },
        NOTE = { icon = get_icon 'note', color = 'hint', alt = { 'INFO' } },
        TEST = { icon = get_icon 'test', color = 'test', alt = { 'TESTING', 'PASSED', 'FAILED' } },
    },
}

vim.keymap.set('n', ']t', function()
    require('todo-comments').jump_next { keywords = { 'TODO', '8AC0FFEE', 'BEBECAFE' } }
end, { desc = 'Next todo comment' })

vim.keymap.set('n', '[t', function()
    require('todo-comments').jump_prev { keywords = { 'TODO', '8AC0FFEE', 'BEBECAFE' } }
end, { desc = 'Previous todo comment' })

vim.keymap.set('n', '=t', function()
    local has_trouble = load_module 'trouble'
    local has_telescope = load_module 'telescope'

    if has_telescope then
        nvim.ex.TodoTelescope()
    elseif has_trouble then
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
    else
        nvim.ex.TodoQuickfix()
    end
end, { noremap = true, silent = true, desc = "Display all available TODO's labels" })

return true

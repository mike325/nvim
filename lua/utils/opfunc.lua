local M = {}

function M.grep(_, visual)
    local nvim = require 'nvim'

    local select_save = vim.o.selection
    vim.o.selection = 'inclusive'

    local search, s_row, s_col, e_row, e_col
    if visual then
        local startpos = nvim.fn.getpos "'<"
        local endpos = nvim.fn.getpos "'>"
        s_row, s_col, e_row, e_col = startpos[2] - 1, startpos[3] - 1, endpos[2] - 1, endpos[3]
    else
        local startpos = nvim.buf.get_mark(0, '[')
        local endpos = nvim.buf.get_mark(0, ']')
        s_row, s_col, e_row, e_col = startpos[1] - 1, startpos[2], endpos[1] - 1, endpos[2] + 1
    end

    search = nvim.buf.get_text(0, s_row, s_col, e_row, e_col, {})[1]
    require('utils.async').grep { search = search }

    vim.o.selection = select_save
end

return M

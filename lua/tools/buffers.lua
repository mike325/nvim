local M = {}

function M.last_position()
    local sc_mark   = require'nvim'.buf.get_mark(0, "'")
    local dc_mark   = require'nvim'.buf.get_mark(0, '"')
    local last_line = require'nvim'.fn.line('$')
    local filetype  = require'nvim'.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark[1] >= 1 and dc_mark[1] <= last_line and black_list[filetype] == nil then
        require'nvim'.win.set_cursor(0, dc_mark)
    end
end

function M.bufloaded(bufnr)
    return require'nvim'.fn.bufloaded(bufnr) == 1
end

return M

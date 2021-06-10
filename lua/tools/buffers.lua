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
    -- assert(type(bufnr) == type(1) and bufnr > 0, 'Invalid buffer')
    return require'nvim'.fn.bufloaded(bufnr) == 1
end

function M.is_modified(bufnr)
    assert(not bufnr or (type(bufnr) == type(1) and bufnr > 0), 'Invalid buffer')
    bufnr = bufnr or require'nvim'.get_current_buf()
    return require'nvim'.buf.get_option(bufnr, 'modified')
end

function M.delete(buffer, wipe)
    assert(not buffer or (type(buffer) == type(1) and buffer > 0), 'Invalid buffer')
    local nvim = require'nvim'
    buffer = buffer or nvim.get_current_buf()
    local is_wipe = nvim.buf.get_option(buffer, 'bufhidden') == 'wipe'
    local prev_buf = nvim.fn.expand('#') ~= '' and nvim.fn.bufnr(nvim.fn.expand('#')) or -1
    local is_loaded = nvim.buf.is_loaded

    if nvim.get_current_buf() == buffer then
        local new_view = is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)
        nvim.win.set_buf(0, new_view)
    end

    if not is_wipe then
        local action = not wipe and {unload = true} or {force = true}
        nvim.buf.delete(buffer, action)
    end
end

function M.get_option(option, default)
    local ok, opt = pcall(vim.api.nvim_buf_get_option, 0, option)
    if not ok then
        ok, opt = pcall(vim.api.nvim_get_option, 0, option)
        if not ok then
            opt = default
        end
    end
    return opt
end

return M

local M = {}

function M.get_global_marks()
    local marks = {}
    local cwd = vim.pesc(vim.uv.cwd() .. '/')
    for idx = vim.fn.char2nr 'A', vim.fn.char2nr 'Z' do
        local letter = vim.fn.nr2char(idx)
        local mark = vim.api.nvim_get_mark(letter, {})
        local filename = mark[4]
        if filename ~= '' and require('utils.files').is_file(filename) then
            filename = (filename:gsub('^' .. cwd, ''))
            marks[filename] = {
                letter = letter,
                row = mark[1],
                col = mark[2],
                buf = mark[3] == 0 and vim.api.nvim_get_current_buf() or mark[3],
                filename = filename,
            }
        end
    end
    return marks
end

function M.clear(opts)
    opts = opts or {}

    local deleted_marks = 0
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        for filename, mark in pairs(marks) do
            if not opts.bang then
                if filename ~= '' and not require('utils.files').is_file(filename) then
                    deleted_marks = deleted_marks + 1
                    vim.api.nvim_del_mark(mark.letter)
                else
                    vim.api.nvim_del_mark(mark.letter)
                end
            end
        end
    end
    return deleted_marks
end

function M.marks_to_arglist(opts)
    opts = opts or {}
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        M.add(vim.tbl_keys(marks), opts.clear)
    end
end

function M.marks_to_quickfix(opts)
    opts = opts or {}
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        local items = {}
        for filename, mark in pairs(marks) do
            filename = (filename:gsub('^' .. cwd, ''))
            local item = {
                filename = filename,
                text = filename,
                lnum = mark.row,
                col = mark.col,
                valid = true,
            }
            table.insert(items, item)
        end
        RELOAD('utils.qf').set_list {
            items = items,
            title = 'Marks',
            open = true,
        }
    end
end

return M

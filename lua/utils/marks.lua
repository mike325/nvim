local M = {}

local marks_default_loc = 'marks.json'

function M.get_global_marks(all)
    local marks = {}
    local cwd = vim.pesc(vim.uv.cwd() .. '/')
    for idx = vim.fn.char2nr 'A', vim.fn.char2nr 'Z' do
        local letter = vim.fn.nr2char(idx)
        local mark = vim.api.nvim_get_mark(letter, {})
        local filename = mark[4]
        if all or (filename ~= '' and require('utils.files').is_file(filename)) then
            filename = (filename:gsub('^' .. cwd, ''))
            marks[letter] = {
                lnum = mark[1],
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
    local marks = M.get_global_marks(true)
    if next(marks) ~= nil then
        for letter, mark in pairs(marks) do
            if not opts.force then
                if mark.filename ~= '' and not require('utils.files').is_file(mark.filename) then
                    deleted_marks = deleted_marks + 1
                    vim.api.nvim_del_mark(letter)
                end
            else
                vim.api.nvim_del_mark(letter)
            end
        end
    end
    return deleted_marks
end

function M.marks_to_arglist(opts)
    opts = opts or {}
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        local files = {}
        for _, mark in pairs(marks) do
            table.insert(files, mark.filename)
        end
        require('utils.arglist').add(files, opts.clear)
    end
end

function M.marks_to_quickfix(opts)
    opts = opts or {}
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        local items = {}
        for _, mark in pairs(marks) do
            local filename = (mark.filename:gsub('^' .. cwd, ''))
            local item = {
                filename = filename,
                text = filename,
                lnum = mark.lnum,
                col = mark.col,
                valid = true,
            }
            table.insert(items, item)
        end
        RELOAD('utils.qf').set_list {
            items = items,
            title = 'Marks',
            open = true,
            win = opts.win,
        }
    end
end

function M.dump_marks(opts)
    opts = opts or {}
    local loc = opts.file and opts.file ~= '' or marks_default_loc
    local marks = M.get_global_marks()
    if next(marks) ~= nil then
        require('utils.files').dump_json(loc, marks)
        return true
    end
    return false
end

function M.load_marks(opts)
    opts = opts or {}
    local loc = opts.file and opts.file ~= '' or marks_default_loc
    if require('utils.files').is_file(loc) then
        M.clear { force = true }

        local view = vim.fn.winsaveview()
        local buf = vim.api.nvim_get_current_buf()

        local marks = require('utils.files').read_json(loc)
        local cwd = vim.pesc(vim.uv.cwd())

        for letter, mark in pairs(marks) do
            local filename = (mark.filename:gsub(cwd, ''))
            local mark_buf = vim.fn.bufadd(filename)

            -- TODO: check if buffer is loaded
            vim.cmd.edit {
                args = { filename },
                mods = {
                    noautocmd = true,
                    keepalt = true,
                    keepjumps = true,
                    keepmarks = true,
                    keeppatterns = true,
                },
            }
            vim.api.nvim_buf_set_mark(mark_buf, letter, mark.lnum, mark.col, {})
        end

        vim.api.nvim_win_set_buf(0, buf)
        vim.fn.winrestview(view)
        return true
    else
        vim.notify('Missing marks.json', vim.log.levels.ERROR, { title = 'Marks' })
    end
    return false
end

return M

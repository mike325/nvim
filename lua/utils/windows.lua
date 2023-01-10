local nvim = require 'neovim'

local M = {}

local function autowipe(win, buffer)
    vim.validate { window = { win, 'number' }, buffer = { buffer, 'number' } }

    nvim.autocmd.add('WinClosed', {
        pattern = tostring(win),
        callback = function()
            if vim.api.nvim_buf_is_valid(buffer) then
                vim.api.nvim_buf_delete(buffer, { force = true })
            end
        end,
        group = 'AutoCloseWindow',
        once = true,
        nested = true,
    })
end

local function close_on_move(win, buffer)
    vim.validate { window = { win, 'number' } }

    nvim.autocmd.add('CursorMoved', {
        buffer = buffer or vim.api.nvim_get_current_buf(),
        callback = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
        group = 'AutoCloseWindow',
        once = true,
        nested = true,
    })
end

local function close_on_leave(win, buffer)
    vim.validate { window = { win, 'number' } }

    if win then
        nvim.autocmd.add('WinLeave', {
            pattern = tostring(win),
            callback = function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end,
            group = 'AutoCloseWindow',
            once = true,
            nested = true,
        })
    end

    if buffer then
        nvim.autocmd.add('BufLeave', {
            buffer = buffer,
            callback = function()
                if vim.api.nvim_win_is_valid(win) then
                    vim.api.nvim_win_close(win, true)
                end
            end,
            group = 'AutoCloseWindow',
            once = true,
            nested = true,
        })
    end
end

function M.big_center(buffer)
    assert(
        not buffer or (type(buffer) == type(0) and buffer >= 0),
        debug.traceback('Invalid buffer: ' .. vim.inspect(buffer))
    )

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()

    local height_percentage = 10 / 100
    local width_percentage = 5 / 100

    if not buffer then
        -- create a new, scratch buffer, for fzf
        buffer = vim.api.nvim_create_buf(false, true)
        vim.bo[buffer].buftype = 'nofile'
    end

    -- if the editor is big enough
    if columns > 100 or lines > 35 then
        -- fzf's window height is 3/4 of the max height, but not more than 70
        local win_height = math.min(math.ceil(lines * 3 / 4), 70)
        local win_width = (columns < 100) and math.ceil(columns - 8) or math.ceil(columns * 0.9)

        -- create a new floating window, centered in the editor
        local win = vim.api.nvim_open_win(buffer, true, {
            style = 'minimal',
            border = 'rounded',
            relative = 'editor',
            row = math.ceil(lines * height_percentage),
            col = math.ceil(columns * width_percentage),
            width = win_width,
            height = win_height,
            noautocmd = true,
            focusable = true,
            zindex = 10,
        })
        return win
    else
        error(debug.traceback 'Current neovim window is too small')
    end
end

function M.progress(buffer, job)
    vim.validate {
        buffer = { buffer, 'number', true },
        job = { job, 'number', true },
    }

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()

    local scratch = false
    if not buffer then
        buffer = vim.api.nvim_create_buf(false, true)
        scratch = true
    end

    if not vim.t.progress_win then
        vim.t.progress_win = vim.api.nvim_open_win(buffer, false, {
            style = 'minimal',
            border = 'rounded',
            relative = 'win',
            anchor = 'SW',
            row = lines - 5,
            col = 2,
            -- bufpos = {lines/2, 15},
            height = 15,
            width = columns - 5,
            noautocmd = true,
            focusable = true,
            zindex = 1, -- very low priority
        })

        nvim.autocmd.JobProgress = {
            event = 'WinClosed',
            pattern = tostring(vim.t.progress_win),
            command = 'unlet t:progress_win',
            once = true,
        }

        if scratch then
            autowipe(vim.t.progress_win, buffer)
        end
    else
        nvim.win.set_buf(vim.t.progress_win, buffer)
    end

    local job_obj = job and STORAGE.jobs[job] or STORAGE.jobs[vim.g.active_job]
    if scratch and job_obj then
        nvim.buf.set_lines(buffer, -2, -1, false, job_obj:output())
        nvim.buf.call(buffer, function()
            nvim.ex['normal!'] 'G'
        end)
    end

    return vim.t.progress_win
end

function M.lower_window(buffer)
    vim.validate {
        buffer = { buffer, 'number', true },
    }

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()

    local scratch = false
    if not buffer then
        buffer = vim.api.nvim_create_buf(false, true)
        scratch = true
    end

    local lower_window = vim.api.nvim_open_win(buffer, false, {
        style = 'minimal',
        border = 'rounded',
        relative = 'win',
        anchor = 'SW',
        row = lines - 5,
        col = 2,
        -- bufpos = {lines/2, 15},
        height = 15,
        width = columns - 5,
        noautocmd = true,
        focusable = true,
        zindex = 1, -- very low priority
    })

    if scratch then
        autowipe(lower_window, buffer)
    end

    return lower_window
end

function M.cursor_window(buffer, auto_size)
    vim.validate {
        buffer = { buffer, 'number', true },
    }

    -- local columns = vim.opt.columns:get()
    -- local lines = vim.opt.lines:get()

    -- local current_win = vim.api.nvim_get_current_win()
    -- local current_buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local scratch = false
    local win_width = 80
    local win_height = math.ceil(win_width / 5)

    if not buffer then
        buffer = vim.api.nvim_create_buf(false, true)
        scratch = true
    elseif auto_size then
        local lines = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
        local width = 0
        for _, line in ipairs(lines) do
            if #line > width then
                width = #line
            end
        end

        win_width = width <= 150 and width or 150
        win_height = #lines <= 15 and #lines or 15
    end

    local win = vim.api.nvim_open_win(buffer, false, {
        style = 'minimal',
        border = 'rounded',
        relative = 'cursor',
        anchor = 'SW',
        col = 0,
        row = -2,
        height = win_height,
        width = win_width,
        -- noautocmd = true,
        focusable = true,
        zindex = 10,
    })

    close_on_move(win)
    close_on_leave(win, buffer)

    if scratch then
        autowipe(win, buffer)
    end

    return win
end

function M.input(opts, on_confirm)
    vim.validate {
        opts = { opts, 'table' },
        on_confirm = { on_confirm, 'function' },
    }

    -- local columns = vim.opt.columns:get()
    -- local lines = vim.opt.lines:get()
    -- local current_win = vim.api.nvim_get_current_win()
    -- local current_buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local buffer = vim.api.nvim_create_buf(false, true)

    local win_width = 30
    local win_height = 1

    local win = vim.api.nvim_open_win(buffer, true, {
        style = 'minimal',
        border = 'rounded',
        relative = 'cursor',
        anchor = 'SW',
        col = 0,
        row = -1,
        height = win_height,
        width = win_width,
        -- noautocmd = true,
        focusable = true,
        zindex = 10,
    })

    autowipe(win, buffer)
    close_on_leave(win, buffer)

    nvim.autocmd.add({ 'BufWipeout', 'BufUnload', 'BufLeave', 'BufWinLeave' }, {
        buffer = buffer,
        command = 'stopinsert',
        group = 'AutoCloseWindow',
        once = true,
        nested = true,
    })

    vim.keymap.set({ 'i', 'n' }, '<ESC>', function()
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if on_confirm then
            on_confirm()
        end
    end, { silent = true, buffer = buffer, nowait = true })

    vim.keymap.set({ 'i', 'n' }, '<CR>', function()
        local result
        if vim.api.nvim_win_is_valid(win) then
            vim.api.nvim_win_close(win, true)
        end
        if vim.api.nvim_buf_is_valid(win) then
            result = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)[1]
        end
        if on_confirm then
            on_confirm(result)
        end
    end, { silent = true, buffer = buffer, nowait = true })

    vim.cmd.startinsert()

    return win
end

return M

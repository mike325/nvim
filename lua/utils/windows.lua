local nvim = require'neovim'
local set_autocmd = require'neovim.autocmds'.set_autocmd
local set_mapping = require'neovim.mappings'.set_mapping

local M = {}

local function autowipe(win, buffer)
    assert(win and buffer, debug.traceback('Buffer and window are necessary'))

    set_autocmd{
        event = {'WinClosed'},
        pattern = win,
        cmd = ('lua if vim.api.nvim_buf_is_valid(%s) then vim.api.nvim_buf_delete(%s, {force=true}) end'):format(
            buffer,
            buffer
        ),
        group = 'AutoCloseWindow',
        once = true,
        nested = true,
    }
end

local function close_on_move(win, buffer)
    assert(win, debug.traceback('Missing window'))

    set_autocmd{
        event   = {'CursorMoved'},
        pattern = ('<buffer=%s>'):format(buffer or vim.api.nvim_get_current_buf()),
        cmd     = ('lua if vim.api.nvim_win_is_valid(%s) then vim.api.nvim_win_close(%s, true) end'):format(
            win,
            win
        ),
        group   = 'AutoCloseWindow',
        once    = true,
        nested  = true,
    }
end

local function close_on_leave(win, buffer)
    assert(win, debug.traceback('Missing window'))

    if win then
        set_autocmd{
            event   = {'WinLeave'},
            pattern = win,
            cmd     = ('lua if vim.api.nvim_win_is_valid(%s) then vim.api.nvim_win_close(%s, true) end'):format(
                win,
                win
            ),
            group   = 'AutoCloseWindow',
            once    = true,
            nested  = true,
        }
    end

    if buffer then
        set_autocmd{
            event   = {'BufLeave'},
            pattern = ('<buffer=%s>'):format(buffer),
            cmd     = ('lua if vim.api.nvim_win_is_valid(%s) then vim.api.nvim_win_close(%s, true) end'):format(
                win,
                win
            ),
            group   = 'AutoCloseWindow',
            once    = true,
            nested  = true,
        }
    end
end

function M.big_center(buffer)
    assert(
        not buffer or (type(buffer) == type(0) and buffer >= 0),
        debug.traceback('Invalid buffer: '..vim.inspect(buffer))
    )

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()

    local height_percentage = 10 / 100
    local width_percentage = 5 / 100

    if not buffer then
        -- create a new, scratch buffer, for fzf
        buffer = vim.api.nvim_create_buf(false, true)
        vim.api.nvim_buf_set_option(buffer, 'buftype', 'nofile')
    end

    -- if the editor is big enough
    if (columns > 100 or lines > 35) then
        -- fzf's window height is 3/4 of the max height, but not more than 70
        local win_height = math.min(math.ceil(lines * 3 / 4), 70)
        local win_width = (columns < 100) and math.ceil(columns - 8) or math.ceil(columns * 0.9)

        -- create a new floating window, centered in the editor
        local win = vim.api.nvim_open_win(buffer, true, {
            style     = "minimal",
            border    = 'rounded',
            relative  = "editor",
            row       = math.ceil(lines * height_percentage),
            col       = math.ceil(columns * width_percentage),
            width     = win_width,
            height    = win_height,
            noautocmd = true,
            focusable = true,
            zindex    = 10,
        })
        return win
    else
        error(debug.traceback('Current neovim window is too small'))
    end
end

function M.progress(buffer)
    assert(
        not buffer or (type(buffer) == type(0) and buffer >= 0),
        debug.traceback('Invalid buffer: '..vim.inspect(buffer))
    )

    local columns = vim.opt.columns:get()
    local lines = vim.opt.lines:get()

    local scratch = false
    if not buffer then
        buffer = vim.api.nvim_create_buf(false, true)
        scratch = true
    end

    if not vim.t.progress_win then
        vim.t.progress_win = vim.api.nvim_open_win(
            buffer,
            false,
            {
                style     = 'minimal',
                border    = 'rounded',
                relative  = 'win',
                anchor    = 'SW',
                row       = lines - 6,
                col       = 2,
                -- bufpos = {lines/2, 15},
                height    = 15,
                width     = columns - 5,
                noautocmd = true,
                focusable = true,
                zindex    = 1, -- very low priority
            }
        )

        set_autocmd{
            event   = 'WinClosed',
            pattern = vim.t.progress_win,
            cmd     = 'unlet t:progress_win',
            group   = 'JobProgress',
            once    = true,
        }

        if scratch then
            autowipe(vim.t.progress_win, buffer)
        end
    else
        nvim.win.set_buf(vim.t.progress_win, buffer)
    end

    return vim.t.progress_win
end

function M.cursor_window(buffer, auto_size)
    assert(
        not buffer or (type(buffer) == type(0) and buffer >= 0),
        debug.traceback('Invalid buffer: '..vim.inspect(buffer))
    )

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
            if #line > 0 then
                width = line
            end
        end

        win_width = width <= 120 and width or 80
        win_height = #lines <= 15 and #lines or 15
    end

    local win = vim.api.nvim_open_win(buffer, false, {
        style     = 'minimal',
        border    = 'rounded',
        relative  = 'cursor',
        anchor    = 'SW',
        col       = 0,
        row       = -1,
        height    = win_height,
        width     = win_width,
        -- noautocmd = true,
        focusable = true,
        zindex    = 10,
    })

    close_on_move(win)
    close_on_leave(win, buffer)

    if scratch then
        autowipe(win, buffer)
    end

    return win
end

function M.ask_window(callback)
    assert(
        not callback or vim.is_callable(callback),
        debug.traceback('Invalid callback: '..vim.inspect(callback))
    )

    -- local columns = vim.opt.columns:get()
    -- local lines = vim.opt.lines:get()
    -- local current_win = vim.api.nvim_get_current_win()
    -- local current_buf = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())

    local buffer = vim.api.nvim_create_buf(false, true)

    local win_width = 30
    local win_height = 1

    local win = vim.api.nvim_open_win(buffer, true, {
        style     = 'minimal',
        border    = 'rounded',
        relative  = 'cursor',
        anchor    = 'SW',
        col       = 0,
        row       = -1,
        height    = win_height,
        width     = win_width,
        -- noautocmd = true,
        focusable = true,
        zindex    = 10,
    })

    autowipe(win, buffer)
    close_on_leave(win, buffer)

    set_autocmd{
        event   = {'BufWipeout', 'BufUnload', 'BufLeave', 'BufWinLeave'},
        pattern = ('<buffer=%s>'):format(buffer),
        cmd     = 'stopinsert',
        group   = 'AutoCloseWindow',
        once    = true,
        nested  = true,
    }

    set_mapping{
        mode = 'i',
        lhs = '<ESC>',
        rhs = function()
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
        end,
        args = {silent = true, buffer = buffer},
    }

    set_mapping{
        mode = 'i',
        lhs = '<CR>',
        rhs = function()
            local result
            if vim.api.nvim_win_is_valid(win) then
                vim.api.nvim_win_close(win, true)
            end
            if vim.api.nvim_buf_is_valid(win) then
                result = vim.api.nvim_buf_get_lines(buffer, 0, -1, false)[1]
            end
            if callback then
                callback(result)
            end
        end,
        args = {silent = true, buffer = buffer},
    }

    nvim.ex.startinsert()

    return win
end

return M

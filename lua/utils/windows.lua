local nvim = require'neovim'
local set_autocmd = require'neovim.autocmds'.set_autocmd

local M = {}

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
            style    = "minimal",
            border   = 'rounded',
            relative = "editor",
            row      = math.ceil(lines * height_percentage),
            col      = math.ceil(columns * width_percentage),
            width    = win_width,
            height   = win_height,
            noautocmd = true,
            focusable = true,
            zindex   = 10,
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

    if not buffer then
        buffer = vim.api.nvim_create_buf(false, true)
    end

    if not vim.t.progress_win then
        vim.t.progress_win = vim.api.nvim_open_win(
            buffer,
            false,
            {
                style = 'minimal',
                border = 'rounded',
                relative = 'win',
                anchor = 'SW',
                row = lines - 6,
                col = 2,
                -- bufpos = {lines/2, 15},
                height = 15,
                width = columns - 5,
                noautocmd = true,
                focusable = true,
                zindex = 1, -- very low priority
            }
        )

        set_autocmd{
            event = 'WinClosed',
            pattern = vim.t.progress_win,
            cmd = 'unlet t:progress_win',
            group = 'JobProgress',
            once    = true,
        }
    else
        nvim.win.set_buf(vim.t.progress_win, buffer)
    end

    return vim.t.progress_win
end

return M

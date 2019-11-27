local api = vim.api

local function floating_window()
    -- get the editor's max width and height
    local width = api.nvim_get_option("columns")
    local height = api.nvim_get_option("lines")

    local height_percentage = 10 / 100
    local width_percentage = 5 / 100

    -- create a new, scratch buffer, for fzf
    local buf = api.nvim_create_buf(false, true)
    api.nvim_buf_set_option(buf, 'buftype', 'nofile')

    -- if the editor is big enough
    if (width > 100 or height > 35) then
        -- fzf's window height is 3/4 of the max height, but not more than 70
        local win_height = math.min(math.ceil(height * 3 / 4), 70)
        local win_width

        -- if the width is small
        if (width < 100) then
            -- just subtract 8 from the editor's width
            win_width = math.ceil(width - 8)
        else
            -- use 90% of the editor's width
            win_width = math.ceil(width * 0.9)
        end

        -- settings for the fzf window
        local opts = {
            style    = "minimal",
            relative = "editor",
            row      = math.ceil(height * height_percentage),
            col      = math.ceil(width * width_percentage),
            width    = win_width,
            height   = win_height,
        }

        -- create a new floating window, centered in the editor
        local win = api.nvim_open_win(buf, true, opts)
    end
end


local floating_funcs = {
    window   = floating_window,
}

return floating_funcs

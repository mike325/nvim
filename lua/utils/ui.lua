local M = {}

-- Extra icons
-- 
-- 
-- ▶
-- ◀
-- »
-- «
-- ❯
-- ➤
-- 
-- ☰
-- 

local icons
if not vim.env.NO_COOL_FONTS then
    icons = {
        error = '✗ ', -- ✗ -- 🞮  -- × --  -- ❌
        warn = ' ', -- 
        info = ' ',
        hint = '',
        wait = '☕',
        build = '⛭',
        success = '✓', -- ✓ -- ✔ -- 
        fail = '✗',
        bug = '',
        breakpoint = '●',
        todo = '',
        hack = ' ',
        perf = ' ',
        note = ' ',
        test = '⏲ ',
        virtual_text = '❯',
        diff_add = '',
        diff_modified = '',
        diff_remove = '',
        git_branch = '',
        readonly = '🔒',
        bar = '▋',
        sep_triangle_left = '',
        sep_triangle_right = '',
        sep_circle_right = '',
        sep_circle_left = '',
        sep_arrow_left = '',
        sep_arrow_right = '',
    }
else
    icons = {
        error = '×',
        warn = '!',
        info = 'I',
        hint = 'H',
        wait = '☕', -- W
        build = '⛭', -- b
        success = '✓', -- ✓ -- ✔ -- 
        fail = '✗',
        breakpoint = '⦿',
        bug = 'B', -- 🐛' -- B
        todo = '⦿',
        hack = '☠',
        perf = '✈', -- 🚀
        note = '🗈',
        test = '⏲',
        virtual_text = '❯', -- '❯', -- '➤',
        diff_add = '+',
        diff_modified = '~',
        diff_remove = '-',
        git_branch = '', -- TODO add an universal branch
        readonly = '🔒', -- '',
        bar = '|',
        sep_triangle_left = '>',
        sep_triangle_right = '<',
        sep_circle_right = '(',
        sep_circle_left = ')',
        sep_arrow_left = '>',
        sep_arrow_right = '<',
    }
end

icons.err = icons.error
icons.msg = icons.hint
icons.message = icons.hint
icons.warning = icons.warn
icons.information = icons.info

function M.get_icon(icon)
    return icons[icon]
end

function M.get_separators(sep_type)
    local separators = {
        circle = {
            left = icons.sep_circle_left,
            right = icons.sep_circle_right,
        },
        triangle = {
            left = icons.sep_triangle_left,
            right = icons.sep_triangle_right,
        },
        arrow = {
            left = icons.sep_arrow_left,
            right = icons.sep_arrow_right,
        },
        tag = {
            left = '',
            right = '',
        },
        slash = {
            left = '/',
            right = '\\',
        },
        parenthesis = {
            left = ')',
            right = '(',
        },
    }

    return separators[sep_type]
end

return M

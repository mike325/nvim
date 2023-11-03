local M = {}

function M.clear()
    local size = vim.fn.argc()
    if size > 0 then
        vim.cmd.argdelete { range = { 1, size } }
    end
end

function M.add(files, clear)
    vim.validate {
        files = { files, 'table' },
        clear = { clear, 'boolean', true },
    }
    if clear then
        M.clear()
    end
    local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
    for _, filename in ipairs(files) do
        if type(filename) == type '' then
            local buf = vim.fn.bufnr(filename)
            filename = (filename:gsub('^' .. cwd, ''))
            if buf == -1 then
                vim.cmd.badd(filename)
            end
            vim.cmd.argadd(filename)
        elseif type(filename) == type(0) then
            local buf = filename
            if not vim.api.nvim_buf_is_valid(buf) then
                error(debug.traceback('Invalid bufnr: ' .. buf))
            end
            local bufname = vim.fn.bufname(buf)
            vim.cmd.argadd((bufname:gsub('^' .. cwd, '')))
        else
            error(debug.traceback('Invalid file argument: ' .. vim.inspect(filename)))
        end
    end

    -- remove duplicates
    vim.cmd.argdedupe()
end

return M

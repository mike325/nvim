local M = {}

--- Clear arglist
---@param all boolean?
function M.clear(all)
    vim.validate {
        all = { all, 'boolean', true },
    }

    if all then
        local size = vim.fn.argc()
        if size > 0 then
            vim.cmd.argdelete '*'
        end
    else
        -- NOTE: sessions may load invalid files in the arglist
        for _, arg in
            ipairs(vim.fn.argv() --[[@as string[] ]])
        do
            if not require('utils.files').is_file(arg) then
                vim.cmd.argdelete(arg)
            end
        end
    end
end

--- Add the given files/buffers to the arglist
---@param files string|string[]|number|number[]
---@param clear boolean?
function M.add(files, clear)
    vim.validate {
        files = { files, { 'table', 'string', 'number' } },
        clear = { clear, 'boolean', true },
    }
    if clear then
        M.clear(true)
    end
    if type(files) ~= type {} then
        files = { files }
    end

    -- local label = vim.t.label
    -- if not label and vim.v.this_session ~= '' then
    --     label = vim.fs.basename(vim.v.this_session)
    -- end

    local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
    ---@cast files table
    for _, filename in ipairs(files) do
        if type(filename) == type '' then
            ---@cast filename string
            local buf = vim.fn.bufnr(filename)
            if filename == '%' then
                filename = vim.fn.bufname(buf)
            end
            if require('utils.files').is_file(filename) or buf ~= -1 then
                filename = (filename:gsub('^' .. cwd, ''))
                if buf == -1 then
                    vim.cmd.badd(filename)
                end
                vim.cmd.argadd(filename)
                -- if label then
                --     require('configs.mini.utils').add_file_to_label(label, filename)
                -- end
            end
        elseif type(filename) == type(0) then
            local buf = filename
            if not vim.api.nvim_buf_is_valid(buf) then
                error(debug.traceback('Invalid bufnr: ' .. buf))
            end
            local bufname = vim.fn.bufname(buf)
            vim.cmd.argadd((bufname:gsub('^' .. cwd, '')))
            -- if label then
            --     require('configs.mini.utils').add_file_to_label(label, bufname)
            -- end
        else
            error(debug.traceback('Invalid file argument: ' .. vim.inspect(filename)))
        end
    end

    -- remove duplicates
    vim.cmd.argdedupe()
end

--- Execute an ex cmd inside every element in the arglist
---@param cmd string
function M.exec(cmd)
    for _, filename in
        ipairs(vim.fn.argv() --[[@as string[] ]])
    do
        local buf = vim.fn.bufnr(filename)
        vim.api.nvim_buf_call(buf, function()
            vim.cmd(cmd)
        end)
    end
end

--- Edit an existing argument
---@param argument string?
function M.edit(argument)
    vim.validate {
        argument = { argument, 'string', true },
    }

    ---@type string[]
    local args = vim.fn.argv() --[[@as string[] ]]
    if #args == 0 then
        return
    end

    if argument and argument ~= '' then
        for idx, arg in ipairs(args) do
            if arg == argument then
                vim.cmd.argument(idx)
                break
            end
        end
    else
        vim.ui.select(
            args,
            { prompt = 'Select Arg > ' },
            vim.schedule_wrap(function(choice, idx)
                if choice and choice ~= '' then
                    vim.cmd.argument(idx)
                end
            end)
        )
    end
end

return M

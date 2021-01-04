local M = {}

function M.echoerr(msg)
    if type(msg) == 'string' and #msg > 0 then
        vim.api.nvim_err_writeln(msg)
    end
end

return M

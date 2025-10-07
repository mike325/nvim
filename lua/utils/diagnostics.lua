local M = {}

function M.toggle_virtual_lines(action, force)
    -- local action = opts.args:gsub('^%-+', '')
    local options = { virtual_text = not force }

    if vim.version.ge(vim.version(), { 0, 11 }) then
        options.virtual_lines = not force
    end

    if action == 'text' then
        options.virtual_lines = nil
        if not force then
            options.virtual_text = {
                spacing = 2,
                prefix = '❯',
            }
        end
    elseif action == 'lines' then
        options.virtual_text = nil
    elseif not force and vim.version.ge(vim.version(), { 0, 11 }) then
        options.virtual_text = false
    end

    vim.diagnostic.config(options)
end

return M

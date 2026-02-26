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

function M.get_namespaces()
    return vim.iter(vim.diagnostic.get_namespaces()):fold({}, function(diagnostics, ns)
        diagnostics[ns.name] = ns
        diagnostics[ns.name].id = vim.api.nvim_create_namespace(ns.name)
        return diagnostics
    end)
end

function M.get_namespace(ns)
    if type(ns) == type(1) then
        local namespace = vim.diagnostic.get_namespace(ns)
        namespace.id = ns
        return namespace
    end
    local namespaces = M.get_namespaces()
    local ns_name = vim.iter(namespaces):find(function(_, namespace)
        return namespace.name == ns or namespace.name:match(ns .. '$')
    end)
    return namespaces[ns_name]
end

return M

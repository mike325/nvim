local M = {}

function M.get_label()
    local label = vim.t.label
    if not label and vim.v.this_session ~= '' then
        label = vim.fs.basename(vim.v.this_session)
    end
    return label
end

function M.add_file_to_label(label, file)
    vim.validate {
        label = { label, 'string' },
        file = { file, { 'number', 'string', 'table' } },
    }

    local mini_visits = _G['MiniVisits'] or vim.F.npcall(require, 'mini.visits')
    if mini_visits then
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        if type(file) ~= type {} then
            file = { file }
        end
        for _, f in ipairs(file) do
            if type(f) == type(0) then
                f = vim.api.nvim_buf_get_name(f)
            end
            mini_visits.add_label(label, (f:gsub('^' .. cwd, '')))
        end
    end
end

function M.get_labels(global)
    vim.validate {
        global = { global, 'boolean', true },
    }
    local labels = {}
    local mini_visits = _G['MiniVisits'] or vim.F.npcall(require, 'mini.visits')
    if mini_visits then
        local cwd = global and '' or nil
        labels = mini_visits.list_labels('', cwd)
    end
    return labels
end

function M.get_labeled_files(label, valid)
    vim.validate {
        label = { label, 'string' },
    }
    local paths = {}
    local mini_visits = _G['MiniVisits'] or vim.F.npcall(require, 'mini.visits')
    if mini_visits then
        paths = vim.iter(mini_visits.list_paths(nil, {
            filter = function(data)
                return (data.labels or {})[label]
            end,
        }))
        if valid then
            paths = paths:filter(require('utils.files').is_file)
        end
        paths = paths:totable()
    end
    return paths
end

function M.clear_label(label, force)
    vim.validate {
        label = { label, 'string' },
        force = { force, 'boolean', true },
    }
    local mini_visits = _G['MiniVisits'] or vim.F.npcall(require, 'mini.visits')
    if mini_visits then
        if force then
            mini_visits.remove_label(label, '')
            vim.t.label = nil
        else
            local paths = vim.iter(M.get_labeled_files(label)):filter(function(path)
                return not require('utils.files').is_file(path)
            end)
            for p in paths do
                mini_visits.remove_label(label, p)
            end
        end
    end
end

return M

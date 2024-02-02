local M = {}

if vim.F.npcall(require, 'mini.fuzzy') then
    require('mini.fuzzy').setup {}
end

local function filter(word, candidates)
    if word == '' then
        return candidates
    end

    local MiniFuzzy = vim.F.npcall(require, 'mini.fuzzy')
    if MiniFuzzy then
        return (MiniFuzzy.filtersort(word, candidates))
    end

    local split_components = require('utils.strings').split_components
    local pattern = table.concat(split_components(word, '.'), '.*')
    return vim.tbl_filter(function(candidate)
        return candidate:lower():match(pattern) ~= nil
    end, candidates) or {}
end

function M.general_completion(arglead, _, _, options)
    local dashes
    if arglead:sub(1, 2) == '--' then
        dashes = '--'
    elseif arglead:sub(1, 1) == '-' then
        dashes = '-'
    end
    local results = filter((arglead:gsub('%-', '')):lower(), options)
    return vim.tbl_map(function(arg)
        if dashes and arg:sub(1, #dashes) ~= dashes then
            return dashes .. arg
        end
        return arg
    end, results)
end

function M.general_nodash_completion(arglead, _, _, options)
    return filter(arglead:lower(), options)
end

function M.json_keys_completion(arglead, cmdline, cursorpos, filename, funcs)
    funcs = funcs or {}

    local json = {}
    if require('utils.files').is_file(filename) then
        json = require('utils.files').read_json(filename)
    end
    local keys = vim.tbl_keys(json)
    if funcs.filter then
        keys = vim.tbl_filter(funcs.filter, keys)
    end
    if funcs.map then
        keys = vim.tbl_map(funcs.map, keys)
    end
    return M.general_completion(arglead, cmdline, cursorpos, keys)
end

return M

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

--- Return a completion function
---@param cmd string[]
---@param options string[]
---@return string[]
local function get_available_flags(cmd, options)
    return vim.iter(options)
        :filter(function(opt)
            return not vim.tbl_contains(cmd, opt)
        end)
        :totable()
end

--- Return a completion function
---@param comp_func fun(arglead: string, cmdline: string, cursorpos: string, options: string[]):string[]
---@param options string[]|fun(cmd: string[]?):string[]
---@param suboptions boolean|table<string, string[]|fun(cmd: string[]?):string[]>|nil
---@param smart boolean?
local function get_completions_func(comp_func, options, suboptions, smart)
    if type(suboptions) == type(true) then
        smart = suboptions --[[@as boolean]]
        suboptions = nil
    end

    return function(arglead, cmdline, cursorpos)
        local cmd = M.get_cmd(cmdline)

        if vim.is_callable(options) then
            options = options(cmd)
        end

        if smart then
            options = get_available_flags(cmd, options --[[@as string[] ]])
        end

        if suboptions then
            for flag, subopts in
                pairs(suboptions --[[@as table<string, string[]|fun(cmd: string[]?):string[]>]])
            do
                local pattern = string.format('^%%-?%%-?%s$', flag)
                if
                    arglead:match(pattern)
                    or (arglead == '' and cmd[#cmd]:match(pattern))
                    or (arglead ~= '' and not arglead:match '^%-' and #cmd >= 2 and cmd[#cmd - 1]:match(pattern))
                then
                    if vim.is_callable(subopts) then
                        subopts = subopts(cmd)
                    end

                    if smart then
                        subopts = get_available_flags(cmd, subopts --[[@as string[] ]])
                    end
                    return comp_func(arglead, cmdline, cursorpos, subopts --[[@as string[] ]])
                end
            end
        end

        return comp_func(arglead, cmdline, cursorpos, options --[[@as string[] ]])
    end
end

--- Return a completion function
---@param options string[]|fun(cmd: string[]?):string[]
---@param suboptions boolean|table<string, string[]|fun(cmd: string[]?):string[]>|nil
---@param smart boolean?
function M.get_completion(options, suboptions, smart)
    return get_completions_func(M.general_completion, options, suboptions, smart)
end

--- Return a completion function
---@param options string[]|fun(cmd: string[]?):string[]
---@param suboptions boolean|table<string, string[]|fun(cmd: string[]?):string[]>|nil
---@param smart boolean?
function M.get_nodash_completion(options, suboptions, smart)
    return get_completions_func(M.general_nodash_completion, options, suboptions, smart)
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

--- Return a cmd separated by spaces
---@param cmdline string
---@return string[]
function M.get_cmd(cmdline)
    return vim.iter(vim.split(cmdline, '%s+', { trimempty = true })):map(vim.trim):totable()
end

return M

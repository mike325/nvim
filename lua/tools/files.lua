local sys  = require('sys')
local nvim = require('nvim')

local line         = nvim.fn.line
local system       = nvim.fn.system
local executable   = nvim.executable
local isdirectory  = nvim.isdirectory
local filereadable = nvim.filereadable

local M = {}

function M.ls(expr)
    expr = expr == nil and {} or expr

    local search
    local path = expr.path
    local glob = expr.glob
    local filter = expr.type

    if glob == nil and path == nil then
        path = path == nil and '.' or path
        glob = glob == nil and '*' or glob
    end

    if path ~= nil and glob ~= nil then
        search = path..'/'..glob
    else
        search = path == nil and glob or path
    end

    local results = nvim.fn.glob(search, false, true, false)

    local filter_func = {
        file = filereadable,
        dir  = isdirectory,
    }

    filter_func.files = filter_func.file
    filter_func.dirs = filter_func.dir

    if filter_func[filter] ~= nil then
        local filtered = {}

        for _,element in pairs(results) do
            if filter_func[filter](element) then
                filtered[#filtered + 1] = element
            end
        end

        results = filtered
    end

    return results
end

function M.get_files(expr)
    expr = expr == nil and {} or expr
    expr.type = 'file'
    return M.files.ls(expr)
end

function M.get_dirs(expr)
    expr = expr == nil and {} or expr
    expr.type = 'dirs'
    return M.files.ls(expr)
end

function M.read_json(filename)
    if not filereadable(filename) then
        return false
    end
    return nvim.fn.json_decode(nvim.fn.readfile(filename))
end

function M.normalize_path(path)
    if path:sub(1, 1) == '~' then
        path = nvim.fn.expand(path)
    end
    return path:gsub('\\','/')
end

return M

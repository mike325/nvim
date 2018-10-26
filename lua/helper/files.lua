-- luacheck: globals unpack vim
local api = vim.api

local files = {}

-- see if the file exists
files.file_exists = function(filename)
    local file = io.open(filename, "rb")
    if file then file:close() end
    return file ~= nil
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
files.read_lines = function(filename)
    if not file_exists(filename) then return {} end
    lines = {}
    for line in io.lines(filename) do
        lines[#lines + 1] = line
    end
    return lines
end

-- get all lines from a file, returns an empty
-- list/table if the file does not exist
files.read_file = function(filename)
    if not file_exists(filename) then return nil end
    local file = assert(io.open(filename, 'r'))
    local data = nil
    data = file:read('*all')
    file:close()
    return data
end

return files

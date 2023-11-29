local mini_test = require 'mini.test'
local M = {}

function M.random_string(size)
    size = size or 10
    local w = ''
    for _ = 1, size do
        w = w .. string.char(math.random(32, 126))
    end
    return w
end

function M.random_word(size)
    size = size or 10
    local w = ''
    for _ = 1, size do
        local char = string.char(math.random(65, 90))
        w = w .. (math.random(0, 100) % 2 == 0 and char or char:lower())
    end
    return w
end

function M.random_int(low, high)
    low = low or 0
    high = high or 1000000
    return math.random(low, high)
end

function M.random_number(low, high)
    low = low or 0
    high = high or 1000000
    if math.random(0, 100) % 2 == 0 then
        return math.random(low, high) -- Integer
    end
    return math.random(low, high) + math.random() -- Float
end

function M.random_generator()
    if math.random(0, 100) % 5 == 0 then
        return M.random_number(0, 1000000)
        -- elseif math.random(0, 100) % 3 == 0 then
        --     return math.random(0, 100) % 2 == 0      -- bool
    end
    return M.random_string(math.random(1, 10)) -- string
end

function M.random_list(size, cb)
    size = size or 10
    local lst = {}
    for _ = 1, size do
        table.insert(lst, M.random_generator())
    end
    if cb then
        return vim.tbl_map(cb, lst)
    end
    return lst
end

function M.random_map(size, cb)
    size = size or 10
    local map = {}
    for _ = 1, size do
        map[M.random_generator()] = M.random_generator()
    end
    if cb then
        return vim.tbl_map(cb, map)
    end
    return map
end

function M.check_clear_lst(lst)
    for _, v in ipairs(lst) do
        if type(v) == type '' then
            mini_test.expect.equality(not v:match '%s+$', true)
            mini_test.expect.equality(not v:match '^%s*$', true)
        end
    end
end

return M

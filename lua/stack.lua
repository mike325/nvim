local Stack = {
    _items = {},
    __call = function(self)
        return coroutine.wrap(function()
            local i = 1
            while self._items[i] do
                coroutine.yield(self._items[i])
                i = i + 1
            end
            return nil
        end)
    end,
}
Stack.__index = Stack

function Stack:new(size)
    vim.validate {
        size = { size, 'number' },
    }
    local obj = {
        _size = size,
    }
    return setmetatable(obj, self)
end

function Stack:peek()
    return self._items[1]
end

function Stack:push(element)
    if #self._items == self._size then
        table.remove(self._items)
    end

    table.insert(self._items, 1, element)
end

function Stack:pop()
    return table.remove(self._items, 1)
end

function Stack:clear()
    self._items = {}
end

return Stack

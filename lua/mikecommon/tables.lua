-- luacheck: globals unpack vim
local api = vim.api

local function contains(array, value)
    for _, data in pairs(array) do
        if data == value then
            return true
        end
    end
    return false
end

local function has_key(array, key)
    return array[key] ~= nil
end

fns.keys = function(tbl)
    local new = {}
    for k, _ in pairs(tbl) do
        table.insert(new, k)
    end
    return new
end

fns.values = function(tbl)
    local new = {}
    for _, v in pairs(tbl) do
        table.insert(new, v)
    end
    return new
end

fns.clone = function(orig)
    local orig_type = type(orig)
    local copy
    if orig_type == 'table' then
        copy = {}
        for orig_key, orig_value in next, orig, nil do
            copy[fns.clone(orig_key)] = fns.clone(orig_value)
        end
        setmetatable(copy, fns.clone(getmetatable(orig)))
    else -- number, string, boolean, etc
        copy = orig
    end
    return copy
end

fns.merge = function (...)
  local res = {}
  for _, tbl in ipairs({...}) do
    for k, v in pairs(tbl) do
      res[k] = v
    end
  end
  return res
end

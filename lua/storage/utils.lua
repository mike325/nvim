local has_sqlite, sqlite = pcall(require, 'sqlite')
local has_lib, _ = pcall(require, 'sqlite.defs')
if not has_lib or not has_sqlite then
    sqlite = false
end

local M = {}

-- TODO: Add support to pass db objects
-- TODO: Add support for persistent db using json
function M.insert_row(tbl_name, data, db_path)
    vim.validate {
        tbl_name = { tbl_name, 'string' },
        data = { data, 'table' },
        db_path = { db_path, 'string', true },
    }

    db_path = db_path or STORAGE.db_path
    data = not vim.islist(data) and { data } or data

    if sqlite then
        return sqlite.with_open(db_path, function(db)
            local id
            local schema = db:schema(tbl_name)
            for name, attrs in pairs(schema) do
                if attrs.cid == 0 then
                    id = name
                    break
                end
            end

            for _, node in pairs(data) do
                local where = {}
                where[id] = node[id]

                local row = db:select(tbl_name, { where = where })[1]

                if not row then
                    db:insert(tbl_name, node)
                else
                    for name, value in pairs(row) do
                        if name ~= id and value ~= node[name] then
                            local update = vim.deepcopy(node)
                            update[id] = nil
                            db:update(tbl_name, {
                                where = where,
                                set = update,
                            })
                            break
                        end
                    end
                end
            end

            return data[#data]
        end)
    end

    local rt_node
    for _, node in pairs(data) do
        if node.id then
            STORAGE[tbl_name][node.id] = node
        elseif node.name then
            STORAGE[tbl_name][node.name] = node
        elseif node.hash then
            STORAGE[tbl_name][node.hash] = node
        else
            local _, val = next(node)
            STORAGE[tbl_name][val] = node
        end
        rt_node = node
    end
    return rt_node
end

function M.tbl_exists(tbl_name, db_path)
    vim.validate {
        tbl_name = { tbl_name, 'string' },
        db_path = { db_path, 'string', true },
    }

    local exists
    db_path = db_path or STORAGE.db_path

    if sqlite then
        exists = sqlite.with_open(db_path, function(db)
            return db:exists(tbl_name)
        end)
    else
        exists = STORAGE[tbl_name]
    end
    return exists and true or false
end

function M.create_tbl(tbl_name, tbl_schema, init_data, db_path)
    vim.validate {
        tbl_name = { tbl_name, 'string' },
        tbl_schema = { tbl_schema, 'table' },
        db_path = { db_path, 'string', true },
        init_data = { init_data, 'table', true },
    }

    db_path = db_path or STORAGE.db_path

    local tbl_exists = M.tbl_exists(tbl_name, db_path)
    if not tbl_exists then
        if sqlite then
            sqlite.with_open(db_path, function(db)
                if not db:exists(tbl_name) then
                    db:create(tbl_name, tbl_schema)
                end
            end)
        elseif not STORAGE[tbl_name] then
            STORAGE[tbl_name] = {}
        end
        if init_data then
            for _, row in pairs(init_data) do
                M.insert_row(tbl_name, row)
            end
        end
    end
end

return M

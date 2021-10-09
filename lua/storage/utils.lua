local _, sqlite = pcall(require, 'sqlite')

local M = {}

function M.insert_row(tbl_name, data, db_path)
    vim.validate {
        tbl_name = { tbl_name, 'string' },
        data = { data, 'table' },
        db_path = { db_path, 'string', true },
    }

    db_path = db_path or STORAGE.db_path
    data = not vim.tbl_islist(data) and { data } or data

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

    for _, node in pairs(data) do
        STORAGE[tbl_name][next(node)] = data
    end
    return STORAGE[tbl_name][next(data)]
end

function M.create_tbl(tbl_name, tbl_schema, init_data, db_path)
    vim.validate {
        tbl_name = { tbl_name, 'string' },
        tbl_schema = { tbl_schema, 'table' },
        db_path = { db_path, 'string', true },
        init_data = { init_data, 'table', true },
    }

    db_path = db_path or STORAGE.db_path

    local tbl_exists
    if sqlite then
        tbl_exists = sqlite.with_open(db_path, function(db)
            return db:exists(tbl_name)
        end)
    else
        tbl_exists = STORAGE[tbl_name]
    end

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

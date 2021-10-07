local _, sqlite = pcall(require, 'sqlite')

local db_path = STORAGE.db_path

local M = {}

local function get_prg_version(output)
    return table.concat(require('utils.strings').split_components(output, '%d+'), '.')
end

local function insert_version(prg, version)
    if sqlite then
        return sqlite.with_open(db_path, function(db)
            local row = db:select('versions', { where = { name = prg } })[1]

            if not row then
                db:insert('versions', {
                    name = prg,
                    version = version,
                })
            elseif version ~= row.version then
                db:update('versions', {
                    where = { name = prg },
                    set = { version = version },
                })
            end

            return db:select('versions', { where = { name = prg } })[1]
        end)
    end

    STORAGE.versions[prg] = { name = prg, version = version }
    return STORAGE.versions[prg]
end

local function async_insert_version(prg)
    local versioner = RELOAD('jobs'):new {
        cmd = prg .. ' --version',
        silent = true,
    }
    versioner:callback_on_success(function(job)
        local version = get_prg_version(table.concat(job:output(), ' '))
        insert_version(prg, version)
    end)
    versioner:start()
end

local function sync_insert_version(prg)
    local output = vim.fn.system(prg .. ' --version')
    return insert_version(prg, get_prg_version(output))
end

function M.get_prg_info(prg)
    assert(type(prg) == type '' and prg ~= '', debug.traceback('Invalid program: ' .. vim.inspect(prg)))
    if sqlite then
        return sqlite.with_open(db_path, function(db)
            return db:select('versions', { where = { name = prg } })
        end)[1]
    end
    return STORAGE.versions[prg]
end

function M.check_version(sys_version, version_target)
    assert(type(sys_version) == type {}, debug.traceback 'System version must be an array')
    assert(type(version_target) == type {}, debug.traceback 'Checking version must be an array')

    for i, _ in pairs(version_target) do
        if type(version_target[i]) == 'string' then
            version_target[i] = tonumber(version_target[i])
        end

        if type(sys_version[i]) == 'string' then
            sys_version[i] = tonumber(sys_version[i])
        end

        if version_target[i] > sys_version[i] then
            return false
        elseif version_target[i] < sys_version[i] then
            return true
        elseif #version_target == i and version_target[i] == sys_version[i] then
            return true
        end
    end
    return false
end

function M.get_version(prg, force)
    assert(type(prg) == type '' and prg ~= '', debug.traceback('Invalid program' .. vim.inspect(prg)))
    assert(
        not force or type(force) == type(true),
        debug.traceback('Invalid force value' .. vim.inspect(force))
    )
    local entries = M.get_prg_info(prg)
    if not entries and force then
        entries = sync_insert_version(prg)
    end
    return entries and entries.version or entries
end

function M.set_version(prg, version)
    assert(type(prg) == type '' and prg ~= '', debug.traceback('Invalid program' .. vim.inspect(prg)))
    assert(
        not version or (type(version) == type '' and version ~= ''),
        debug.traceback('Invalid version' .. vim.inspect(version))
    )

    if not version then
        async_insert_version(prg)
    else
        insert_version(prg, version)
    end
end

function M.has_version(prg, target_version)
    assert(type(prg) == type '' and prg ~= '', debug.traceback('Invalid program' .. vim.inspect(prg)))
    assert(
        not target_version or (type(target_version) == type {} and vim.tbl_islist(target_version)),
        debug.traceback('Invalid version' .. vim.inspect(target_version))
    )

    if not vim.fn.executable(prg) ~= 1 then
        return false
    end

    local version = M.get_version(prg, true)

    if not target_version or #target_version == 0 then
        return version
    end

    local system_version = require('utils.strings').split_components(version, '%d+')

    return M.check_version(system_version, target_version)
end

function M.setup()
    local tbl_exists
    if sqlite then
        tbl_exists = sqlite.with_open(db_path, function(db)
            return db:exists 'versions'
        end)
    else
        tbl_exists = STORAGE.versions
    end

    if not tbl_exists then
        if sqlite then
            sqlite.with_open(db_path, function(db)
                if not db:exists 'versions' then
                    db:create('versions', {
                        name = { 'text', 'primary', 'key' },
                        version = { 'text' },
                    })
                end
            end)
        elseif not STORAGE.versions then
            STORAGE.versions = {}
        end

        for _, prg in pairs { 'git', 'python3' } do
            async_insert_version(prg)
        end
    end
end

return M

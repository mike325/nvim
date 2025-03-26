local sqlite = vim.F.npcall(require, 'sqlite')

local db_path = STORAGE.db_path

local M = {}

local function get_prg_version(output)
    return table.concat(require('utils.strings').split_components(output, '%d+'), '.')
end

local function async_insert_version(prg)
    local insert_row = RELOAD('storage.utils').insert_row

    local versioner = RELOAD('jobs'):new {
        cmd = prg .. ' --version',
        silent = true,
        callbacks_on_success = function(job)
            local version = get_prg_version(table.concat(job:output(), ' '))
            insert_row('versions', { name = prg, version = version })
        end,
    }
    versioner:start()
end

local function sync_insert_version(prg)
    local insert_row = RELOAD('storage.utils').insert_row

    local output = vim.fn.system(prg .. ' --version')
    return insert_row('versions', { name = prg, version = get_prg_version(output) })
end

function M.get_prg_info(prg)
    vim.validate('program', prg, { 'string' })
    if sqlite then
        return sqlite.with_open(db_path, function(db)
            return db:select('versions', { where = { name = prg } })
        end)[1]
    end
    return STORAGE.versions[prg]
end

function M.check_version(sys_version, target_version)
    vim.validate('system_version', sys_version, 'table')
    vim.validate('target_version', target_version, 'table')

    for i, _ in pairs(target_version) do
        if type(target_version[i]) == 'string' then
            target_version[i] = tonumber(target_version[i])
        end

        if type(sys_version[i]) == 'string' then
            sys_version[i] = tonumber(sys_version[i])
        end

        if target_version[i] > sys_version[i] then
            return false
        elseif target_version[i] < sys_version[i] then
            return true
        elseif #target_version == i and target_version[i] == sys_version[i] then
            return true
        end
    end
    return false
end

function M.get_version(prg, force)
    vim.validate('program', prg, 'string', false)
    vim.validate('force', force, 'boolean', true)
    local entries = M.get_prg_info(prg)
    if not entries and force then
        entries = sync_insert_version(prg)
    end
    return entries and entries.version or entries
end

function M.set_version(prg, version)
    vim.validate('program', prg, 'string')
    vim.validate('version', version, 'string', true)

    if not version then
        async_insert_version(prg)
    else
        local insert_row = RELOAD('storage.utils').insert_row
        insert_row('versions', { name = prg, version = version })
    end
end

function M.has_version(prg, target_version)
    vim.validate('program', prg, 'string')
    vim.validate('target_version', target_version, { 'string', 'table' }, true)

    if not require('utils.files').executable(prg) then
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
    local tbl_exists = RELOAD('storage.utils').tbl_exists 'versions'
    if not tbl_exists then
        local create_tbl = RELOAD('storage.utils').create_tbl
        create_tbl('versions', { name = { 'text', 'primary', 'key' }, version = { 'text' } })
        -- BUG: This creates a race condition and throw startup errors when sqlite is missing
        -- for _, prg in pairs { 'git', 'python3' } do
        --     async_insert_version(prg)
        -- end
    end
end

return M

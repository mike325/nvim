local stdpath = vim.fn.stdpath

local function system_name()
    local name = jit.os:lower()
    return name
end

local function homedir()
    local home = vim.loop.os_homedir()
    return home:gsub('\\', '/')
end

local function basedir()
    return stdpath('config'):gsub('\\', '/')
end

local function cachedir()
    return stdpath('cache'):gsub('\\', '/')
end

local function datadir()
    return stdpath('data'):gsub('\\', '/')
end

local function luajit_version()
    return vim.split(jit.version, ' ')[2]
end

local function has_sqlite()
    local os = system_name()
    -- TODO: search for dll in windows, .so in linux
    if os == 'windows' then
        local sqlite_path = (cachedir() .. '/sqlite3.dll'):gsub('\\', '/')
        if vim.fn.filereadable(sqlite_path) == 1 then
            vim.g.sqlite_clib_path = sqlite_path
            return true
        end
        return false
    end
    return vim.fn.executable 'sqlite3' == 1
end

local function db_root_path()
    local root = stdpath('data'):gsub('\\', '/') .. '/databases'
    if vim.fn.isdirectory(root) ~= 1 then
        vim.fn.mkdir(root, 'p')
    end
    return root
end

local sys = {
    name = system_name(),
    home = homedir(),
    base = basedir(),
    data = datadir(),
    cache = cachedir(),
    luajit = luajit_version(),
    db_root = db_root_path(),
    has_sqlite = has_sqlite(),
    user = vim.loop.os_get_passwd(),
}

sys.user.name = sys.user.username

function sys.tmp(filename)
    local tmpdir = sys.name == 'windows' and 'c:/temp/' or '/tmp/'
    return tmpdir .. filename
end

return sys

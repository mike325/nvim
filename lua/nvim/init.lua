require 'globals'

local function get_autocmd(opts)
    vim.validate {
        opts = { opts, 'table', true },
    }
    opts = opts or {}

    return vim.F.npcall(vim.api.nvim_get_autocmds, opts) or {}
end

local function get_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            function(n)
                return type(n) == type '' or type(n) == type(0)
            end,
            'Augroup name string or id number',
        },
    }
    return get_autocmd { group = name_id }
end

local function get_augroup_id(name)
    local groups = get_augroup(name)
    if #groups > 0 then
        return groups[1].group
    end
    return -1
end

-- local function get_augroup_name(id)
--     local groups = get_augroup(id)
--     if #groups > 0 then
--         return
--     end
-- end

local function add_augroup(name, clear)
    vim.validate {
        name = { name, 'string' },
        clear = { clear, 'boolean', true },
    }

    local groups = get_augroup(name)
    if #groups == 0 or clear then
        return vim.api.nvim_create_augroup(name, { clear = clear == true })
    end
    return groups[1].group
end

local function clear_augroup(name)
    vim.validate {
        name = { name, 'string' },
    }
    vim.api.nvim_create_augroup(name, { clear = true })
end

local function del_augroup(name_id)
    vim.validate {
        name_id = {
            name_id,
            function(n)
                return type(n) == type '' or type(n) == type(0)
            end,
            'Augroup name string or id number',
        },
    }

    local api_call = type(name_id) == type '' and vim.api.nvim_del_augroup_by_name or vim.api.nvim_del_augroup_by_id
    pcall(api_call, name_id)
    -- local ok, _ = pcall(api_call, name_id)
    -- NOTE: May disable notifications and do a silent fail
    -- if not ok then
    --     vim.notify(('Augroup %s does not exists'):format(name_id), vim.log.levels.WARN, { title = 'Augroup delete' })
    -- end
end

local function add_autocmd(event, opts)
    vim.validate {
        opts = { opts, 'table', true },
        event = {
            event,
            function(e)
                return type(e) == type '' or vim.islist(e)
            end,
            'an array of events or a event string',
        },
    }

    local clear = opts.clear
    opts.clear = nil

    if opts.group then
        add_augroup(opts.group)
    end

    if clear and opts.group then
        clear_augroup(opts.group)
    end

    return vim.api.nvim_create_autocmd(event, opts)
end

local function add_command(name, cmd, opts)
    vim.validate {
        name = { name, 'string' },
        cmd = {
            cmd,
            function(c)
                return type(c) == type '' or vim.is_callable(c)
            end,
            'a string or a lua function',
        },
        opts = { opts, 'table', true },
    }
    opts = opts or {}
    if opts.buffer then
        local buffer = type(opts.buffer) == type(0) and opts.buffer or 0
        opts.buffer = nil
        vim.api.nvim_buf_create_user_command(buffer, name, cmd, opts)
    else
        vim.api.nvim_create_user_command(name, cmd, opts)
    end
end

local function del_command(name, buffer)
    vim.validate {
        name = { name, 'string' },
        buffer = {
            buffer,
            function(b)
                return not b or type(b) == type(true) or type(b) == type(0)
            end,
            'a boolean or a number',
        },
    }
    if buffer then
        buffer = type(buffer) == type(0) and buffer or 0
        vim.api.nvim_buf_del_user_command(buffer, name)
    else
        vim.api.nvim_del_user_command(name)
    end
end

local function get_lazypath()
    local lazy_root = string.format('%s/lazy', vim.fn.stdpath 'data')
    vim.g.lazypath = vim.g.lazypath or string.format('%s/lazy.nvim', lazy_root)
    return vim.g.lazypath
end

local function get_mini_path()
    local path_package = (vim.fn.stdpath 'data') .. '/site'
    local mini_path = path_package .. '/pack/deps/start/mini.nvim'

    local lazy_root = get_lazypath()
    if vim.uv.fs_stat(lazy_root) then
        mini_path = string.format('%s/mini.nvim', vim.fs.dirname(lazy_root))
    else
        local locations = {
            'deps',
            'host',
            'packer',
        }
        for _, location in ipairs(locations) do
            local plugin_loc = path_package .. string.format('/pack/%s/start/mini.nvim', location)
            if vim.uv.fs_stat(plugin_loc) then
                mini_path = plugin_loc
                break
            end
        end
    end
    return mini_path
end

local function clone_repo(repo, path, branch)
    if vim.fn.executable 'git' ~= 1 then
        return false
    end
    vim.fn.mkdir(vim.fs.dirname(path), 'p')
    vim.notify('Downloading repo...', vim.log.levels.INFO, { title = 'Clone' })

    local url = repo:match '^%w+://' and repo or string.format('https://github.com/%s.git', repo)
    local cmd = {
        'git',
        'clone',
        '--filter=blob:none',
        url,
    }

    if branch then
        table.insert(cmd, string.format('--branch=%s', branch))
    end
    table.insert(cmd, path)

    local out = vim.fn.system(cmd)
    if vim.v.shell_error == 0 then
        vim.notify((out or 'Repo cloned to: ') .. path, vim.log.levels.INFO, { title = 'Repo cloned' })
    else
        vim.notify(
            string.format('Failed to clone repo!! exit code: %d', vim.v.shell_error),
            vim.log.levels.ERROR,
            { title = 'Clone' }
        )
    end
    return vim.v.shell_error == 0
end

local function download_lazy(lazypath)
    lazypath = lazypath or get_lazypath()
    local repo = 'folke/lazy.nvim'
    vim.g.lazy_setup = clone_repo(repo, lazypath, 'stable')
    if vim.g.lazy_setup then
        vim.opt.rtp:prepend(lazypath)
    end
    return vim.g.lazy_setup
end

local function download_mini(mini_path)
    mini_path = mini_path or get_mini_path()
    local repo = 'echasnovski/mini.nvim'
    vim.g.mini_setup = clone_repo(repo, mini_path)
    return vim.g.mini_setup
end

local function setup_mini(download)
    vim.validate {
        download = { download, 'boolean', true },
    }

    vim.g.mini_path = get_mini_path()
    vim.g.mini_setup = vim.uv.fs_stat(vim.g.mini_path) ~= nil

    if vim.g.mini_setup and vim.g.mini_path:match '/lazy' then
        vim.opt.rtp:prepend(vim.g.mini_path)
        vim.cmd.helptags 'ALL'
    elseif vim.g.mini_setup then
        vim.cmd 'packadd mini.nvim | helptags ALL'
    elseif download and vim.fn.executable 'git' == 1 and vim.fn.input 'Download mini.nvim? (y for yes): ' == 'y' then
        vim.g.mini_setup = download_mini(vim.g.mini_path)
        if vim.g.mini_path:match '/lazy' then
            vim.opt.rtp:prepend(vim.g.mini_path)
            vim.cmd.helptags 'ALL'
        else
            vim.cmd 'packadd mini.nvim | helptags ALL'
        end
        vim.notify('Installed `mini.nvim`', vim.log.levels.INFO, { title = 'Mini' })
        vim.cmd.redraw()
    end

    if vim.g.mini_setup then
        local MiniDeps = require 'mini.deps'
        MiniDeps.setup { path = { package = (vim.fn.stdpath 'data') .. '/site/' } }

        MiniDeps.now(function()
            require 'configs.mini'
        end)

        MiniDeps.later(function()
            pcall(vim.cmd.packadd, { bang = true, args = { 'LuaSnip' } })
            pcall(require, 'configs.luasnip')
        end)
    end
    return vim.g.mini_setup
end

local function setup_lazy(download)
    vim.validate {
        download = { download, 'boolean', true },
    }

    vim.g.lazypath = get_lazypath()
    vim.g.lazy_setup = vim.uv.fs_stat(vim.g.lazypath) ~= nil

    if vim.g.lazy_setup then
        vim.opt.rtp:prepend(vim.g.lazypath)
    elseif download and vim.fn.executable 'git' == 1 and vim.fn.input 'Download lazy? (y for yes): ' == 'y' then
        vim.g.lazy_setup = download_lazy(vim.g.lazypath)
    end

    if vim.g.lazy_setup then
        require('lazy').setup('plugins', {
            ui = { border = 'rounded' },
            -- dev = { path = vim.g.projects_dir },
            install = {
                missing = false, -- Do not automatically install on startup.
            },
            -- change_detection = { notify = false },
            performance = {
                rtp = {
                    disabled_plugins = {
                        'gzip',
                        'netrwPlugin',
                        'rplugin',
                        'tarPlugin',
                        'tohtml',
                        'tutor',
                        'zipPlugin',
                    },
                },
            },
        })
    end

    return vim.g.lazy_setup
end

-- Took from https://github.com/norcalli/nvim_utils
-- GPL3 apply to the nvim object
local nvim = {
    plugins = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]

            if x ~= nil then
                return x
            end

            local plugins = vim.F.npcall(vim.api.nvim_get_var, 'plugs') or {}
            if plugins[k] then
                mt[k] = plugins[k]
                return plugins[k]
            end

            local lazy = vim.F.npcall(require, 'lazy')
            if lazy then
                plugins = lazy.plugins()
                for _, plugin in ipairs(plugins) do
                    if plugin.name == k then
                        mt[k] = plugin
                        return plugin
                    end
                end
            end

            if packer_plugins then
                plugins = packer_plugins
                if plugins[k] and plugins[k].loaded then
                    return plugins[k]
                end
            end

            return nil
        end,
    }),
    has = setmetatable({
        cmd = function(cmd)
            return vim.api.nvim_call_function('exists', { ':' .. cmd }) == 2
        end,
        command = function(command)
            return vim.api.nvim_call_function('exists', { ':' .. command }) == 2
        end,
        event = function(event)
            return vim.api.nvim_call_function('exists', { '##' .. event }) == 2
        end,
        augroup = function(augroup)
            return vim.api.nvim_call_function('exists', { '#' .. augroup }) == 1
        end,
        option = function(option)
            return vim.api.nvim_call_function('exists', { '+' .. option }) == 1
        end,
        func = function(func)
            return vim.api.nvim_call_function('exists', { '*' .. func }) == 1
        end,
    }, {
        __call = function(_, feature)
            if type(feature) == type {} then
                vim.validate {
                    version = { feature, vim.islist, 'a nvim version string to list' },
                }
                local nvim_version = {
                    vim.version().major,
                    vim.version().minor,
                    vim.version().patch,
                }
                return require('storage').check_version(nvim_version, feature)
            end
            return vim.api.nvim_call_function('has', { feature }) == 1
        end,
    }),
    exists = setmetatable({
        cmd = function(cmd)
            return vim.api.nvim_call_function('exists', { ':' .. cmd }) == 2
        end,
        command = function(command)
            return vim.api.nvim_call_function('exists', { '##' .. command }) == 2
        end,
        augroup = function(augroup)
            return vim.api.nvim_call_function('exists', { '#' .. augroup }) == 1
        end,
        option = function(option)
            return vim.api.nvim_call_function('exists', { '+' .. option }) == 1
        end,
        func = function(func)
            return vim.api.nvim_call_function('exists', { '*' .. func }) == 1
        end,
    }, {
        __call = function(_, feature)
            return vim.api.nvim_call_function('exists', { feature }) == 1
        end,
    }),
    env = setmetatable({}, {
        __index = function(_, k)
            local value = vim.F.npcall(vim.api.nvim_call_function, 'getenv', { k })
            if not value then
                value = vim.api.nvim_call_function('expand', { '$' .. k })
                value = value == k and nil or value
            end
            return value or nil
        end,
        __newindex = function(_, k, v)
            if not pcall(vim.api.nvim_call_function, 'setenv', { k, v }) then
                v = type(v) == 'string' and '"' .. v .. '"' or v
                local _ = vim.api.nvim_eval('let $' .. k .. ' = ' .. v)
            end
        end,
    }),
    ex = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local command = k:gsub('_$', '!')
            local f = function(...)
                return vim.api.nvim_command(table.concat(vim.iter({ command, ... }):flatten():totable(), ' '))
            end
            mt[k] = f
            return f
        end,
    }),
    buf = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = vim.api['nvim_buf_' .. k]
            mt[k] = f
            return f
        end,
    }),
    win = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = vim.api['nvim_win_' .. k]
            mt[k] = f
            return f
        end,
    }),
    tab = setmetatable({}, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local f = vim.api['nvim_tabpage_' .. k]
            mt[k] = f
            return f
        end,
    }),
    reg = setmetatable({}, {
        __index = function(_, k)
            return vim.F.npcall(vim.api.nvim_call_function, 'getreg', { k })
        end,
        __newindex = function(_, k, v)
            if v == nil then
                error "Can't clear registers"
            end
            pcall(vim.api.nvim_call_function, 'setreg', { k, v })
        end,
    }),
    -- keymap = require('nvim.mappings').keymap,
    command = {
        set = add_command,
        del = del_command,
    },
    augroup = setmetatable({
        add = add_augroup,
        del = del_augroup,
        get = get_augroup,
        get_id = get_augroup_id,
        clear = clear_augroup,
    }, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_augroup(k)
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == type '' and k ~= '' then
                if v == nil then
                    del_augroup(k)
                elseif type(v) == type {} then
                    local autocmds
                    if vim.islist(v) then
                        autocmds = vim.deepcopy(v)
                    else
                        autocmds = { v }
                    end
                    local clear = true
                    for _, aucmd in ipairs(autocmds) do
                        local opts = aucmd
                        local event = opts.event
                        opts.event = nil
                        if event then
                            add_augroup(k, clear)
                            clear = false
                            opts.group = k
                            add_autocmd(event, opts)
                        else
                            error(debug.traceback 'Missing autocmd event!')
                        end
                    end
                end
            end
        end,
    }),
    autocmd = setmetatable({
        add = add_autocmd,
        get = get_autocmd,
        del = function(id)
            vim.validate {
                id = { id, 'number' },
            }
            pcall(vim.api.nvim_del_autocmd, id)
        end,
    }, {
        __index = function(self, k)
            local mt = getmetatable(self)
            local x = mt[k]
            if x ~= nil then
                return x
            end
            local cmds = get_autocmd { event = k }
            return #cmds > 0 and cmds or nil
        end,
        __newindex = function(_, k, v)
            if type(k) == type '' and k ~= '' and type(v) == type {} then
                local autocmds
                if vim.islist(v) then
                    autocmds = vim.deepcopy(v)
                else
                    autocmds = { v }
                end
                local clear = true
                for _, aucmd in ipairs(autocmds) do
                    local opts = aucmd
                    local event = opts.event
                    opts.event = nil
                    if event then
                        add_augroup(k, clear)
                        clear = false
                        opts.group = k
                        add_autocmd(event, opts)
                    else
                        error(debug.traceback 'Missing autocmd event!')
                    end
                end
            end
        end,
    }),
    executable = function(exe)
        vim.validate { exe = { exe, 'string' } }
        return vim.fn.executable(exe) == 1
    end,
    setup = setmetatable({
        lazy = setup_lazy,
        get_lazypath = get_lazypath,
        download_lazy = download_lazy,
        mini = setup_mini,
        get_mini_path = get_mini_path,
        download_mini = download_mini,
    }, {
        __call = function(_, download)
            if not vim.g.bare and not vim.g.minimal then
                setup_lazy(download)
            elseif vim.g.minimal and not vim.g.bare then
                setup_mini(download)
            end
        end,
    }),
}

setmetatable(nvim, {
    __index = function(self, k)
        local mt = getmetatable(self)
        if mt[k] then
            return mt[k]
        end

        local x = vim.F.npcall(RELOAD, 'nvim.' .. k)
        if not x then
            x = vim.api['nvim_' .. k]
            if not x then
                x = vim[k]
            end
        end

        return x
    end,
})

return nvim

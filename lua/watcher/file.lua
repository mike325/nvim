local realpath = require('utils.files').realpath
local normalize = require('utils.files').normalize

local Watcher = {}
Watcher.__index = Watcher

-- TODO: Check if this will still works if the file is removed and re-created
local function on_change(watcher, err, _, status)
    -- Do work...
    if not watcher._wait then
        for _, cb in ipairs(watcher._cb) do
            cb(err, watcher._filename, status)
        end

        for _, autocmd_name in ipairs(watcher._autocmd) do
            vim.api.nvim_exec_autocmds('User', {
                pattern = autocmd_name,
                group = vim.api.nvim_create_augroup('Watcher', { clear = false }),
                data = {
                    err = err,
                    fname = watcher._filename,
                    status = status,
                },
            })
        end
    end

    -- Debounce: stop/start.
    watcher:stop()
    vim.defer_fn(function()
        watcher:start()
    end, 100)
end

-- TODO: Add support for autocmd groups ?
function Watcher:new(filename, autocmd, cb)
    vim.validate {
        filename = { filename, 'string' },
        autocmd = { autocmd, { 'function', 'string' } },
        cb = { cb, { 'function' }, true },
    }

    filename = realpath(normalize(filename))

    if not cb and type(autocmd) == 'function' then
        cb = { autocmd }
        autocmd = {}
    elseif type(autocmd) == type '' then
        autocmd = { autocmd }
    end

    if type(cb) ~= type {} then
        cb = { cb }
    end

    -- NOTE: Allow just 1 watcher per file
    local watcher_obj
    if STORAGE.watchers[filename] then
        watcher_obj = STORAGE.watchers[filename]

        for _, callback in ipairs(cb or {}) do
            watcher_obj:subscribe(callback)
        end

        for _, au in ipairs(autocmd or {}) do
            watcher_obj:subscribe(au)
        end
    else
        local watcher = vim.uv.new_fs_event()
        local obj = {
            _filename = filename,
            _watcher = watcher,
            _cb = cb or {},
            _autocmd = autocmd or {},
            _wait = false,
        }

        STORAGE.watchers[filename] = setmetatable(obj, self)
    end

    return STORAGE.watchers[filename]
end

-- NOTE: For some reason we get notified more than once, need this flag and a defer to
-- mitigate this and get just 1 notification per change
function Watcher:start()
    self._wait = false
    self._watcher:start(
        self._filename,
        {
            watch_entry = false, -- true = when dir, watch dir inode, not dir content
            stat = false, -- true = don't use inotify/kqueue but periodic check, not implemented
            recursive = false, -- true = watch dirs inside dirs
        },
        vim.schedule_wrap(function(...)
            on_change(self, ...)
        end)
    )
end

function Watcher:stop()
    self._wait = true
    self._watcher:stop()
end

function Watcher:restart()
    self:stop()
    self:start()
end

function Watcher:reset()
    self:stop()
    self._cb = {}
    self._autocmd = {}
end

function Watcher:is_active()
    return self._watcher:is_active()
end

function Watcher:subscribe(cb)
    vim.validate {
        cb = { cb, { 'function', 'string' } },
    }

    if type(cb) == type '' then
        -- NOTE: Do not duplicate autocmds
        if not vim.list_contains(self._autocmd, cb) then
            table.insert(self._autocmd, cb)
        end
    else
        table.insert(self._cb, cb)
    end
end

return Watcher

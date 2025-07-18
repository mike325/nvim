local utils = require 'completions.utils'
local utils_io = require 'utils.files'

local diagnostic_actions = {
    '-enable',
    '-disable',
    '-dump',
    '-clear',
    '-show',
    '-hide',
}

local completions = {}
completions = vim.tbl_extend('force', completions, {
    ssh_hosts_completion = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(STORAGE.hosts))
    end,
    oscyank = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, { 'tmux', 'kitty', 'default' })
    end,
    gitfiles_workspace = function(arglead, cmdline, cursorpos)
        local gitstatus = require('utils.git').status()
        local files = vim.tbl_keys(gitstatus.workspace)
        vim.list_extend(files, gitstatus.untracked)
        return utils.general_completion(arglead, cmdline, cursorpos, require('utils.tables').uniq_unorder(files))
    end,
    gitfiles_stage = function(arglead, cmdline, cursorpos)
        local gitstatus = require('utils.git').status()
        local files = vim.tbl_keys(gitstatus.stage)
        return utils.general_completion(arglead, cmdline, cursorpos, files)
    end,
    session_files = function(arglead, cmdline, cursorpos)
        local sessions = utils_io.get_files(require('sys').session)
        return utils.general_completion(arglead, cmdline, cursorpos, vim.tbl_map(vim.fs.basename, sessions))
    end,
    spells = function(arglead, cmdline, cursorpos)
        local spells = utils_io.get_files(require('sys').base .. '/spell')
        spells = vim.tbl_map(function(spell)
            return (vim.fs.basename(spell):gsub('%..*', ''))
        end, spells)
        return utils.general_completion(arglead, cmdline, cursorpos, spells)
    end,
    zoom_links = function(arglead, cmdline, cursorpos)
        return utils.json_keys_completion(arglead, cmdline, cursorpos, '~/.config/zoom/links.json')
    end,
    toggle = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, { 'enable', 'disable' })
    end,
    toggle_dash = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, { '-enable', '-disable' })
    end,
    reload_configs = function(arglead, cmdline, cursorpos)
        local get_files = function(path)
            return vim.iter(vim.fs.dir(vim.fs.joinpath(vim.fn.stdpath 'config', path)))
                :filter(function(c)
                    return c:match '%.lua$' or c:match '%.vim'
                end)
                :map(function(c)
                    return require('utils.files').filename(vim.fs.basename(c))
                end)
                :totable()
        end
        local uniq = require('utils.tables').merge_uniq_unorder
        local files = { 'all' }
        files = uniq(files, get_files 'plugin')
        files = uniq(files, get_files 'after/plugin')

        local comp_func = utils.get_completion(files)
        return comp_func(arglead, cmdline, cursorpos, files)
    end,
    severity_list = function(arglead, cmdline, cursorpos)
        local severity_lst = vim.tbl_filter(function(s)
            return #tostring(s) > 1
        end, vim.diagnostic.severity)
        return utils.general_completion(arglead, cmdline, cursorpos, severity_lst)
    end,
    background_tasks = function(arglead, cmdline, cursorpos)
        local tasks = {}
        for hash, task in pairs(ASYNC.tasks) do
            local cmd = vim.json.decode(vim.base64.decode(hash)).cmd
            tasks[#tasks + 1] = ('%s: %s'):format(task.pid, cmd[1])
        end
        return utils.general_completion(arglead, cmdline, cursorpos, tasks)
    end,
    diagnostics_virtual_lines = function(arglead, cmdline, cursorpos)
        local nvim = require 'nvim'

        local options = { 'text' }
        if nvim.has { 0, 11 } then
            table.insert(options, 'lines')
        end
        return utils.general_completion(arglead, cmdline, cursorpos, options)
    end,
    diagnostics_namespaces = function(arglead, cmdline, cursorpos)
        local namespaces = vim.iter(vim.diagnostic.get_namespaces())
            :map(function(d)
                return d.name
            end)
            :totable()
        return utils.general_nodash_completion(arglead, cmdline, cursorpos, namespaces)
    end,
    diagnostics_actions = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, diagnostic_actions)
    end,
    diagnostics_level = function(arglead, cmdline, cursorpos)
        local levels = vim.deepcopy(vim.log.levels)
        levels.OFF = nil
        return utils.general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(levels))
    end,
    diagnostics_completion = function(arglead, cmdline, cursorpos)
        local cmd = utils.get_cmd(cmdline)

        if #cmd <= 1 or (#cmd == 2 and arglead:match '[%-%w]+$') then
            return completions.diagnostics_actions(arglead, cmdline, cursorpos)
        end
        if cmd[#cmd] == '-dump' then
            return completions.diagnostics_level(arglead, cmdline, cursorpos)
        end
        return completions.diagnostics_namespaces(arglead, cmdline, cursorpos)
    end,
    buflist = function(arglead, cmdline, cursorpos)
        local cwd = vim.pesc(vim.uv.cwd() .. '/')
        local buffers = vim.iter(vim.api.nvim_list_bufs())
            :map(function(buf)
                return (vim.api.nvim_buf_get_name(buf):gsub(cwd, ''))
            end)
            :filter(function(bufname)
                return bufname ~= '' and not bufname:match '^%w+://' and not bufname:match '^Mini%w+:.*'
            end)
        return utils.general_completion(arglead, cmdline, cursorpos, buffers:totable())
    end,
    reviewers = function(arglead, cmdline, cursorpos)
        local reviewers = {}
        if require('utils.files').is_file 'reviewers.json' then
            reviewers = require('utils.files').read_json 'reviewers.json'
            local cmd = utils.get_cmd(cmdline)

            local tmp = {}
            for _, reviewer in ipairs(reviewers) do
                if not vim.list_contains(cmd, reviewer) then
                    table.insert(tmp, reviewer)
                end
            end

            reviewers = tmp
        end
        return utils.general_completion(arglead, cmdline, cursorpos, reviewers)
    end,
    gh_edit_reviewers = function(arglead, cmdline, cursorpos)
        local cmd = utils.get_cmd(cmdline)

        if #cmd == 1 or (#cmd == 2 and cmdline:sub(#cmdline, #cmdline) ~= ' ') then
            return utils.general_completion(arglead, cmdline, cursorpos, { '-add', '-remove' })
        end

        local reviewers = {}
        if require('utils.files').is_file 'reviewers.json' then
            reviewers = require('utils.files').read_json 'reviewers.json'

            local tmp = {}
            for _, reviewer in ipairs(reviewers) do
                if not vim.list_contains(cmd, reviewer) then
                    table.insert(tmp, reviewer)
                end
            end

            reviewers = tmp
        end
        return utils.general_nodash_completion(arglead, cmdline, cursorpos, reviewers)
    end,
    gh_pr_ready = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, { 'ready', 'draft' })
    end,
    lua_tests = function(arglead, cmdline, cursorpos)
        return utils.general_completion(
            arglead,
            cmdline,
            cursorpos,
            vim.fn.globpath('lua/tests', '**/*_spec.lua', true, true)
        )
    end,
    dap_commands = function(arglead, cmdline, cursorpos)
        local cmds = {
            'stop',
            'start',
            'continue',
            'restart',
            'repl',
            'breakpoint',
            'list',
            'clear',
            'run2cursor',
            'clear_virtual_text',
            'remote_attach',
            -- 'remote_run',
        }
        return utils.general_completion(arglead, cmdline, cursorpos, cmds)
    end,
    namespaces = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(vim.api.nvim_get_namespaces()))
    end,
    lsp_configs = function(arglead, cmdline, cursorpos)
        local configs = vim.api.nvim_get_runtime_file('after/lsp/*.lua', true)
        local confignames = vim.iter(configs)
            :map(vim.fs.basename)
            :map(require('utils.files').filename)
            :filter(function(configname)
                local config = vim.lsp.config[configname]
                return vim.list_contains(config.filetypes, vim.bo.filetype)
            end)
            :totable()
        return utils.general_completion(arglead, cmdline, cursorpos, confignames)
    end,
    lsp_clients = function(arglead, cmdline, cursorpos)
        local servers = vim.iter(vim.lsp.get_clients())
            :map(function(client)
                return string.format('%d:%s', client.id, client.name)
            end)
            :totable()
        return utils.general_completion(arglead, cmdline, cursorpos, servers)
    end,
    local_labels = function(arglead, cmdline, cursorpos)
        local labels = require('configs.mini.utils').get_labels(false)
        return utils.general_completion(arglead, cmdline, cursorpos, labels)
    end,
    global_labels = function(arglead, cmdline, cursorpos)
        local labels = require('configs.mini.utils').get_labels(true)
        return utils.general_completion(arglead, cmdline, cursorpos, labels)
    end,
})

return completions

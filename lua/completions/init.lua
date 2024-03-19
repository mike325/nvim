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
    build_type = function(arglead, cmdline, cursorpos)
        return utils.general_completion(
            arglead,
            cmdline,
            cursorpos,
            vim.tbl_keys(require 'filetypes.cpp.build_types')
        )
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
    fileformats = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, { 'unix', 'dos' })
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
        return utils.general_completion(
            arglead,
            cmdline,
            cursorpos,
            { 'all', 'mappings', 'commands', 'autocmds', 'options' }
        )
    end,
    severity_list = function(arglead, cmdline, cursorpos)
        local severity_lst = vim.tbl_filter(function(s)
            return #tostring(s) > 1
        end, vim.diagnostic.severity)
        return utils.general_completion(arglead, cmdline, cursorpos, severity_lst)
    end,
    background_jobs = function(arglead, cmdline, cursorpos)
        local jobs = {}
        for id, job in pairs(STORAGE.jobs) do
            -- NOTE: this gives very little context about the cmd arguments and what is running
            -- We need a more unique identifier but also a descriptive enough one to know what's
            -- executing
            table.insert(jobs, id .. ':' .. job.exe)
        end
        return utils.general_completion(arglead, cmdline, cursorpos, jobs)
    end,
    diagnostics_namespaces = function(arglead, cmdline, cursorpos)
        local namespaces = {}
        for _, ns in pairs(vim.diagnostic.get_namespaces()) do
            table.insert(namespaces, ns.name)
        end
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
        local cmd = vim.tbl_map(function(arg)
            return vim.trim(arg)
        end, vim.split(cmdline, '%s+', { trimempty = true }))

        if #cmd <= 1 or (#cmd == 2 and arglead:match '[%-%w]+$') then
            return completions.diagnostics_actions(arglead, cmdline, cursorpos)
        end
        if cmd[#cmd] == '-dump' then
            return completions.diagnostics_level(arglead, cmdline, cursorpos)
        end
        return completions.diagnostics_namespaces(arglead, cmdline, cursorpos)
    end,
    qf_file_options = function(arglead, cmdline, cursorpos)
        local options = {
            '-hunks',
            '-qf',
            '-open',
            '-background',
        }
        return utils.general_completion(arglead, cmdline, cursorpos, options)
    end,
    bufkill_options = function(arglead, cmdline, cursorpos)
        local options = {
            '-cwd',
            '-empty',
        }
        return utils.general_completion(arglead, cmdline, cursorpos, options)
    end,
    arglist = function(arglead, cmdline, cursorpos)
        return utils.general_completion(arglead, cmdline, cursorpos, vim.fn.argv())
    end,
    buflist = function(arglead, cmdline, cursorpos)
        local cwd = vim.pesc(vim.loop.cwd() .. '/')
        local buffers = vim.tbl_filter(
            function(buf)
                return buf ~= ''
            end,
            vim.tbl_map(function(buf)
                return (vim.api.nvim_buf_get_name(buf):gsub(cwd, ''))
            end, vim.api.nvim_list_bufs())
        )
        return utils.general_completion(arglead, cmdline, cursorpos, buffers)
    end,
    reviewers = function(arglead, cmdline, cursorpos)
        local reviewers = {}
        if require('utils.files').is_file 'reviewers.json' then
            reviewers = require('utils.files').read_json 'reviewers.json'

            local cmd = vim.tbl_map(function(arg)
                return vim.trim(arg)
            end, vim.split(cmdline, '%s+', { trimempty = true }))

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
        local cmd = vim.tbl_map(function(arg)
            return vim.trim(arg)
        end, vim.split(cmdline, '%s+', { trimempty = true }))

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
})

return completions

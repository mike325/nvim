local function general_completion(arglead, _, _, options)
    local split_components = require('utils.strings').split_components
    local dashes
    if arglead:sub(1, 2) == '--' then
        dashes = '--'
    elseif arglead:sub(1, 1) == '-' then
        dashes = '-'
    end
    local pattern = table.concat(split_components((arglead:gsub('%-', '')), '.'), '.*')
    pattern = pattern:lower()
    local results = vim.tbl_filter(function(opt)
        return opt:lower():match(pattern) ~= nil
    end, options) or {}
    return vim.tbl_map(function(arg)
        if dashes and arg:sub(1, #dashes) ~= dashes then
            return dashes .. arg
        end
        return arg
    end, results)
end

local function general_nodash_completion(arglead, _, _, options)
    local split_components = require('utils.strings').split_components
    local pattern = table.concat(split_components(arglead, '.'), '.*')
    pattern = pattern:lower()
    local results = vim.tbl_filter(function(opt)
        return opt:lower():match(pattern) ~= nil
    end, options) or {}
    return results
end

local function json_keys_completion(arglead, cmdline, cursorpos, filename, funcs)
    funcs = funcs or {}

    local json = {}
    if require('utils.files').is_file(filename) then
        json = require('utils.files').read_json(filename)
    end
    local keys = vim.tbl_keys(json)
    if funcs.filter then
        keys = vim.tbl_filter(funcs.filter, keys)
    end
    if funcs.map then
        keys = vim.tbl_map(funcs.map, keys)
    end
    return general_completion(arglead, cmdline, cursorpos, keys)
end

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
        return general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(STORAGE.hosts))
    end,
    oscyank = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'tmux', 'kitty', 'default' })
    end,
    cmake_build = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'Debug', 'Release', 'MinSizeRel', 'RelWithDebInfo' })
    end,
    gitfiles_workspace = function(arglead, cmdline, cursorpos)
        local gitstatus = require('utils.git').status()
        local files = vim.tbl_keys(gitstatus.workspace)
        vim.list_extend(files, gitstatus.untracked)
        return general_completion(arglead, cmdline, cursorpos, require('utils.tables').uniq_unorder(files))
    end,
    gitfiles_stage = function(arglead, cmdline, cursorpos)
        local gitstatus = require('utils.git').status()
        local files = vim.tbl_keys(gitstatus.stage)
        return general_completion(arglead, cmdline, cursorpos, files)
    end,
    session_files = function(arglead, cmdline, cursorpos)
        local utils = require 'utils.files'
        local sessions = utils.get_files(require('sys').session)
        return general_completion(arglead, cmdline, cursorpos, vim.tbl_map(utils.filename, sessions))
    end,
    fileformats = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'unix', 'dos' })
    end,
    spells = function(arglead, cmdline, cursorpos)
        local utils = require 'utils.files'
        local spells = utils.get_files(require('sys').base .. '/spell')
        spells = vim.tbl_map(function(spell)
            return (utils.filename(spell):gsub('%..*', ''))
        end, spells)
        return general_completion(arglead, cmdline, cursorpos, spells)
    end,
    zoom_links = function(arglead, cmdline, cursorpos)
        return json_keys_completion(arglead, cmdline, cursorpos, '~/.config/zoom/links.json')
    end,
    toggle = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'enable', 'disable' })
    end,
    reload_configs = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'all', 'mappings', 'commands', 'autocmds', 'options' })
    end,
    severity_list = function(arglead, cmdline, cursorpos)
        local severity_lst = vim.tbl_filter(function(s)
            return #tostring(s) > 1
        end, vim.diagnostic.severity)
        return general_completion(arglead, cmdline, cursorpos, severity_lst)
    end,
    background_jobs = function(arglead, cmdline, cursorpos)
        local jobs = {}
        for id, job in pairs(STORAGE.jobs) do
            -- NOTE: this gives very little context about the cmd arguments and what is running
            -- We need a more unique identifier but also a descriptive enough one to know what's
            -- executing
            table.insert(jobs, id .. ':' .. job.exe)
        end
        return general_completion(arglead, cmdline, cursorpos, jobs)
    end,
    diagnostics_namespaces = function(arglead, cmdline, cursorpos)
        local namespaces = {}
        for _, ns in pairs(vim.diagnostic.get_namespaces()) do
            table.insert(namespaces, ns.name)
        end
        return general_nodash_completion(arglead, cmdline, cursorpos, namespaces)
    end,
    diagnostics_actions = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, diagnostic_actions)
    end,
    diagnostics_level = function(arglead, cmdline, cursorpos)
        local levels = vim.deepcopy(vim.log.levels)
        levels.OFF = nil
        return general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(levels))
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
        return general_completion(arglead, cmdline, cursorpos, options)
    end,
    bufkill_options = function(arglead, cmdline, cursorpos)
        local options = {
            '-cwd',
            '-empty',
        }
        return general_completion(arglead, cmdline, cursorpos, options)
    end,
    arglist = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, vim.fn.argv())
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
        return general_completion(arglead, cmdline, cursorpos, buffers)
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
        return general_completion(arglead, cmdline, cursorpos, reviewers)
    end,
    gh_pr_ready = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'ready', 'draft' })
    end,
    lua_tests = function(arglead, cmdline, cursorpos)
        return general_completion(
            arglead,
            cmdline,
            cursorpos,
            vim.fn.globpath('lua/tests', '**/*_spec.lua', true, true)
        )
    end,
})

return completions

local function general_completion(arglead, _, _, options)
    local split_components = require('utils.strings').split_components
    local pattern = table.concat(split_components(arglead, '.'), '.*')
    pattern = pattern:lower()
    return vim.tbl_filter(function(opt)
        return opt:lower():match(pattern) ~= nil
    end, options) or {}
end

local completions = {
    ssh_hosts_completion = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, vim.tbl_keys(STORAGE.hosts))
    end,
    oscyank = function(arglead, cmdline, cursorpos)
        return general_completion(arglead, cmdline, cursorpos, { 'tmux', 'kitty', 'default' })
    end,
    cmake_build = function(arglead, cmdline, cursorpos)
        return general_completion(
            arglead,
            cmdline,
            cursorpos,
            { 'Debug', 'Release', 'MinSizeRel', 'RelWithDebInfo' }
        )
    end,
    gitfiles_workspace = function(arglead, cmdline, cursorpos)
        local gitstatus = require('git.utils').status()
        local files = {}
        if gitstatus.workspace then
            vim.list_extend(files, vim.tbl_keys(gitstatus.workspace))
        end
        if gitstatus.untracked then
            vim.list_extend(files, gitstatus.untracked)
        end
        return general_completion(arglead, cmdline, cursorpos, files)
    end,
    gitfiles_stage = function(arglead, cmdline, cursorpos)
        local gitstatus = require('git.utils').status()
        local files = {}
        if gitstatus.stage then
            vim.list_extend(files, vim.tbl_keys(gitstatus.stage))
        end
        return general_completion(arglead, cmdline, cursorpos, files)
    end,
}

_G._completions = completions
return completions
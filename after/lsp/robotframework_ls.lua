---@brief
---
-- https://github.com/robocorp/robotframework-lsp
--
-- Language Server Protocol implementation for Robot Framework.

local exclude = {
    'xifs',
    'xtst',
    'xtestdoubles',
    'xifs-global',
    'clang',
    'matlab_mcr',
    'lxsr_glp_ls1046a',
    'lxsr_glp_ppce6500',
    'vxworks7',
    '.vscode_clangd_setup',
    '.vscode',
}

exclude = vim.iter(exclude)
    :map(function(dir)
        return string.format('"**/%s/**"', dir)
    end)
    :totable()

return {
    cmd = { 'robotframework_ls' },
    filetypes = { 'robot' },
    root_markers = { 'robotidy.toml', 'pyproject.toml', 'conda.yaml', 'robot.yaml', '.git' },
    cmd_env = {
        ROBOTFRAMEWORK_LS_WATCH_IMPL = 'fsnotify',
        ROBOTFRAMEWORK_LS_IGNORE_DIRS = string.format('[%s]', table.concat(exclude, ',')),
        PYHTONPATH = vim.env.PYTHONPATH,
    },
    settings = {
        robot = {
            python = {
                env = {
                    ROBOTFRAMEWORK_LS_WATCH_IMPL = 'fsnotify',
                    ROBOTFRAMEWORK_LS_IGNORE_DIRS = string.format('[%s]', table.concat(exclude, ',')),
                },
            },
            lint = {
                undefinedLibraries = false,
                undefinedResources = false,
                undefinedKeywords = false,
                variables = false,
            },
        },
    },
}

---@brief
---
-- https://github.com/mtshiba/pylyzer
--
-- `pylyzer`, a fast static code analyzer & language server for Python.
return {
    cmd = { 'pylyzer', '--server' },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
    settings = {
        python = {
            diagnostics = true,
            inlayHints = true,
            smartCompletion = true,
            checkOnType = false,
        },
    },
}

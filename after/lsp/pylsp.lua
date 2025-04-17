---@brief
---
-- https://github.com/python-lsp/python-lsp-server
--
-- A Python 3.6+ implementation of the Language Server Protocol.
--
-- See the [project's README](https://github.com/python-lsp/python-lsp-server) for installation instructions.
--
-- Configuration options are documented [here](https://github.com/python-lsp/python-lsp-server/blob/develop/CONFIGURATION.md).
-- In order to configure an option, it must be translated to a nested Lua table and included in the `settings` argument to the `config('pylsp', {})` function.
-- For example, in order to set the `pylsp.plugins.pycodestyle.ignore` option:
-- ```lua
-- vim.lsp.config('pylsp', {
--   settings = {
--     pylsp = {
--       plugins = {
--         pycodestyle = {
--           ignore = {'W391'},
--           maxLineLength = 100
--         }
--       }
--     }
--   }
-- })
-- ```
--
-- Note: This is a community fork of `pyls`.
return {
    cmd = {
        'pylsp',
        '--check-parent-process',
        '--log-file=/tmp/pylsp.log',
    },
    filetypes = { 'python' },
    root_markers = {
        'pyproject.toml',
        'setup.py',
        'setup.cfg',
        'requirements.txt',
        'Pipfile',
        '.git',
    },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = { snippetSupport = true },
            },
        },
    },
    settings = {
        pylsp = {
            plugins = {
                jedi = {
                    extra_paths = {},
                },
                jedi_completion = {
                    enabled = true,
                    fuzzy = true,
                    include_params = true,
                },
                flake8 = {
                    enabled = true,
                    config = './.flake8',
                },
                ruff = {
                    enabled = false, -- Enable the plugin
                    formatEnabled = false, -- Enable formatting using ruffs formatter
                },
                pylsp_mypy = { enabled = true },
                pyflakes = { enabled = true },
                mccabe = { enabled = true },
                pylint = { enabled = true },
                pycodestyle = {
                    enabled = false,
                    -- ignore = { 'W391' },
                    -- maxLineLength = 100,
                },
                black = { enabled = false },
            },
        },
    },
}

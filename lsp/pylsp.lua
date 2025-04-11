return {
    cmd = {
        'pylsp',
        '--check-parent-process',
        '--log-file=/tmp/pylsp.log',
    },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.flake8', '.git' },
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
                pycodestyle = { enabled = false },
                black = { enabled = false },
            },
        },
    },
}

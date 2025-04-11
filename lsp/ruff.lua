return {
    cmd = {
        'ruff',
        'server',
        '--preview',
        -- '--config',
        -- './ruff.toml',
    },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.ruff.toml', 'ruff.toml', '.flake8', '.git' },
}

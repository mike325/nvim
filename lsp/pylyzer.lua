return {
    cmd = {
        'pylyzer',
        '--server',
    },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.flake8', '.git' },
    settings = {
        python = {
            checkOnType = false,
            diagnostics = false,
            inlayHints = true,
            smartCompletion = true,
        },
    },
}

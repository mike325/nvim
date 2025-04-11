return {
    cmd = {
        'basedpyright',
        -- '--stdio',
        -- '--pythonplatform',
        -- 'Linux',
        -- '--pythonversion',
        -- '3.8',
        '--threads',
        vim.uv.available_parallelism(),
    },
    filetypes = { 'python' },
    root_markers = { 'pyproject.toml', '.flake8', '.git' },
    settings = {
        python = {
            analysis = {
                autoSearchPaths = true,
                diagnosticMode = 'workspace',
                useLibraryCodeForTypes = true,
                typeCheckingMode = 'basic', -- "off", "basic", "strict"
                verboseOutput = true,
                -- extraPaths = {},
                reportMissingImports = 'none',
                ['dummy-variables-rgx'] = '(Fake+[a-zA-Z0-9]*?$)|(Stub+[a-zA-Z0-9]*?$)',
            },
        },
    },
}

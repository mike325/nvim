-- TODO: change command on demand
return {
    cmd = {
        'clangd',
        '--fallback-style=Google',
        '--clang-tidy',
        '--header-insertion=iwyu',
        '--function-arg-placeholders',
        '--completion-style=bundled',
        -- '--pch-storage=memory',
        '--background-index',
        '--malloc-trim',
        '--log=error',
    },
    filetypes = {
        'c',
        'cpp',
        'objc',
        'objcpp',
        'cuda',
    },
    root_markers = {
        'compile_commands.json',
        'compile_flags.txt',
        'Makefile',
        'CMakeLists.txt',
        '.clangd',
        '.git',
    },
    cmd_env = {
        -- NOTE: pchs directory is not created by default, needs to be manually created
        TMPDIR = './.cache/clangd/pchs/',
    },
    capabilities = {
        offsetEncoding = { 'utf-16' }, -- TODO: Check if this cause side effects
        textDocument = {
            completion = {
                completionItem = { snippetSupport = true },
            },
        },
    },
    init_options = {
        usePlaceholders = true,
        completeUnimported = true,
        clangdFileStatus = true,
    },
}

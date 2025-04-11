return {
    cmd = {
        'texlab',
    },
    filetypes = { 'latex', 'tex', 'bibtex', 'bib' },
    root_markers = { '.git' },
    capabilities = {
        textDocument = {
            completion = {
                completionItem = { snippetSupport = true },
            },
        },
    },
    settings = {
        bibtex = {
            formatting = {
                lineLength = 120,
            },
        },
        latex = {
            forwardSearch = {
                args = {},
                onSave = false,
            },
            build = {
                args = {
                    '-outdir=texlab',
                    '-pdf',
                    '-interaction=nonstopmode',
                    '-synctex=1',
                    '%f',
                },
                executable = 'latexmk',
                onSave = true,
            },
            lint = {
                onChange = true,
            },
        },
    },
}

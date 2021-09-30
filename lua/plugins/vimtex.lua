local sys = require 'sys'
local executable = require('utils.files').executable

if executable 'latexmk' then
    vim.g.vimtex_compiler_method = 'latexmk'

    vim.g.vimtex_compiler_latexmk = {
        build_dir = 'build',
        callback = 1,
        continuous = 1,
        executable = 'latexmk',
        hooks = {},
        options = {
            '-pdf',
            '-shell-escape',
            '-verbose',
            '-file-line-error',
            '-synctex=1',
            '-pvc',
            '-interaction=nonstopmode',
        },
    }
elseif executable 'latexrun' then
    vim.g.vimtex_compiler_method = 'latexrun'
elseif executable 'arara' then
    vim.g.vimtex_compiler_method = 'arara'
else
    vim.g.vimtex_enabled = 0
    return false
end

vim.g.vimtex_enabled = 1
vim.g.vimtex_mappings_enabled = 0
vim.g.vimtex_quickfix_open_on_warning = 0

if sys.name == 'windows' then
    vim.vimtex_compiler_latexmk_engines = {
        ['_'] = '-pdf',
        pdflatex = '-shell-escape -synctex=1 -interaction=nonstopmode',
        dvipdfex = '-pdfdvi',
        lualatex = '-lualatex',
        xelatex = '-xelatex',
        ['context (pdftex)'] = '-shell-escape -synctex=1 -interaction=nonstopmode',
        ['context (luatex)'] = '-pdf -pdflatex=context',
        ['context (xetex)'] = "-pdf -pdflatex='texexec --xtx'",
    }
end

if sys.name == 'windows' then
    if executable 'sumatrapdf' then
        vim.g.vimtex_view_general_viewer = 'SumatraPDF'
        vim.g.vimtex_view_general_options = '-reuse-instance -forward-search @tex @line @pdf'
        vim.g.vimtex_view_general_options_latexmk = '-reuse-instance'
    elseif executable 'okular' then
        vim.g.vimtex_view_general_viewer = 'okular'
        vim.g.vimtex_view_general_options = [[--unique file:@pdf\#src:@line@tex]]
        vim.g.vimtex_view_general_options_latexmk = '--unique'
    end
end

return true

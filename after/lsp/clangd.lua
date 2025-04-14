---@brief
---
-- https://clangd.llvm.org/installation.html
--
-- - **NOTE:** Clang >= 11 is recommended! See [#23](https://github.com/neovim/nvim-lspconfig/issues/23).
-- - If `compile_commands.json` lives in a build directory, you should
--   symlink it to the root of your source tree.
--   ```
--   ln -s /path/to/myproject/build/compile_commands.json /path/to/myproject/
--   ```
-- - clangd relies on a [JSON compilation database](https://clang.llvm.org/docs/JSONCompilationDatabase.html)
--   specified as compile_commands.json, see https://clangd.llvm.org/installation#compile_commandsjson
local pch_dirs = './.cache/clangd/pchs/'
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
        'proto',
    },
    root_markers = {
        '.clangd',
        '.clang-tidy',
        '.clang-format',
        'compile_commands.json',
        'compile_flags.txt',
        'configure.ac', -- AutoTools
        'Makefile',
        'CMakeLists.txt',
        '.git',
    },
    cmd_env = {
        TMPDIR = pch_dirs,
    },
    capabilities = {
        textDocument = {
            completion = {
                editsNearCursor = true,
            },
        },
        offsetEncoding = { 'utf-8', 'utf-16' },
    },
    -- init_options = {
    --     usePlaceholders = true,
    --     completeUnimported = true,
    --     clangdFileStatus = true,
    -- },
    on_attach = function()
        if vim.fn.isdirectory(pch_dirs) == 0 then
            vim.fn.mkdir(pch_dirs, 'p')
        end

        vim.api.nvim_buf_create_user_command(0, 'ClangdSwitch', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'edit')
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'ClangdSwitchVSplit', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'vsplit')
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'ClangdSwitchSplit', function()
            require('configs.lsp.utils').switch_source_header_splitcmd(0, 'split')
        end, { desc = 'Switch between source/header' })

        vim.api.nvim_buf_create_user_command(0, 'ClangdShowSymbolInfo', function()
            require('configs.lsp.utils').symbol_info()
        end, { desc = 'Show symbol info' })
    end,
}

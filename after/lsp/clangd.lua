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
local root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    'compile_commands.json',
    'compile_flags.txt',
    'configure.ac', -- AutoTools
    'Makefile',
    'CMakeLists.txt',
    '.git',
}

local default_cmd = {
    'clangd',
    '--fallback-style=Google',
    '--clang-tidy',
    '--header-insertion=iwyu',
    '--function-arg-placeholders',
    '--completion-style=bundled',
    -- '--pch-storage=memory',
    '--background-index',
    -- '--malloc-trim',
    '--log=error',
}

return {
    cmd = default_cmd,
    filetypes = {
        'c',
        'cpp',
        'objc',
        'objcpp',
        'cuda',
        'proto',
    },
    -- init_options = {
    --     usePlaceholders = true,
    --     completeUnimported = true,
    --     clangdFileStatus = true,
    -- },
    root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        local root = vim.fs.root(fname, root_markers)
        if root then
            if vim.fn.isdirectory(pch_dirs) == 0 then
                vim.fn.mkdir(pch_dirs, 'p')
            end

            -- -- TODO: this is not reflected for the current LSP, just the next
            -- local local_config = vim.fs.find('clangd.json', { path = root, upward = true, type = 'file' })[1]
            -- if local_config then
            --     local utils_io = require 'utils.files'
            --     local ok, configs = pcall(utils_io.read_json, local_config)
            --     if ok and configs.cmd then
            --         vim.lsp.config.clangd = { cmd = configs.cmd }
            --     end
            -- else
            --     vim.lsp.config.clangd = { cmd = default_cmd }
            -- end

            on_dir(root)
        end
    end,
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
    on_attach = function()
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

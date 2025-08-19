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

local pch_dir = './.cache/clangd/pchs/'
local compile_db = 'compile_commands.json'

local root_markers = {
    '.clangd',
    '.clang-tidy',
    '.clang-format',
    compile_db,
    'compile_flags.txt',
    'configure.ac', -- AutoTools
    -- 'Makefile',
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
    '--background-index',
    '--pch-storage=disk',
}

return {
    -- cmd = default_cmd,
    cmd = function(dispatchers, config, dummy)
        if require('utils.files').is_dir(pch_dir) then
            require('utils.files').mkdir(pch_dir, true)
        end

        local cmd = vim.deepcopy(default_cmd)
        local root_dir = vim.fs.root(0, root_markers) or vim.uv.cwd()
        root_dir = vim.fs.normalize(vim.uv.fs_realpath(root_dir))

        if vim.lsp.log.get_level() <= vim.log.levels.DEBUG then
            table.insert(cmd, '--log=verbose')
        elseif vim.lsp.log.get_level() < vim.log.levels.ERROR then
            table.insert(cmd, '--log=info')
        else
            table.insert(cmd, '--log=error')
        end

        local home = vim.uv.os_homedir()
        local xdg_config_home = vim.env.XDG_CONFIG_HOME or vim.fs.joinpath(home, '.config')
        local clangd_config = vim.fs.joinpath('clangd', 'clangd_config.yaml')

        local sysname = vim.uv.os_uname().sysname:lower()
        local global_config
        if sysname:match '^windows' then
            global_config = vim.fs.joinpath(vim.env.USERPROFILE, 'AppData', 'Local', clangd_config)
        elseif sysname == 'linux' then
            global_config = vim.fs.joinpath(xdg_config_home, clangd_config)
        else
            global_config = vim.fs.joinpath(home, 'Library', 'Preferences', clangd_config)
        end

        global_config = vim.fs.normalize(global_config)

        if vim.uv.fs_stat(global_config) or vim.fs.root(0, { '.clangd' }) then
            table.insert(cmd, '--enable-config')
        else
            -- https://clangd.llvm.org/config.html
            if not vim.uv.fs_stat(global_config) and not vim.fs.root(0, { '.clangd' }) then
                local db_path = '--compile-commands-dir=%s'
                if vim.env.CLEARCASE_ROOT and not vim.fs.root(0, { '.git' }) then
                    root_dir = '/vobs/litho'
                    table.insert(cmd, db_path:format(root_dir))
                else
                    -- NOTE: is this needed ?
                    local db_loc = root_dir
                    if vim.uv.fs_stat(vim.fs.joinpath(root_dir, 'build', compile_db)) then
                        db_loc = vim.fs.joinpath(root_dir, 'build', compile_db)
                    end
                    table.insert(cmd, db_path:format(db_loc))
                end
            end

            if vim.t.clangd_indexer or vim.g.clangd_indexer or vim.env.CLANGD_INDEXER then
                if vim.t.clangd_indexer then
                    table.insert(cmd, '--remote-index-address=' .. vim.t.clangd_indexer)
                elseif vim.g.clangd_indexer then
                    table.insert(cmd, '--remote-index-address=' .. vim.g.clangd_indexer)
                elseif vim.env.CLANGD_INDEXER then
                    table.insert(cmd, '--remote-index-address=' .. vim.env.CLANGD_INDEXER)
                end

                if require('utils.files').is_dir(vim.fs.joinpath(root_dir, '.vscode_clangd_setup')) then
                    table.insert(cmd, '--project-root=' .. vim.fs.joinpath(root_dir, '.vscode_clangd_setup'))
                elseif vim.env.CLEARCASE_ROOT then
                    table.insert(cmd, '--project-root=/vobs')
                else
                    table.insert(cmd, '--project-root=' .. root_dir)
                end
            end
        end

        if sysname == 'linux' then
            table.insert(cmd, '--malloc-trim')
        end

        return dummy and cmd or vim.lsp.rpc.start(cmd, dispatchers, config or { cwd = root_dir })
    end,
    filetypes = {
        'c',
        'cpp',
        'objc',
        'objcpp',
        'cuda',
        'proto',
    },
    -- fix: add measured_position to KHWTUM::DataCache
    -- init_options = {
    --     usePlaceholders = true,
    --     completeUnimported = true,
    --     clangdFileStatus = true,
    -- },
    root_markers = root_markers,
    cmd_env = {
        TMPDIR = pch_dir,
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

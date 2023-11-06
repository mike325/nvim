local nvim = require 'nvim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir
local completions = RELOAD 'completions'
local noremap = { noremap = true, silent = true }

if vim.F.npcall(require, 'mini.doc') then
    require('mini.doc').setup {}
end

local MiniSessions = vim.F.npcall(require, 'mini.sessions')
if MiniSessions then
    local sessions_dir = sys.session
    if not is_dir(sessions_dir) then
        mkdir(sessions_dir)
    end
    MiniSessions.setup {}
    nvim.command.set('SessionSave', function(opts)
        local session = opts.args
        if session == '' then
            local getcwd = require('utils.files').getcwd
            session = vim.v.this_session ~= '' and vim.v.this_session or vim.fs.basename(getcwd())
            if session:match '^%.' then
                session = session:gsub('^%.+', '')
            end
        end
        MiniSessions.write(session:gsub('%s+', '_'), { force = true })
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionLoad', function(opts)
        local session = opts.args
        if session ~= '' then
            MiniSessions.read(session, { force = false })
        else
            MiniSessions.get_latest()
        end
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionDelete', function(opts)
        local bang = opts.bang
        local session = opts.args
        local is_file = require('utils.files').is_file
        local path = sessions_dir .. '/' .. session
        if not is_file(path) then
            vim.notify('Invalid Session: ' .. session, 'ERROR', { title = 'MiniSession' })
            return
        end
        MiniSessions.delete(session, { force = bang })
    end, {
        bang = true,
        nargs = 1,
        complete = completions.session_files,
    })
end

if vim.F.npcall(require, 'mini.move') then
    require('mini.move').setup {
        mappings = {
            left = '',
            right = '',
            down = ']e',
            up = '[e',

            line_left = '',
            line_right = '',
            line_down = ']e',
            line_up = '[e',
        },
    }
end

local mini_splitjoin = vim.F.npcall(require, 'mini.splitjoin')
if mini_splitjoin then
    local gen_hook = mini_splitjoin.gen_hook
    local curly = { brackets = { '%b{}' } }

    -- Add trailing comma when splitting inside curly brackets
    local add_comma_curly = gen_hook.add_trailing_separator(curly)

    -- Delete trailing comma when joining inside curly brackets
    local del_comma_curly = gen_hook.del_trailing_separator(curly)

    -- Pad curly brackets with single space after join
    local pad_curly = gen_hook.pad_brackets(curly)

    mini_splitjoin.setup {
        mappings = {
            toggle = 'gj',
            split = '',
            join = '',
        },

        -- Split options
        split = {
            hooks_pre = {},
            hooks_post = { add_comma_curly },
        },

        -- Join options
        join = {
            hooks_pre = {},
            hooks_post = { del_comma_curly, pad_curly },
        },
    }
end

local MiniFiles = vim.F.npcall(require, 'mini.files')
if MiniFiles then
    MiniFiles.setup {
        mappings = {
            close = 'q',
            go_in = '<TAB>',
            go_in_plus = '<CR>',
            go_out = '<BS>',
            go_out_plus = 'H',
            reset = '<F5>',
            reveal_cwd = '@',
            show_help = 'g?',
            synchronize = '=',
            trim_left = '<',
            trim_right = '>',
        },
    }
    nvim.command.set('Files', function(opts)
        local path = opts.bang and vim.api.nvim_buf_get_name(0) or vim.loop.cwd()
        MiniFiles.open(path)
    end, { bang = true, desc = 'Open mini.files' })

    vim.keymap.set('n', '-', function()
        MiniFiles.open()
    end, { noremap = true, silent = true, desc = 'Open mini.files' })

    vim.keymap.set('n', 'g-', function()
        MiniFiles.open(vim.api.nvim_buf_get_name(0))
    end, { noremap = true, silent = true, desc = 'Open mini.files' })

    local show_dotfiles = true

    local filter_show = function(fs_entry)
        return true
    end

    local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
    end

    if vim.g.mini_files_autocmd then
        vim.api.nvim_del_autocmd(vim.g.mini_files_autocmd)
        vim.g.mini_files_autocmd = nil
    end

    vim.g.mini_files_autocmd = vim.api.nvim_create_autocmd('User', {
        pattern = 'MiniFilesBufferCreate',
        callback = function(args)
            local buf_id = args.data.buf_id
            -- Tweak left-hand side of mapping to your liking
            vim.keymap.set('n', 'g.', function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                MiniFiles.refresh { content = { filter = new_filter } }
            end, { buffer = buf_id, nowait = true })

            local mapping = vim.tbl_filter(function(keymap)
                return keymap.callback and keymap.lhs == '<CR>'
            end, vim.api.nvim_buf_get_keymap(buf_id, 'n'))

            if #mapping > 0 then
                vim.keymap.set('n', '<C-LeftMouse>', mapping[1].callback, { buffer = true, nowait = true })
            end
        end,
    })
end

local MiniMap = vim.F.npcall(require, 'mini.map')
if MiniMap then
    MiniMap.setup {}
    nvim.command.set('MiniMap', function(opts)
        if opts.args == 'enable' then
            MiniMap.open()
        elseif opts.args == 'disable' then
            MiniMap.close()
        else
            MiniMap.toggle()
        end
    end, { nargs = '?', complete = completions.toggle, desc = 'Open/Close mini.map' })
end

if vim.F.npcall(require, 'mini.comment') then
    require('mini.comment').setup {}
end

local MiniPick = vim.F.npcall(require, 'mini.pick')
if MiniPick then
    MiniPick.setup {
        mappings = {
            move_up = '<C-k>',
            move_down = '<C-j>',
        },
    }
    vim.ui.select = MiniPick.ui_select

    if vim.g.minimal then
        vim.keymap.set('n', '<leader><C-r>', function()
            MiniPick.builtin.resume()
        end, noremap)

        vim.keymap.set('n', '<leader>g', function()
            MiniPick.builtin.grep()
        end, noremap)

        vim.keymap.set('n', '<C-p>', function()
            local is_git = vim.b.project_root and vim.b.project_root.is_git or false
            local fast_pickers = {
                fd = true,
                fdfind = true,
                rg = true,
                git = true,
            }
            local finder = RELOAD('utils.functions').select_filelist(is_git, true)
            if fast_pickers[finder[1]] then
                MiniPick.builtin.cli { command = finder }
            else
                -- TODO: add support for threads to have async functionality?
                MiniPick.builtin.files()
            end
        end, noremap)

        vim.keymap.set('n', '<leader><C-p>', function()
            local finder = RELOAD('utils.functions').select_filelist(false, true)
            local fast_pickers = {
                fd = true,
                fdfind = true,
                rg = true,
            }
            if fast_pickers[finder[1]] then
                table.insert(finder, '-uuu')
                MiniPick.builtin.cli { command = finder }
            else
                -- TODO: add support for threads to have async functionality?
                MiniPick.builtin.files()
            end
        end, noremap)

        vim.keymap.set('n', '<C-b>', function()
            MiniPick.builtin.buffers {}
        end, noremap)
    end
end

local MiniExtras = vim.F.npcall(require, 'mini.extra')
if MiniExtras then
    MiniExtras.setup {}
end

local MiniPairs = vim.F.npcall(require, 'mini.pairs')
if MiniPairs then
    MiniPairs.setup()
end

if vim.F.npcall(require, 'mini.surround') then
    require('mini.surround').setup {
        mappings = {
            add = 'ys',
            delete = 'ds',
            replace = 'cs',
            find = '',
            find_left = '',
            highlight = '',
            update_n_lines = '',
        },
    }
    -- Remap adding surrounding to Visual mode selection
    vim.keymap.del('x', 'ys')
    vim.keymap.set('x', 'S', [[:<C-u>lua MiniSurround.add('visual')<CR>]], { silent = true })
    -- Make special mapping for "add surrounding for line"
    -- vim.keymap.set('n', 'yss', 'ys_', { remap = true })
end

if vim.F.npcall(require, 'mini.ai') then
    local gen_ai_spec = MiniExtras.gen_ai_spec
    require('mini.ai').setup {
        custom_textobjects = {
            e = gen_ai_spec.buffer(),
            D = gen_ai_spec.diagnostic(),
            L = gen_ai_spec.line(),
            N = gen_ai_spec.number(),
            i = gen_ai_spec.indent(),
        },
    }
end

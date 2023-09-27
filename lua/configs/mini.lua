local nvim = require 'nvim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir
local completions = RELOAD 'completions'

local mini_doc = vim.F.npcall(require, 'mini.doc')
if mini_doc then
    mini_doc.setup {}
end

local mini_sessions = vim.F.npcall(require, 'mini.sessions')
if mini_sessions then
    local sessions_dir = sys.session
    if not is_dir(sessions_dir) then
        mkdir(sessions_dir)
    end
    mini_sessions.setup {}
    nvim.command.set('SessionSave', function(opts)
        local session = opts.args
        if session == '' then
            local getcwd = require('utils.files').getcwd
            session = vim.v.this_session ~= '' and vim.v.this_session or vim.fs.basename(getcwd())
            if session:match '^%.' then
                session = session:gsub('^%.+', '')
            end
        end
        mini_sessions.write(session:gsub('%s+', '_'), { force = true })
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionLoad', function(opts)
        local session = opts.args
        if session ~= '' then
            mini_sessions.read(session, { force = false })
        else
            mini_sessions.get_latest()
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
        mini_sessions.delete(session, { force = bang })
    end, {
        bang = true,
        nargs = 1,
        complete = completions.session_files,
    })
end

local mini_move = vim.F.npcall(require, 'mini.move')
if mini_move then
    mini_move.setup {
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

local mini_files = vim.F.npcall(require, 'mini.files')
if mini_files then
    mini_files.setup {
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
        mini_files.open(path)
    end, { bang = true, desc = 'Open mini.files' })

    vim.keymap.set('n', '-', function()
        mini_files.open()
    end, { noremap = true, silent = true, desc = 'Open mini.files' })

    vim.keymap.set('n', 'g-', function()
        mini_files.open(vim.api.nvim_buf_get_name(0))
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
                mini_files.refresh { content = { filter = new_filter } }
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

local mini_map = vim.F.npcall(require, 'mini.map')
if mini_map then
    mini_map.setup {}
    nvim.command.set('MiniMap', function(opts)
        if opts.args == 'enable' then
            mini_map.open()
        elseif opts.args == 'disable' then
            mini_map.close()
        else
            mini_map.toggle()
        end
    end, { nargs = '?', complete = completions.toggle, desc = 'Open/Close mini.map' })
end

local mini_comment = vim.F.npcall(require, 'mini.comment')
if mini_comment then
    mini_comment.setup {}
end

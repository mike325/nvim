local nvim = require 'nvim'
local sys = require 'sys'

local is_dir = require('utils.files').is_dir
local mkdir = require('utils.files').mkdir
local completions = RELOAD 'completions'
local noremap = { noremap = true, silent = true }

local me = debug.getinfo(1, 'S')
if me and me.source then
    require('utils.functions').watch_config_file((me.source:sub(2)))
end

local mini = {}
local function load_simple_module(plugin, config)
    local mini_plugin = 'mini.' .. plugin
    local module = vim.F.npcall(require, mini_plugin)
    if module then
        mini[plugin] = module
        require(mini_plugin).setup(config or {})
    end
end

local diffopts = {}
vim.tbl_map(function(opt)
    local k, v = unpack(vim.split(opt, ':'))
    diffopts[k] = v or true
end, vim.split(vim.o.diffopt, ','))

local censor_extmark_opts = function(_, match, _)
    local mask = string.rep('*', vim.fn.strchars(match))
    return {
        virt_text = { { mask, 'Comment' } },
        virt_text_pos = 'overlay',
        priority = 200,
        right_gravity = false,
    }
end

local password_table = {
    pattern = {
        'password:? ()%S+()',
        'password_usr:? ()%S+()',
    },
    group = '',
    extmark_opts = censor_extmark_opts,
}

local simple_mini = {
    align = {
        mappings = {
            start = 'gl',
            start_with_preview = 'gL',
        },
    },
    doc = {},
    fuzzy = {},
    extra = {},
    pairs = {},
    sessions = {},
    map = {},
    surround = {
        mappings = {
            add = 'ys',
            delete = 'ds',
            replace = 'cs',
            find = '',
            find_left = '',
            highlight = '',
            update_n_lines = '',
        },
    },
    files = {
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
    },
    move = {
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
    },
    diff = {
        view = {
            style = vim.go.number and 'number' or 'sign',
            -- style = 'sign',
            signs = { add = '+', change = '~', delete = '-' },
        },
        mappings = {
            apply = 'gh',
            reset = 'gH',
            textobject = '',
            -- TODO: Add support to jump to TS context
            goto_first = '[C',
            goto_last = ']C',
            goto_prev = '[c',
            goto_next = ']c',
        },
        options = {
            algorithm = diffopts.algorithm or 'histogram',
            indent_heuristic = diffopts['indent-heuristic'],
            linematch = tonumber(diffopts.linematch) or 60,
        },
    },
    hipatterns = {
        highlighters = {
            pw = password_table, -- Cloaking Passwords
        },
    },
}

if not nvim.has { 0, 10 } then
    simple_mini.comment = {}
end

for plugin, config in pairs(simple_mini) do
    load_simple_module(plugin, config)
end

if mini.sessions then
    local sessions_dir = sys.session
    if not is_dir(sessions_dir) then
        mkdir(sessions_dir)
    end
    nvim.command.set('SessionSave', function(opts)
        local session = opts.args
        if session == '' then
            local getcwd = require('utils.files').getcwd
            session = vim.v.this_session ~= '' and vim.v.this_session or vim.fs.basename(getcwd())
            if session:match '^%.' then
                session = session:gsub('^%.+', '')
            end
        end
        mini.sessions.write(session:gsub('%s+', '_'), { force = true })
    end, { nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionLoad', function(opts)
        local session = opts.args
        if session ~= '' then
            mini.sessions.read(session, { force = false })
        elseif opts.bang then
            mini.sessions.read(mini.sessions.get_latest(), { force = false })
        else
            local sessions = require('utils.files').get_files(sessions_dir)
            vim.ui.select(
                vim.tbl_map(vim.fs.basename, sessions),
                { prompt = 'Select session file: ' },
                vim.schedule_wrap(function(choice)
                    if choice then
                        mini.sessions.read(choice, { force = false })
                    end
                end)
            )
        end
    end, { bang = true, nargs = '?', complete = completions.session_files })

    nvim.command.set('SessionDelete', function(opts)
        local bang = opts.bang
        local session = opts.args

        local function delete_session(session_file)
            local path = sessions_dir .. '/' .. session_file
            if not require('utils.files').is_file(path) then
                vim.notify('Invalid Session: ' .. session_file, vim.log.levels.ERROR, { title = 'mini.session' })
                return
            end
            mini.sessions.delete(session_file, { force = bang })
        end

        if session == '' then
            local sessions = require('utils.files').get_files(sessions_dir)
            vim.ui.select(
                vim.tbl_map(vim.fs.basename, sessions),
                { prompt = 'Select session file: ' },
                vim.schedule_wrap(function(choice)
                    if choice then
                        delete_session(choice)
                    end
                end)
            )
        else
            delete_session(session)
        end
    end, {
        bang = true,
        nargs = '?',
        complete = completions.session_files,
    })
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

mini.files = vim.F.npcall(require, 'mini.files')
if mini.files then
    nvim.command.set('Files', function(opts)
        local path = opts.bang and vim.api.nvim_buf_get_name(0) or vim.loop.cwd()
        mini.files.open(path)
    end, { bang = true, desc = 'Open mini.files' })

    vim.keymap.set('n', '-', function()
        mini.files.open()
    end, { noremap = true, silent = true, desc = 'Open mini.files' })

    vim.keymap.set('n', 'g-', function()
        mini.files.open(vim.api.nvim_buf_get_name(0))
    end, { noremap = true, silent = true, desc = 'Open mini.files' })

    local show_dotfiles = true

    local filter_show = function(_)
        return true
    end

    local filter_hide = function(fs_entry)
        return not vim.startswith(fs_entry.name, '.')
    end

    vim.api.nvim_create_autocmd('User', {
        desc = 'Re-map mouse click and g. in MiniFiles buffer to open and show hidden files',
        group = vim.api.nvim_create_augroup('MiniFilesCreate', { clear = true }),
        pattern = 'mini.filesBufferCreate',
        callback = function(args)
            local buf_id = args.data.buf_id
            -- Tweak left-hand side of mapping to your liking
            vim.keymap.set('n', 'g.', function()
                show_dotfiles = not show_dotfiles
                local new_filter = show_dotfiles and filter_show or filter_hide
                mini.files.refresh { content = { filter = new_filter } }
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

if mini.map then
    nvim.command.set('MiniMap', function(opts)
        if opts.args == 'enable' then
            mini.map.open()
        elseif opts.args == 'disable' then
            mini.map.close()
        else
            mini.map.toggle()
        end
    end, { nargs = '?', complete = completions.toggle, desc = 'Open/Close mini.map' })
end

mini.pick = vim.F.npcall(require, 'mini.pick')
if mini.pick then
    local win_config = function()
        local height = math.floor(0.618 * vim.o.lines)
        local width = math.floor(0.618 * vim.o.columns)
        return {
            anchor = 'NW',
            border = 'double',
            col = math.floor(0.5 * (vim.o.columns - width)),
            height = height,
            row = math.floor(0.5 * (vim.o.lines - height)),
            width = width,
        }
    end

    mini.pick.setup {
        window = {
            config = win_config,
        },
        mappings = {
            move_up = '<C-k>',
            move_down = '<C-j>',
        },
    }
    vim.ui.select = mini.pick.ui_select

    if vim.g.minimal then
        vim.keymap.set('n', '<leader><C-r>', function()
            mini.pick.builtin.resume()
        end, noremap)

        vim.keymap.set('n', '<leader>g', function()
            mini.pick.builtin.grep()
        end, noremap)

        vim.keymap.set('n', '<C-p>', function()
            local is_git = vim.t.is_in_git
            local fast_pickers = {
                fd = true,
                fdfind = true,
                rg = true,
                git = true,
            }
            local finder = RELOAD('utils.functions').select_filelist(is_git, true)
            if fast_pickers[finder[1]] then
                mini.pick.builtin.cli { command = finder }
            else
                -- TODO: add support for threads to have async functionality?
                mini.pick.builtin.files()
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
                mini.pick.builtin.cli { command = finder }
            else
                -- TODO: add support for threads to have async functionality?
                mini.pick.builtin.files()
            end
        end, noremap)

        vim.keymap.set('n', '<C-b>', function()
            mini.pick.builtin.buffers {}
        end, noremap)
    end
end

if mini.surround then
    -- Remap adding surrounding to Visual mode selection
    vim.keymap.del('x', 'ys')
    vim.keymap.set(
        'x',
        'S',
        [[:<C-u>lua MiniSurround.add('visual')<CR>]],
        { silent = true, desc = 'Visual mini surround mapping' }
    )
    -- Make special mapping for "add surrounding for line"
    -- vim.keymap.set('n', 'yss', 'ys_', { remap = true })
end

if mini.diff then
    vim.keymap.set('n', '=f', function()
        mini.diff.toggle_overlay(0)
    end, { desc = 'Toggle mini diff overlay' })
end

if vim.F.npcall(require, 'mini.ai') and mini.extra then
    local gen_ai_spec = mini.extra.gen_ai_spec
    require('mini.ai').setup {
        mappings = {
            -- -- Main textobject prefixes
            -- around = 'a',
            -- inside = 'i',
            --
            -- -- Next/last textobjects
            -- around_next = 'an',
            -- inside_next = 'in',
            -- around_last = 'al',
            -- inside_last = 'il',

            -- Move cursor to corresponding edge of `a` textobject
            goto_left = '',
            goto_right = '',
        },
        custom_textobjects = {
            e = gen_ai_spec.buffer(),
            D = gen_ai_spec.diagnostic(),
            L = gen_ai_spec.line(),
            N = gen_ai_spec.number(),
            i = gen_ai_spec.indent(),
        },
    }
end

mini.test = vim.F.npcall(require, 'mini.test')
if mini.test then
    mini.test.setup {
        collect = {
            find_files = function()
                return vim.fn.globpath('lua/tests', '**/*_spec.lua', true, true)
            end,
        },
    }

    local neovim_test = vim.api.nvim_create_augroup('NeovimTest', { clear = true })

    vim.api.nvim_create_autocmd({ 'Filetype' }, {
        desc = 'Create Mini test commands to execute and manage tests',
        group = neovim_test,
        pattern = 'lua',
        callback = function(event)
            nvim.command.set('RunLuaTests', function(opts)
                local test = opts.args
                if test == '*' then
                    mini.test.execute(mini.test.collect())
                elseif test == '' then
                    test = vim.api.nvim_buf_get_name(0)
                    if not test:match '.+_spec%.lua$' then
                        mini.test.execute(mini.test.collect())
                    else
                        mini.test.run_file(test)
                    end
                else
                    mini.test.run_file(vim.fn.expand(test))
                end
            end, {
                buffer = event.buf,
                nargs = '?',
                complete = completions.lua_tests,
                desc = 'Execute a lua test or a collection of tests',
            })
        end,
    })

    vim.api.nvim_create_autocmd({ 'BufReadPost' }, {
        desc = 'Create command to execute lua test at location',
        group = neovim_test,
        pattern = '*_spec.lua',
        callback = function(event)
            nvim.command.set('ExecuteLuaTest', function(opts)
                if opts.bang then
                    mini.test.run_file(nvim.buf.get_name(0))
                else
                    mini.test.run_at_location()
                end
            end, {
                buffer = event.buf,
                bang = true,
                -- complete = completions.lua_tests,
                desc = 'Execute a lua especific test in the cursor location',
            })
        end,
    })
end

if mini.hipatterns then
    vim.keymap.set('n', '<leader>P', function()
        if next(mini.hipatterns.config.highlighters.pw) == nil then
            mini.hipatterns.config.highlighters.pw = password_table
        else
            mini.hipatterns.config.highlighters.pw = {}
        end
        vim.cmd 'edit'
    end, { desc = 'Toggle Password Cloaking' })
end

if vim.g.minimal then
    local simple_minimal = {
        'cursorword',
        'notify',
        'indentscope',
    }

    for _, plugin in ipairs(simple_minimal) do
        load_simple_module(plugin)
    end

    if vim.F.npcall(require, 'mini.completion') then
        -- TODO: Write custom completion func to collect and combine results
        require('mini.completion').setup {
            lsp_completion = {
                source_func = 'omnifunc',
                auto_setup = false,
            },
        }
        vim.keymap.set('i', '<Tab>', [[pumvisible() ? "\<C-n>" : "\<Tab>"]], { expr = true })
        vim.keymap.set('i', '<S-Tab>', [[pumvisible() ? "\<C-p>" : "\<S-Tab>"]], { expr = true })

        local keys = {
            ['cr'] = vim.keycode '<CR>',
            ['ctrl-y'] = vim.keycode '<C-y>',
            ['ctrl-e'] = vim.keycode '<C-e>',
        }

        vim.keymap.set('i', '<CR>', function()
            if vim.fn.pumvisible() ~= 0 then
                -- If popup is visible, confirm selected item or add new line otherwise
                local item_selected = vim.fn.complete_info()['selected'] ~= -1
                return item_selected and keys['ctrl-y'] or keys['ctrl-e']
            else
                -- TODO: Add support for native snippet expansion
                -- return keys['cr']
                return mini.pairs.cr()
            end
        end, { expr = true })
    end

    if mini.hipatterns then
        local notes = {
            hack = false,
            todo = false,
            note = false,
            fixme = false,
            fix = false,
            warn = 'DiagnosticWarn',
            bug = 'DiagnosticError',
            error = 'DiagnosticError',
        }

        local highlighters = {
            emmylua = {
                pattern = function(buf_id)
                    if vim.bo[buf_id].filetype ~= 'lua' then
                        return nil
                    end
                    return '^%s*%-%-%-()@%w+()'
                end,
                group = 'Special',
            },
            trailing_space = {
                pattern = '%f[%s]%s*$',
                group = 'DiagnosticError',
            },
            hex_color = mini.hipatterns.gen_highlighter.hex_color(),
            pw = password_table, -- Cloaking Passwords
        }

        for pattern, group in pairs(notes) do
            group = group or ('MiniHipatterns%s'):format(require('utils.strings').capitalize(pattern))
            highlighters['comment_' .. pattern] = {
                pattern = {
                    function(buf_id)
                        local get_comment = RELOAD('utils.buffers').get_comment
                        return get_comment(('()%s%%%%(%%%%w+%%%%)():?'):format(pattern:upper()), buf_id)
                            :gsub('%s', '%%s*')
                            :gsub('%-', '%%-')
                    end,
                    function(buf_id)
                        local get_comment = RELOAD('utils.buffers').get_comment
                        return get_comment(('()%s():?'):format(pattern:upper()), buf_id)
                            :gsub('%s', '%%s*')
                            :gsub('%-', '%%-')
                    end,
                },
                group = group,
            }
        end

        mini.hipatterns.config.highlighters = highlighters
        pcall(mini.hipatterns.update)
    end

    local MiniStatusline = vim.F.npcall(require, 'mini.statusline')
    if MiniStatusline then
        MiniStatusline.setup {
            set_vim_settings = false,
            content = {
                active = function()
                    local statusline = require 'statusline'
                    local _, mode_hl = MiniStatusline.section_mode { trunc_width = 120 }
                    local diagnostics = MiniStatusline.section_diagnostics { trunc_width = 75 }
                    local filename = MiniStatusline.section_filename { trunc_width = 140 }
                    local fileinfo = MiniStatusline.section_fileinfo { trunc_width = 120 }
                    local location = MiniStatusline.section_location { trunc_width = 75 }
                    local search = MiniStatusline.section_searchcount { trunc_width = 75 }

                    return MiniStatusline.combine_groups {
                        { hl = mode_hl, strings = { statusline.mode.component(), statusline.spell.component() } },
                        {
                            hl = 'MiniStatuslineDevinfo',
                            strings = {
                                statusline.clearcase.component(),
                                statusline.git_branch.component(),
                                diagnostics,
                                statusline.session.component(),
                                statusline.dap.component(),
                                statusline.qf_counter.component(),
                                statusline.loc_counter.component(),
                                statusline.arglist.component(),
                                statusline.jobs.component(),
                            },
                        },
                        '%<', -- Mark general truncate point
                        { hl = 'MiniStatuslineFilename', strings = { filename } },
                        '%=', -- End left alignment
                        { hl = 'MiniStatuslineFileinfo', strings = { fileinfo } },
                        { hl = mode_hl, strings = { search, location } },
                    }
                end,
            },
        }
    end
end

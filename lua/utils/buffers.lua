local nvim = require 'nvim'

local M = {}

function M.last_position()
    local sc_mark = nvim.buf.get_mark(0, "'")
    local dc_mark = nvim.buf.get_mark(0, '"')
    local last_line = nvim.fn.line '$'
    local filetype = nvim.bo.filetype

    local black_list = {
        git = 1,
        gitcommit = 1,
        fugitive = 1,
        qf = 1,
    }

    if sc_mark[1] >= 1 and dc_mark[1] <= last_line and not black_list[filetype] then
        nvim.win.set_cursor(0, dc_mark)
    end
end

function M.bufloaded(buffer)
    vim.validate {
        buffer = {
            buffer,
            function(b)
                return type(b) == type '' or type(b) == type(1)
            end,
            'filepath string or a buffer number',
        },
    }
    -- return vim.api.nvim_buf_is_loaded(bufnr)
    return vim.fn.bufloaded(buffer) == 1
end

function M.is_modified(bufnr)
    vim.validate { buffer = { bufnr, 'number', true } }

    bufnr = bufnr or nvim.get_current_buf()
    return vim.bo[bufnr].modified
end

function M.delete(bufnr, wipe)
    vim.validate { buffer = { bufnr, 'number', true }, wipe = { wipe, 'boolean', true } }
    assert(not bufnr or bufnr > 0, debug.traceback 'Buffer must be greater than 0')

    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local bufname = vim.api.nvim_buf_get_name(bufnr)
    local is_duplicated = false
    local is_wipe = vim.bo[bufnr].bufhidden == 'wipe'
    local prev_buf = vim.fn.expand '#' ~= '' and vim.fn.bufnr(vim.fn.expand '#') or -1
    prev_buf = prev_buf == bufnr and -1 or prev_buf

    if prev_buf == -1 then
        local wins = nvim.tab.list_wins(0)
        if #wins > 1 then
            local current_win = nvim.get_current_win()
            for _, win in pairs(wins) do
                local buf = nvim.win.get_buf(win)
                if win ~= current_win and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
        local bufs = nvim.list_bufs()
        if #bufs > 1 and prev_buf == -1 then
            for _, buf in pairs(bufs) do
                if nvim.buf.is_loaded(buf) and buf ~= bufnr then
                    prev_buf = buf
                    break
                end
            end
        end
    end

    -- TODO: Don't create multiple empty buffers just do nothing here if buf == [No Name]
    if nvim.get_current_buf() == bufnr then
        local new_view = nvim.buf.is_loaded(prev_buf) and prev_buf or nvim.create_buf(true, false)
        nvim.win.set_buf(0, new_view)
    end

    for _, tab in pairs(nvim.list_tabpages()) do
        for _, win in pairs(nvim.tab.list_wins(tab)) do
            if nvim.win.get_buf(win) == bufnr then
                is_duplicated = true
                break
            end
        end
    end

    if not is_duplicated and not is_wipe and nvim.buf.is_valid(bufnr) then
        local action = { unload = true }
        -- TODO: maybe should ask for confirmation in non scratch modified buffers
        if wipe or vim.bo[bufnr].modified then
            action = { force = true }
            if vim.list_contains(vim.tbl_map(require('utils.files').realpath, vim.fn.argv()), bufname) then
                vim.cmd.argdelete(bufname)
            end
        end
        nvim.buf.delete(bufnr, action)
    end
end

function M.get_option(option, default)
    local ok, opt = pcall(nvim.buf.get_option, 0, option)
    if not ok then
        ok, opt = pcall(nvim.get_option, 0, option)
        if not ok then
            opt = default
        end
    end
    return opt
end

function M.get_indent()
    local indent = vim.opt_local.softtabstop:get()
    if indent <= 0 then
        indent = vim.opt_local.shiftwidth:get()
        if indent == 0 then
            indent = vim.opt_local.tabstop:get()
        end
    end
    return indent
end

function M.get_indent_block(lines)
    vim.validate { lines = { lines, 'table' } }
    assert(vim.islist(lines), debug.traceback 'Lines must be an array')

    local indent_level
    for _, line in pairs(lines) do
        if #line > 0 then
            local level = line:match '^%s+'
            level = level and #level or nil
            if not level then
                indent_level = 0
                break
            elseif not indent_level or level < indent_level then
                indent_level = level
            end
        end
    end
    return indent_level or 0
end

function M.get_indent_block_level(lines)
    vim.validate { lines = { lines, 'table' } }
    assert(vim.islist(lines), debug.traceback 'Lines must be an array')

    local indent_level = M.get_indent_block(lines)
    return math.floor(indent_level / M.get_indent())
end

function M.get_indent_string(indent)
    vim.validate { indent = { indent, 'number', true } }

    local expand = vim.bo.expandtab
    indent = indent or M.get_indent()
    local spaces = not expand and '\t' or string.rep(' ', indent)
    return spaces
end

local function normalize_indent(lines, indent)
    local expand = vim.bo.expandtab
    local spaces = M.get_indent_string(indent)

    for i = 1, #lines do
        if #lines[i] > 0 and not lines[i]:match '^%s+$' then
            if expand then
                lines[i] = lines[i]:gsub('\t', spaces)
            else
                lines[i] = lines[i]:gsub(spaces, '\t')
            end
        end
    end

    return lines
end

function M.indent(lines, level)
    vim.validate { lines = { lines, 'table' }, level = { level, 'number' } }
    assert(vim.islist(lines), debug.traceback 'Lines must be an array')

    if level == 0 or #lines == 0 then
        return lines
    end

    local abslevel = math.abs(level)

    local indent = M.get_indent()
    local expand = vim.bo.expandtab
    local tmp_lines = vim.deepcopy(lines)

    tmp_lines = normalize_indent(tmp_lines, abslevel)

    local spaces = not expand and string.rep('\t', abslevel) or string.rep(' ', indent * abslevel)

    if level < 0 then
        local block_indent = M.get_indent_block(tmp_lines)
        if block_indent == 0 then
            return tmp_lines
        else
            if not expand then
                block_indent = block_indent * indent
            end

            if block_indent < abslevel * indent then
                return tmp_lines
            end
        end
        spaces = '^' .. spaces
    end

    for i = 1, #tmp_lines do
        if #tmp_lines[i] > 0 and not tmp_lines[i]:match '^%s+$' then
            if level < 0 then
                tmp_lines[i] = tmp_lines[i]:gsub(spaces, '')
            else
                tmp_lines[i] = spaces .. tmp_lines[i]
            end
        end
    end

    return tmp_lines
end

-- TODO: Make this function async, maybe using readfile
-- TODO: Respect indent format from editorconfig and other files
-- TODO: Cache indent settings using SQLite?
function M.detect_indent(buf)
    vim.validate { buffer = { buf, 'number', true } }

    buf = buf or vim.api.nvim_get_current_buf()

    if not vim.api.nvim_buf_is_valid(buf) then
        return
    end

    if vim.b.editorconfig and (vim.b.editorconfig.indent_size or vim.b.editorconfig.indent_style) then
        return
    end

    local ignore_fts = {
        man = true,
        help = true,
        qf = true,
        Telescope = true,
        TelescopePrompt = true,
        TelescopeResults = true,
    }

    local ft = vim.bo[buf].filetype
    local buftype = vim.bo[buf].buftype
    local ok, indent_set = pcall(vim.api.nvim_buf_get_var, buf, 'indent_set')
    indent_set = ok and indent_set or false

    if ignore_fts[ft] or indent_set or buftype ~= '' then
        return
    end

    -- -- Respect modaline
    -- if vim.bo[buf].modeline then
    --     local last_line = vim.api.nvim_buf_get_lines(buf, -2, -1, false)[1]
    --     if last_line and last_line:match '^%s*vim:' then
    --         for _, val in ipairs(vim.split(last_line, ':')) do
    --             if val:match 'ts%=%d+' or val:match 'tabstop%=%d+' then
    --                 return
    --             end
    --         end
    --     end
    -- end

    local ts_utils = RELOAD 'utils.treesitter'

    local indent = vim.bo[buf].tabstop
    local expandtab = vim.bo[buf].expandtab
    local is_in_node = ts_utils.is_in_node
    local has_ts = ts_utils.has_ts(buf)

    -- BUG: This hangs neovim's startup, seems to be a race condition, tested in windows 10
    -- local line_count = vim.api.nvim_buf_line_count(buf)

    local line_count = vim.fn.line '$'
    local lines = vim.api.nvim_buf_get_lines(buf, 0, line_count < 1024 and line_count or 1024, true)
    -- TODO: may change this to while to skip ranges of un interested blocks of code

    local blacklist = {
        'string',
        'comment',
        'paragraph',
        'document',
        'parameter_list',
        'field_initializer_list',
        'field_initializer',
        'parameters',
    }

    for idx, line in ipairs(lines) do
        if line and #line > 0 and not line:match '^%s*$' then
            local indent_str = line:match '^(%s+)[^%s]+'
            if indent_str then
                -- Use TS to avoid multiline strings and comments
                -- We may need to fallback to lua pattern matching if TS is not available
                if not has_ts or not is_in_node(blacklist, { idx - 1, #indent_str + 1 }) then
                    -- NOTE: we may need to confirm tab indent with more than 1 line and avoid mix indent
                    if indent_str:match '^\t+$' then
                        expandtab = false
                        break
                    elseif indent_str:match '^ +$' and #indent_str < 9 and #indent_str > 1 then
                        indent = #indent_str
                        expandtab = true
                        break
                    end
                end
            end
        end
    end

    vim.bo[buf].expandtab = expandtab
    vim.bo[buf].tabstop = indent
    vim.bo[buf].softtabstop = -1
    vim.bo[buf].shiftwidth = 0

    -- Cache this indent to avoid re-set it
    vim.b[buf].indent_set = true

    return indent
end

function M.replace_indent(cmd)
    vim.validate { cmd = { cmd, 'table' } }
    for idx, arg in ipairs(cmd) do
        if arg == '$WIDTH' then
            cmd[idx] = M.get_indent()
            break
        end
    end
    return cmd
end

function M.format(opts)
    opts = opts or {}

    local ft = opts.ft or vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()
    local external_formatprg = RELOAD('utils.functions').external_formatprg
    local ok, utils = pcall(RELOAD, 'filetypes.' .. ft)

    local view = vim.fn.winsaveview()

    local first = vim.v.lnum
    local last = first + vim.v.count - 1
    local whole_file = last - first == nvim.buf.line_count(bufnr) or opts.whole_file

    local clients = vim.lsp.buf_get_clients(0)
    local is_null_ls_formatting_enabled = require('configs.lsp.utils').is_null_ls_formatting_enabled

    for _, client in pairs(clients) do
        if whole_file and client.server_capabilities.documentFormattingProvider then
            if client.name ~= 'null-ls' or is_null_ls_formatting_enabled(bufnr) then
                vim.lsp.buf.format {
                    async = false,
                    id = client.id,
                }
                if vim.bo.modified then
                    vim.fn.winrestview(view)
                    return 0
                end
            end
        elseif client.server_capabilities.documentRangeFormattingProvider then
            if client.name ~= 'null-ls' or is_null_ls_formatting_enabled(bufnr) then
                vim.lsp.buf.format {
                    async = false,
                    id = client.id,
                    range = {
                        start = { first, 0 },
                        ['end'] = { last, #nvim.buf.get_lines(0, last, last + 1, false)[1] },
                    },
                }
                if vim.bo.modified then
                    vim.fn.winrestview(view)
                    return 0
                end
            end
        end
    end

    if ok and utils.get_formatter then
        local cmd = utils.get_formatter()
        if cmd then
            if opts.whole_file then
                first = 0
                last = -1
            else
                first = nil
                last = nil
            end
            external_formatprg {
                cmd = M.replace_indent(cmd),
                bufnr = bufnr,
                efm = utils.formatprg[cmd[1]].efm,
                first = first,
                last = last,
            }
            return 0
        end
    end

    return 1
end

function M.lint(opts)
    opts = opts or {}

    local ft = opts.ft or vim.bo.filetype
    local bufnr = vim.api.nvim_get_current_buf()
    local external_linterprg = RELOAD('utils.functions').external_linterprg
    local ok, utils = pcall(RELOAD, 'filetypes.' .. ft)

    -- local clients = vim.lsp.buf_get_clients(0)
    if ok and utils.get_linter then
        local cmd = utils.get_linter()
        if cmd then
            external_linterprg {
                cmd = cmd,
                bufnr = bufnr,
                efm = utils.makeprg[cmd[1]].efm,
            }
        end
    end

    return 1
end

function M.setup(ft, opts)
    vim.validate { ft = { ft, 'string', true }, opts = { opts, 'table', true } }
    ft = ft or vim.bo.filetype

    -- NOTE: C uses C++ setup
    if ft == 'c' then
        ft = 'cpp'
    end

    local utils = vim.F.npcall(RELOAD, string.format('filetypes.%s', ft))
    opts = opts or {}
    if utils then
        if utils.get_linter then
            local linter = utils.get_linter()
            if linter then
                table.insert(linter, '%')
                vim.opt_local.makeprg = table.concat(linter, ' ')
                if (utils.makeprg[linter[1]] or utils.makeprg[vim.fs.basename(linter[1])]).efm then
                    vim.opt_local.errorformat = utils.makeprg[linter[1]].efm
                end
            end
            opts.makeprg = nil
            opts.errorformat = nil
        end

        if utils.get_formatter then
            local formatter = utils.get_formatter()
            if formatter and vim.opt_local.formatexpr:get() == '' then
                vim.opt.formatexpr = "v:lua.RELOAD('utils.buffers').format( { 'ft': &l:filetype })"
            end
            opts.formatexpr = nil
        end

        if utils.setup then
            utils.setup()
        end
    end

    local ft_mappings = string.format('lua/filetypes/%s/mappings.lua', ft)
    local mappings = vim.api.nvim_get_runtime_file(ft_mappings, true)
    if #mappings > 0 then
        for _, fname in ipairs(mappings) do
            local module = fname:gsub('^.*/lua/', ''):gsub('%.lua$', ''):gsub('/', '.')
            vim.F.npcall(RELOAD, module)
            require('utils.functions').watch_config_file(fname)
        end
    end

    for option, value in pairs(opts) do
        vim.opt_local[option] = value
    end
end

function M.remove_empty(opts, buffers)
    opts = opts or {}
    buffers = buffers or vim.api.nvim_list_bufs()
    vim.validate {
        buffers = { buffers, 'table' },
        opts = { opts, 'table' },
    }

    local bufs_in_use = {}
    -- NOTE: list_wins returns all windows across tabs
    for _, win in ipairs(vim.api.nvim_list_wins()) do
        bufs_in_use[tostring(vim.api.nvim_win_get_buf(win))] = true
    end

    local function buf_is_empty(buf)
        if vim.api.nvim_buf_line_count(buf) == 1 and vim.api.nvim_buf_get_lines(buf, 0, 1, false)[1] == '' then
            return true
        end
        return false
    end

    local function buf_is_scratch(buf)
        if vim.api.nvim_buf_get_name(buf) == '' or vim.bo[buf].buftype == 'nofile' then
            return true
        end
        return false
    end

    local removed = 0
    for _, buf in ipairs(buffers) do
        if buf_is_scratch(buf) and not bufs_in_use[tostring(buf)] then
            if buf_is_empty(buf) or opts.bang then
                vim.api.nvim_buf_delete(buf, { force = true })
                removed = removed + 1
            end
        end
    end

    return removed
end

function M.open_changes(opts)
    vim.validate {
        opts = { opts, 'table' },
        action = { opts.action, 'string' },
        revision = { opts.revision, 'string', true },
        clear = { opts.clear, 'boolean' },
    }

    local action = opts.action
    local revision = opts.revision
    local clear = opts.clear == nil and true or opts.clear

    local function get_content(filename)
        local buf = vim.fn.bufnr(filename)
        if buf ~= -1 then
            return table.concat(vim.api.nvim_buf_get_lines(buf, 0, -1, false), '\n')
        end
        return require('utils.files').readfile(filename, true)
    end

    local function files_actions(files)
        if #files > 0 then
            local blacklist = {
                png = true,
                jpg = true,
                jpeg = true,
                hif = true,
                zip = true,
                ['7z'] = true,
                gif = true,
                docx = true,
                xlsm = true,
            }

            files = vim.tbl_filter(function(filename)
                local utils = require 'utils.files'
                return utils.is_file(filename) and not blacklist[utils.extension(filename)]
            end, files)
            local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
            for idx, filename in ipairs(files) do
                -- NOTE: using badd since `:edit` load every buffer and `bufadd()` set buffers as hidden
                filename = filename:gsub('^' .. cwd, '')
                vim.cmd.badd(filename)
                files[idx] = filename
            end
            local qfutils = RELOAD 'utils.qf'

            if action == 'qf' then
                local diff_opts = { result_type = 'indices', algorithm = 'minimal' }
                local items = {}
                require('utils.git').status(function(status)
                    for _, filename in ipairs(files) do
                        local item = {
                            filename = filename,
                            valid = true,
                        }
                        item.col = 1
                        if revision then
                            item.text = filename
                            item.lnum = 1
                        else
                            if status.conflict[filename] then
                                item.text = 'Conflict file'
                                local content = get_content(filename)
                                for idx, line in ipairs(vim.split(content, '\n')) do
                                    if line:match '^<<<<<<<' then
                                        item.lnum = idx + 1
                                        break
                                    end
                                end
                            else
                                if status.stage[filename] or status.workspace[filename] then
                                    local is_staged = status.stage[filename] ~= nil
                                    item.text = is_staged and 'Staged file' or 'Modified file'
                                    local content
                                    if is_staged then
                                        content = table.concat(require('utils.git').get_filecontent(filename), '\n')
                                    else
                                        content = get_content(filename)
                                    end
                                    local revision_content = require('utils.git').get_filecontent(filename, 'HEAD')
                                    local diffs = vim.diff(content, table.concat(revision_content, '\n'), diff_opts)
                                    item.lnum = diffs[1] and diffs[1][1] or 1
                                else -- untracked
                                    item.text = 'Untracked file'
                                end
                            end
                        end
                        table.insert(items, item)
                    end
                    qfutils.set_list { items = items, title = 'OpenChanges', open = not qfutils.is_open() }
                end)
            elseif action == 'hunks' then
                RELOAD('threads').queue_thread(RELOAD('threads.git').get_hunks, function(hunks)
                    if next(hunks) ~= nil then
                        qfutils.set_list { items = hunks.items, title = 'OpenChanges', open = not qfutils.is_open() }
                    end
                end, { revision = revision, files = files })
            else
                RELOAD('utils.arglist').add(files, clear)
                if action == 'open' or action == '' then
                    vim.api.nvim_win_set_buf(0, vim.fn.bufadd(files[1]))
                    -- else "background" does not :edit the first file
                end
            end
        else
            vim.notify('No modified files to open', vim.log.levels.WARN, { title = 'GitStatus' })
        end
    end

    if revision then
        RELOAD('utils.git').modified_files_from_base(revision, files_actions)
    else
        RELOAD('utils.git').modified_files(files_actions)
    end
end

function M.open_conflicts(opts)
    local action = (opts.args:gsub('^%-+', ''))
    RELOAD('utils.git').status(function(status)
        if next(status.conflict) ~= nil then
            local conflicts = vim.tbl_keys(status.conflict)
            local cwd = vim.pesc(require('utils.files').getcwd()) .. '/'
            for idx, filename in ipairs(conflicts) do
                -- NOTE: using badd since `:edit` load every buffer and `bufadd()` set buffers as hidden
                filename = filename:gsub('^' .. cwd, '')
                vim.cmd.badd(filename)
                conflicts[idx] = filename
            end
            local qfutils = RELOAD 'utils.qf'

            local items = {}
            if action == 'qf' or action == 'hunks' then
                for _, filename in ipairs(conflicts) do
                    if status.conflict[filename] then
                        local content = require('utils.files').readfile(filename)
                        for idx, line in ipairs(content) do
                            if line:match '^<<<<<<<' then
                                table.insert(items, {
                                    filename = filename,
                                    valid = true,
                                    lnum = idx + 1,
                                    text = content[idx + 1],
                                })
                            end
                        end
                    end
                end
                qfutils.set_list { items = items, title = 'OpenConflicts', open = not qfutils.is_open() }
            else
                RELOAD('utils.arglist').add(conflicts, true)
                if action == 'open' or action == '' then
                    vim.api.nvim_win_set_buf(0, vim.fn.bufadd(conflicts[1]))
                    -- else "background" does not :edit the first file
                end
            end
        end
    end)
end

function M.get_diagnostic_ns(ns, buf)
    vim.validate {
        ns = { ns, 'string' },
        buf = { buf, 'number', true },
    }
    if ns ~= '' then
        for namespace, attrs in pairs(vim.diagnostic.get_namespaces()) do
            if attrs.name == ns then
                if buf then
                    local diagnostics = vim.diagnostic.get(buf, { namespace = namespace })
                    if #diagnostics == 0 then
                        return
                    end
                end
                return namespace
            end
        end
    end
end

function M.push_tag(args)
    args = args or {}
    vim.validate {
        cmd = { args.cmd, 'string', true },
        pos = { args.pos, 'table', true },
        tagname = { args.tagname, 'string', true },
        filename = { args.filename, 'string', true },
        buf = { args.buf, 'number', true },
    }

    local buf = args.buf
    local filename = args.filename
    assert(buf or filename, debug.traceback 'Missing both, buf number and filename')
    assert(args.cmd or args.pos, debug.traceback 'Missing both, position and cmd')

    local cwd = vim.pesc(vim.loop.cwd()) .. '/'

    if not buf then
        filename = args.filename:gsub('^' .. cwd, '')
        buf = vim.fn.bufadd(filename)
    end

    local tagname = args.tagname or vim.fn.expand '<cword>'

    local win = vim.api.nvim_get_current_win()
    local cursor_pos = vim.api.nvim_win_get_cursor(win)
    local pos = { vim.api.nvim_get_current_buf(), cursor_pos[1], cursor_pos[2], 0 }
    local newtag = { { tagname = tagname, from = pos } }

    vim.api.nvim_win_set_buf(win, buf)

    if args.cmd then
        vim.api.nvim_command(args.cmd)
    else
        vim.api.nvim_win_set_cursor(win, args.pos)
    end

    vim.fn.settagstack(win, { items = newtag }, 't')
end

function M.find_config(opts)
    opts = opts or {}
    vim.validate {
        configs = { opts.configs, { 'string', 'table' } },
        dirs = { opts.dirs, { 'string', 'table' }, true },
    }

    local dirs = opts.dirs or { vim.fs.dirname(vim.api.nvim_buf_get_name(0)), require('utils.files').getcwd() }
    if type(dirs) ~= type {} then
        dirs = { dirs }
    end

    local configs = opts.configs
    if type(configs) ~= type {} then
        configs = { configs }
    end

    local config_path
    for _, cwd in ipairs(dirs) do
        config_path = vim.fs.find(configs, { upward = true, type = 'file', path = cwd })[1]
        if config_path then
            config_path = require('utils.files').realpath(config_path)
            break
        end
    end
    return config_path
end

-- TODO: Update this with TS support
function M.get_comment(text, buf)
    vim.validate {
        text = {
            text,
            function(x)
                return not x or type(x) == type '' or vim.islist(x)
            end,
            'text must be either a string or an array of lines',
        },
        buf = { buf, 'number', true },
    }
    buf = buf or vim.api.nvim_get_current_buf()
    local comment = vim.bo[buf].commentstring
    comment = comment ~= '' and comment or '// %s'
    if not comment:match '%s%%s' then
        comment = comment:gsub('%%s', ' %%s')
    end
    local comment_str
    if text then
        if vim.islist(text) then
            comment_str = {}
            for _, line in ipairs(text) do
                local commented = comment:format(line)
                if line == '' then
                    commented = vim.trim(commented)
                end
                table.insert(comment_str, commented)
            end
        else
            comment_str = comment:gsub('%%s', text)
        end
    end
    return comment_str or comment
end

return M

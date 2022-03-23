local sys = require 'sys'
local nvim = require 'neovim'

local clear_lst = require('utils.tables').clear_lst
local executable = require('utils.files').executable
local is_file = require('utils.files').is_file
local writefile = require('utils.files').writefile
local normalize_path = require('utils.files').normalize_path
local realpath = require('utils.files').realpath
local basename = require('utils.files').basename
local read_json = require('utils.files').read_json

local set_abbr = require('neovim.abbrs').set_abbr
local set_command = require('neovim.commands').set_command

local noremap = { noremap = true }
local noremap_silent = { noremap = true, silent = true }

local has_nvim_6 = nvim.has { 0, 6 }

if not vim.g.mapleader then
    vim.g.mapleader = ' '
end

set_abbr { mode = 'c', lhs = 'Gti', rhs = 'Git' }
set_abbr { mode = 'c', lhs = 'W', rhs = 'w' }
set_abbr { mode = 'c', lhs = 'Q', rhs = 'q' }
set_abbr { mode = 'c', lhs = 'q1', rhs = 'q!' }
set_abbr { mode = 'c', lhs = 'qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'w1', rhs = 'w!' }
set_abbr { mode = 'c', lhs = 'wA!', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'wa1', rhs = 'wa!' }
set_abbr { mode = 'c', lhs = 'Qa1', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'Qa!', rhs = 'qa!' }
set_abbr { mode = 'c', lhs = 'QA!', rhs = 'qa!' }

vim.keymap.set('c', '<C-n>', '<down>', noremap)
vim.keymap.set('c', '<C-p>', '<up>', noremap)
vim.keymap.set('c', '<C-r><C-w>', "<C-r>=escape(expand('<cword>'), '#')<CR>", noremap)

vim.keymap.set('n', ',', ':', noremap)
vim.keymap.set('x', ',', ':', noremap)
vim.keymap.set('n', 'Y', 'y$', noremap)
vim.keymap.set('x', '$', '$h', noremap)
vim.keymap.set('n', 'Q', 'o<ESC>', noremap)
vim.keymap.set('n', 'J', 'm`J``', noremap)
vim.keymap.set('i', 'jj', '<ESC>')
vim.keymap.set('x', '<BS>', '<ESC>', noremap)

vim.keymap.set('n', '<leader>h', '<C-w>h', noremap)
vim.keymap.set('n', '<leader>j', '<C-w>j', noremap)
vim.keymap.set('n', '<leader>k', '<C-w>k', noremap)
vim.keymap.set('n', '<leader>l', '<C-w>l', noremap)

vim.keymap.set('n', '<leader>e', '<C-w>=', noremap)
vim.keymap.set('n', '<leader>1', '1gt', noremap)
vim.keymap.set('n', '<leader>2', '2gt', noremap)
vim.keymap.set('n', '<leader>3', '3gt', noremap)
vim.keymap.set('n', '<leader>4', '4gt', noremap)
vim.keymap.set('n', '<leader>5', '5gt', noremap)
vim.keymap.set('n', '<leader>6', '6gt', noremap)
vim.keymap.set('n', '<leader>7', '7gt', noremap)
vim.keymap.set('n', '<leader>8', '8gt', noremap)
vim.keymap.set('n', '<leader>9', '9gt', noremap)
vim.keymap.set('n', '<leader>0', '<cmd>tablast<CR>', noremap)
vim.keymap.set('n', '<leader><leader>n', '<cmd>tabnew<CR>', noremap)

vim.keymap.set('n', '-', '<cmd>Explore<CR>', noremap)

vim.keymap.set('n', '&', '<cmd>&&<CR>', noremap)
vim.keymap.set('x', '&', '<cmd>&&<CR>', noremap)

vim.keymap.set('n', '/', 'ms/', noremap)
vim.keymap.set('n', 'g/', 'ms/\\v', noremap)
vim.keymap.set('n', '0', '^', noremap)
vim.keymap.set('n', '^', '0', noremap)

vim.keymap.set('n', 'gV', '`[v`]', noremap)

vim.keymap.set('t', '<ESC>', '<C-\\><C-n>', noremap)

vim.keymap.set('n', '<BS>', function()
    local ok, _ = pcall(nvim.ex.pop)
    if not ok then
        local key = nvim.replace_termcodes('<C-o>', true, false, true)
        nvim.feedkeys(key, 'n', true)
        -- local jumps
        -- ok, jumps = pcall(nvim.exec, 'jumps', true)
        -- if ok and #jumps > 0 then
        --     jumps = vim.split(jumps, '\n')
        --     table.remove(jumps, 1)
        --     table.remove(jumps, #jumps)
        --     local current_jump
        --     for i=1,#jumps do
        --         local jump = vim.trim(jumps[i]);
        --         jump = split(jump, ' ');
        --         if jump[1] == 0 then
        --             current_jump = i;
        --         end
        --         jumps[i] = jump;
        --     end
        --     if current_jump > 1 then
        --         local current_buf = nvim.win.get_buf(0)
        --         local jump_buf = jumps[current_jump - 1][4]
        --         if current_buf ~= jump_buf then
        --             if not nvim.buf.is_valid(jump_buf) or not nvim.buf.is_loaded(jump_buf) then
        --                 nvim.ex.edit(jump_buf)
        --             end
        --         end
        --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
        --     end
        -- end
    end
end, noremap_silent)

local function nicenext(dir)
    local view = vim.fn.winsaveview()
    vim.cmd('silent! normal! ' .. dir)
    if view.topline ~= vim.fn.winsaveview().topline then
        vim.cmd 'silent! normal! zz'
    end
end

vim.keymap.set('n', 'n', function()
    nicenext 'n'
end, noremap_silent)

vim.keymap.set('n', 'N', function()
    nicenext 'N'
end, noremap_silent)

vim.keymap.set('n', '<S-tab>', '<C-o>', noremap)
vim.keymap.set('x', '<', '<gv', noremap)
vim.keymap.set('x', '>', '>gv', noremap)

vim.keymap.set(
    'n',
    'j',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'j' : 'gj']],
    { noremap = true, expr = true }
)

vim.keymap.set(
    'n',
    'k',
    [[v:count ? (v:count >= 3 ? "m'" . v:count : '') . 'k' : 'gk']],
    { noremap = true, expr = true }
)

vim.keymap.set('n', '<leader><leader>e', '<cmd>echo expand("%")<CR>', noremap)

vim.keymap.set('n', 'i', function()
    local current_line = vim.fn.line '.'
    local last_line = vim.fn.line '$'
    local buftype = vim.bo.buftype
    if #vim.fn.getline '.' == 0 and last_line ~= current_line and buftype ~= 'terminal' then
        return '"_ddO'
    end
    return 'i'
end, { noremap = true, expr = true })

vim.keymap.set('n', 'c*', 'm`*``cgn', noremap)
vim.keymap.set('n', 'c#', 'm`#``cgN', noremap)
vim.keymap.set('n', 'cg*', 'm`g*``cgn', noremap)
vim.keymap.set('n', 'cg#', 'm`#``cgN', noremap)
vim.keymap.set('x', 'c', [["cy/<C-r>c<CR>Ncgn]], noremap)
vim.keymap.set('n', '¿', '`', noremap)
vim.keymap.set('x', '¿', '`', noremap)
vim.keymap.set('n', '¿¿', '``', noremap)
vim.keymap.set('x', '¿¿', '``', noremap)
vim.keymap.set('n', '¡', '^', noremap)
vim.keymap.set('x', '¡', '^', noremap)

vim.keymap.set('n', '<leader>p', '<C-^>', noremap)

vim.keymap.set('n', '<leader>q', function()
    local tabs = nvim.list_tabpages()
    local wins = nvim.tab.list_wins(0)
    if #wins > 1 and vim.fn.expand '%' ~= '[Command Line]' then
        nvim.win.hide(0)
    elseif #tabs > 1 then
        nvim.ex['tabclose!']()
    else
        nvim.exec('quit!', false)
    end
end, noremap_silent)

vim.keymap.set('i', '<C-U>', '<C-G>u<C-U>', noremap)

vim.keymap.set('n', '<leader>d', function()
    require('utils.buffers').delete()
end)

vim.keymap.set('n', '[Q', ':<C-U>cfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']Q', ':<C-U>clast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[q', ':<C-U>exe "".(v:count ? v:count : "")."cprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']q', ':<C-U>exe "".(v:count ? v:count : "")."cnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[L', ':<C-U>lfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']L', ':<C-U>llast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[l', ':<C-U>exe "".(v:count ? v:count : "")."lprevious"<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']l', ':<C-U>exe "".(v:count ? v:count : "")."lnext"<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[B', ':<C-U>bfirst<CR>zvzz', noremap_silent)
vim.keymap.set('n', ']B', ':<C-U>blast<CR>zvzz', noremap_silent)
vim.keymap.set('n', '[b', ':<C-U>exe "".(v:count ? v:count : "")."bprevious"<CR>', noremap_silent)
vim.keymap.set('n', ']b', ':<C-U>exe "".(v:count ? v:count : "")."bnext"<CR>', noremap_silent)
vim.keymap.set('n', ']<Space>', [[:<C-U>lua require"utils.helpers".add_nl(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[<Space>', [[:<C-U>lua require"utils.helpers".add_nl(false)<CR>]], noremap_silent)
vim.keymap.set('n', ']e', [[:<C-U>lua require"utils.helpers".move_line(true)<CR>]], noremap_silent)
vim.keymap.set('n', '[e', [[:<C-U>lua require"utils.helpers".move_line(false)<CR>]], noremap_silent)
vim.keymap.set('n', '<C-L>', '<cmd>nohlsearch|diffupdate<CR>', noremap_silent)

set_command {
    lhs = 'ClearQf',
    rhs = function()
        require('utils.helpers').clear_qf()
    end,
    args = { force = true },
}

set_command {
    lhs = 'ClearLoc',
    rhs = function(win)
        require('utils.helpers').clear_qf(win or nvim.get_current_win())
    end,
    args = { nargs = '?', force = true },
}

vim.keymap.set('n', '<leader><leader>p', function()
    if nvim.t.swap_window == nil then
        nvim.t.swap_window = 1
        nvim.t.swap_cursor = nvim.win.get_cursor(0)
        nvim.t.swap_base_tab = nvim.tab.get_number(0)
        nvim.t.swap_base_win = nvim.tab.get_win(0)
        nvim.t.swap_base_buf = nvim.win.get_buf(0)
    else
        local swap_new_tab = nvim.tab.get_number(0)
        local swap_new_win = nvim.tab.get_win(0)
        local swap_new_buf = nvim.win.get_buf(0)
        if
            swap_new_tab == nvim.t.swap_base_tab
            and swap_new_win ~= nvim.t.swap_base_win
            and swap_new_buf ~= nvim.t.swap_base_buf
        then
            nvim.win.set_buf(0, nvim.t.swap_base_buf)
            nvim.win.set_buf(nvim.t.swap_base_win, swap_new_buf)
            nvim.win.set_cursor(0, nvim.t.swap_cursor)
            nvim.ex['normal!'] 'zz'
        end
        nvim.t.swap_window = nil
        nvim.t.swap_cursor = nil
        nvim.t.swap_base_tab = nil
        nvim.t.swap_base_win = nil
        nvim.t.swap_base_buf = nil
    end
end, noremap_silent)

vim.keymap.set(
    'n',
    '=l',
    [[<cmd>lua require"utils.helpers".toggle_qf(vim.api.nvim_get_current_win())<CR>]],
    noremap_silent
)

vim.keymap.set('n', '=q', [[<cmd>lua require"utils.helpers".toggle_qf()<CR>]], noremap_silent)

set_command {
    lhs = 'Terminal',
    rhs = function(...)
        local cmd = { ... }
        local is_empty = #cmd == 0
        local shell

        if not is_empty then
            shell = table.concat(cmd, ' ')
        elseif sys.name == 'windows' then
            if vim.regex([[^cmd\(\.exe\)\?$]]):match_str(vim.opt.shell:get()) then
                shell = 'powershell -noexit -executionpolicy bypass '
            else
                shell = vim.opt.shell:get()
            end
        else
            shell = vim.fn.fnamemodify(vim.env.SHELL or '', ':t')
            if vim.regex([[\(t\)\?csh]]):match_str(shell) then
                shell = executable 'zsh' and 'zsh' or (executable 'bash' and 'bash' or shell)
            end
        end

        local win = require('utils.windows').big_center()

        vim.wo[win].number = false
        vim.wo[win].relativenumber = false

        -- nvim.ex.edit('term://'..)
        vim.fn.termopen(shell)

        if is_empty then
            nvim.ex.startinsert()
        end
    end,
    args = { nargs = '*', force = true },
}

set_command {
    lhs = 'RelativeNumbersToggle',
    rhs = 'set relativenumber! relativenumber?',
    args = { force = true },
}

set_command {
    lhs = 'MouseToggle',
    rhs = function()
        if vim.o.mouse == '' then
            vim.o.mouse = 'a'
            print 'Mouse Enabled'
        else
            vim.o.mouse = ''
            print 'Mouse Disbled'
        end
    end,
    args = { force = true },
}

-- set_command{
--     lhs = 'ArrowsToggle',
--     rhs = function()
--     end,
--     args = {force=true}
-- }

set_command {
    lhs = 'BufKill',
    rhs = function(bang)
        local count = 0
        for _, buf in pairs(nvim.list_bufs()) do
            if not nvim.buf.is_valid(buf) or (bang and not nvim.buf.is_loaded(buf)) then
                nvim.ex['bwipeout!'](buf)
                count = count + 1
            end
        end
        if count > 0 then
            print(count, 'buffers deleted')
        end
    end,
    args = { bang = true, force = true, nargs = 0 },
}

set_command {
    lhs = 'ModifiableToggle',
    rhs = 'setlocal modifiable! modifiable?',
    args = { force = true },
}

set_command {
    lhs = 'CursorLineToggle',
    rhs = 'setlocal cursorline! cursorline?',
    args = { force = true },
}

set_command {
    lhs = 'ScrollBindToggle',
    rhs = 'setlocal scrollbind! scrollbind?',
    args = { force = true },
}

set_command {
    lhs = 'HlSearchToggle',
    rhs = 'setlocal hlsearch! hlsearch?',
    args = { force = true },
}

set_command {
    lhs = 'NumbersToggle',
    rhs = 'setlocal number! number?',
    args = { force = true },
}

set_command {
    lhs = 'SpellToggle',
    rhs = 'setlocal spell! spell?',
    args = { force = true },
}

set_command {
    lhs = 'WrapToggle',
    rhs = 'setlocal wrap! wrap?',
    args = { force = true },
}

set_command {
    lhs = 'VerboseToggle',
    rhs = 'let &verbose=!&verbose | echo "Verbose " . &verbose',
    args = { force = true },
}

set_command {
    lhs = 'TrimToggle',
    rhs = function()
        if not vim.b.trim then
            print 'Trim'
        else
            print 'NoTrim'
        end
        vim.b.trim = not vim.b.trim
    end,
    args = { force = true },
}

set_command {
    lhs = 'GonvimSettngs',
    rhs = "execute('edit ~/.gonvim/setting.toml')",
    args = { nargs = '*', force = true },
}

set_command {
    lhs = 'FileType',
    rhs = function(ft)
        ft = (ft and ft ~= '') and ft or 'text'
        vim.opt_local.filetype = ft
    end,
    args = { nargs = '?', complete = 'filetype', force = true },
}

set_command {
    lhs = 'FileFormat',
    rhs = function(format)
        format = (format and format ~= '') and format or 'unix'
        vim.opt_local.fileformat = format
    end,
    args = { nargs = '?', complete = 'customlist,v:lua._completions.fileformats', force = true },
}

set_command {
    lhs = 'SpellLang',
    rhs = function(lang)
        lang = (lang and lang ~= '') and lang or 'en'
        require('utils.helpers').spelllangs(lang)
    end,
    args = { force = true, nargs = '?', complete = 'customlist,v:lua._completions.spells' },
}

set_command {
    lhs = 'Qopen',
    rhs = "execute((&splitbelow) ? 'botright' : 'topleft' ) . ' copen ' . expand(<q-args>)",
    args = { nargs = '?', force = true },
}

-- TODO: Check for GUIs
if sys.name == 'windows' then
    vim.keymap.set('n', '<C-h>', '<cmd>call neovim#bs()<CR>', noremap_silent)
    vim.keymap.set('x', '<C-h>', '<cmd><ESC>', noremap)
    if not vim.g.started_by_firenvim then
        vim.keymap.set('n', '<C-z>', '<nop>', noremap)
    end
else
    set_command {
        lhs = 'Chmod',
        rhs = function(mode)
            if not mode:match '^%d+$' then
                vim.notify('Not a valid permissions mode: ' .. mode, 'ERROR', { title = 'Chmod' })
                return
            end
            local filename = vim.fn.expand '%'
            local chmod = require('utils.files').chmod
            if is_file(filename) then
                chmod(filename, mode)
            end
        end,
        args = { nargs = 1, force = true },
    }
end

set_command {
    lhs = 'MoveFile',
    rhs = function(bang, new_path)
        local current_path = vim.fn.expand '%:p'
        local is_dir = require('utils.files').is_dir

        if is_file(current_path) and is_dir(new_path) then
            new_path = new_path .. '/' .. vim.fn.fnamemodify(current_path, ':t')
        end

        require('utils.files').rename(current_path, new_path, bang)
    end,
    args = { force = true, bang = true, nargs = 1, complete = 'file' },
}

set_command {
    lhs = 'RenameFile',
    rhs = function(bang, args)
        local current_path = vim.fn.expand '%:p'
        local current_dir = vim.fn.expand '%:h'
        require('utils.files').rename(current_path, current_dir .. '/' .. args, bang)
    end,
    args = { force = true, bang = true, nargs = 1, complete = 'file' },
}

set_command {
    lhs = 'Mkdir',
    rhs = function(args)
        vim.fn.mkdir(vim.fn.fnameescape(args), 'p')
    end,
    args = { force = true, nargs = 1, complete = 'dir' },
}

set_command {
    lhs = 'RemoveFile',
    rhs = function(bang, args)
        local target = args ~= '' and args or vim.fn.expand '%'
        require('utils.files').delete(vim.fn.fnamemodify(target, ':p'), bang)
    end,
    args = { force = true, bang = true, nargs = '?', complete = 'file' },
}

set_command {
    lhs = 'Grep',
    rhs = function(...)
        require('utils.functions').send_grep_job { ... }
    end,
    args = { nargs = '+', force = true },
}

vim.keymap.set('n', 'gs', '<cmd>set opfunc=neovim#grep<CR>g@', noremap_silent)
vim.keymap.set('v', 'gs', ':<C-U>call neovim#grep(visualmode(), v:true)<CR>', noremap_silent)
vim.keymap.set('n', 'gss', function()
    require('utils.functions').send_grep_job(vim.fn.expand '<cword>')
end, noremap_silent)

set_command {
    lhs = 'Lint',
    rhs = function(...)
        local args = { ... }

        local ok, val = pcall(nvim.buf.get_option, 0, 'makeprg')
        local cmd = ok and val or vim.o.makeprg

        if cmd:sub(#cmd, #cmd) == '%' then
            cmd = cmd:gsub('%%', vim.fn.expand '%')
        end

        cmd = cmd .. table.concat(args, ' ')
        local lint = RELOAD('jobs'):new {
            cmd = cmd,
            qf = {
                on_fail = {
                    jump = true,
                    open = true,
                },
                loc = true,
                win = nvim.get_current_win(),
                context = 'AsyncLint',
                title = 'AsyncLint',
            },
        }
        lint:start()
    end,
    args = { nargs = '*', force = true },
}

if executable 'cscope' then
    local function cscope(cword, action)
        local actions = {
            definition = 'find g',
            callers = 'find c',
            file = 'find f',
            text = 'find t',
        }
        cword = (cword and cword ~= '') and cword or vim.fn.expand '<cword>'
        action = actions[action] or 'g'
        nvim.ex.cscope(action .. ' ' .. cword)
    end

    set_command {
        lhs = 'CDefinition',
        rhs = function(cword)
            cscope(cword, 'definition')
        end,
        args = { nargs = '?', force = true },
    }

    set_command {
        lhs = 'CCallers',
        rhs = function(cword)
            cscope(cword, 'callers')
        end,
        args = { nargs = '?', force = true },
    }

    set_command {
        lhs = 'CFile',
        rhs = function(cword)
            cscope(cword, 'file')
        end,
        args = { complete = 'file', nargs = '?', force = true },
    }

    set_command {
        lhs = 'CText',
        rhs = function(cword)
            cscope(cword, 'text')
        end,
        args = { nargs = '?', force = true },
    }
end

if executable 'scp' then
    local function convert_path(path, send, host)
        path = normalize_path(path)

        local remote_path = './'
        local hosts, paths, projects

        local path_json = normalize_path '~/.config/remotes/paths.json'
        if is_file(path_json) then
            local configs = read_json(path_json) or {}
            hosts = configs.hosts or {}
            paths = hosts[host] or configs.paths or {}
            projects = configs.projects or {}
        else
            paths = {}
            projects = {}
        end

        local project = path:match 'projects/([%w%d%.-_]+)'
        if not project then
            for short, full in pairs(projects) do
                if short ~= 'default' and path:match('/(' .. short .. ')[%w%d%.-_]*') then
                    project = full
                    break
                end
            end
            if not project then
                project = nvim.env.PROJECT or projects.default or 'mike'
            end
        end

        for loc, remote in pairs(paths) do
            if loc:match '%%PROJECT' then
                loc = loc:gsub('%%PROJECT', project)
            end
            loc = normalize_path(loc)
            if path:match(loc) then
                local tail = path:gsub(loc, '')
                if remote:match '%%PROJECT' then
                    remote = remote:gsub('%%PROJECT', project)
                end
                remote_path = remote .. '/' .. tail
                break
            end
        end

        if not send and remote_path == './' then
            remote_path = remote_path .. basename(path)
        end

        return remote_path
    end

    local function remote_cmd(host, send)
        local filename = vim.api.nvim_buf_get_name(vim.api.nvim_get_current_buf())
        local foward_slash = sys.name == 'windows' and not vim.opt.shellslash:get()
        if foward_slash then
            filename = filename:gsub('\\', '/')
        end
        local virtual_filename

        if filename:match '^%w+://' then
            local prefix = filename:match '^%w+://'
            filename = filename:gsub('^%w+://', '')
            if prefix == 'fugitive://' then
                filename = filename:gsub('%.git//?[%w%d]+//?', '')
            end
            virtual_filename = vim.fn.tempname()
            if foward_slash then
                virtual_filename = virtual_filename:gsub('\\', '/')
            end
        end

        vim.validate {
            filename = {
                filename,
                function(f)
                    return is_file(f) or virtual_filename
                end,
                'a valid file',
            },
        }

        if virtual_filename and send then
            writefile(virtual_filename, nvim.buf.get_lines(0, 0, -1, true))
        else
            filename = realpath(normalize_path(filename))
            if foward_slash then
                filename = filename:gsub('\\', '/')
            end
        end

        local remote_path = ('%s:%s'):format(host, convert_path(filename, send, host))
        local rcmd = [[scp -r "%s" "%s"]]
        if send then
            rcmd = rcmd:format(virtual_filename or filename, remote_path)
        else
            rcmd = rcmd:format(remote_path, virtual_filename or filename)
        end
        return rcmd
    end

    local function get_host(host)
        if not host or host == '' then
            host = vim.fn.input('Enter hostname > ', '', 'customlist,v:lua._completions.ssh_hosts_completion')
        end
        return host
    end

    set_command {
        lhs = 'SendFile',
        rhs = function(host)
            host = get_host(host)
            if not host or host == '' then
                return
            end
            local cmd = remote_cmd(host, true)
            local send_file = RELOAD('jobs'):new {
                cmd = cmd,
                opts = {
                    pty = true,
                },
            }
            send_file:start()
        end,
        args = {
            nargs = '*',
            force = true,
            complete = 'customlist,v:lua._completions.ssh_hosts_completion',
        },
    }

    set_command {
        lhs = 'GetFile',
        rhs = function(host)
            host = get_host(host)
            if not host or host == '' then
                return
            end
            local cmd = remote_cmd(host, false)
            local Job = RELOAD 'jobs'
            local get_file = Job:new {
                cmd = cmd,
                opts = {
                    pty = true,
                },
            }
            get_file:start()
        end,
        args = {
            nargs = '*',
            force = true,
            complete = 'customlist,v:lua._completions.ssh_hosts_completion',
        },
    }

    vim.keymap.set('n', '<leader><leader>s', '<cmd>SendFile<CR>', { noremap = true, silent = true })
    vim.keymap.set('n', '<leader><leader>g', '<cmd>GetFile<CR>', { noremap = true, silent = true })
end

set_command {
    lhs = 'Scratch',
    rhs = function(ft)
        ft = (ft and ft ~= '') and ft or vim.bo.filetype
        local scratchs = STORAGE.scratchs
        scratchs[ft] = scratchs[ft] or vim.fn.tempname()
        local buf = vim.fn.bufnr(scratchs[ft], true)

        if ft and ft ~= '' then
            vim.bo[buf].filetype = ft
        end
        vim.bo[buf].bufhidden = 'hide'

        local wins = nvim.tab.list_wins(0)
        local scratch_win

        for _, win in pairs(wins) do
            if nvim.win.get_buf(win) == buf then
                scratch_win = win
                break
            end
        end

        if not scratch_win then
            scratch_win = nvim.open_win(
                buf,
                true,
                { relative = 'editor', width = 1, height = 1, row = 1, col = 1 }
            )
        end

        nvim.set_current_win(scratch_win)
        nvim.ex.wincmd 'K'
    end,
    args = {
        nargs = '?',
        force = true,
        complete = 'filetype',
    },
}

set_command {
    lhs = 'ConncallLevel',
    rhs = function()
        local conncall = vim.opt_local.conceallevel:get() or 0
        vim.opt_local.conceallevel = conncall > 0 and 0 or 2
    end,
    args = { force = true },
}

set_command {
    lhs = 'Messages',
    rhs = function(args)
        if not args or args == '' then
            local messages = nvim.exec('messages', true)
            messages = clear_lst(vim.split(messages, '\n'))

            -- WARN: This is a WA to avoid EFM detecting ^I as part of a file in lua tracebacks
            for idx, msg in ipairs(messages) do
                messages[idx] = nvim.replace_termcodes(msg, true, false, true)
                if msg:match '%^I' and #msg > 2 then
                    messages[idx] = msg:gsub('%^I', '')
                end
            end

            vim.fn.setqflist({}, 'r', {
                lines = messages,
                title = 'Messages',
                context = 'Messages',
            })
            nvim.ex.Qopen()
        else
            nvim.ex.messages 'clear'
            local context = vim.fn.getqflist({ context = 1 }).context
            if context == 'Messages' then
                require('utils.helpers').clear_qf()
                nvim.ex.cclose()
            end
        end
    end,
    args = { nargs = '?', force = true, complete = 'messages' },
}

if executable 'pre-commit' then
    set_command {
        lhs = 'PreCommit',
        rhs = function(...)
            local args = { ... }
            local errorformats = {
                '%f:%l:%c: %t%n %m',
                '%f:%l:%c:%t: %m',
                '%f:%l:%c: %m',
                '%f:%l: %trror: %m',
                '%f:%l: %tarning: %m',
                '%f:%l: %tote: %m',
                '%f:%l:%m',
                '%f: %trror: %m',
                '%f: %tarning: %m',
                '%f: %tote: %m',
                '%f: Failed to json decode (%m: line %l column %c (char %*\\\\d))',
                '%f: Failed to json decode (%m)',
                '%E%f:%l:%c: fatal error: %m',
                '%E%f:%l:%c: error: %m',
                '%W%f:%l:%c: warning: %m',
                'Diff in %f:',
                '+++ %f',
                'reformatted %f',
            }
            local precommit = RELOAD('jobs'):new {
                cmd = 'pre-commit',
                args = args,
                -- progress = true,
                qf = {
                    efm = errorformats,
                    dump = false,
                    on_fail = {
                        dump = true,
                        jump = false,
                        open = true,
                    },
                    context = 'PreCommit',
                    title = 'PreCommit',
                },
            }
            precommit:start()
            -- precommit:progress()
        end,
        args = { nargs = '*', force = true },
    }
end

if not vim.env.SSH_CONNECTION then
    set_command {
        lhs = 'Open',
        rhs = require('utils.functions').open,
        args = { nargs = '1', force = true, complete = 'file' },
    }

    vim.keymap.set('n', 'gx', function()
        local cfile = vim.fn.expand '<cfile>'
        local cword = vim.fn.expand '<cWORD>'
        require('utils.functions').open(cword:match '^[%w]+://' and cword or cfile)
    end, noremap_silent)
end

set_command {
    lhs = 'Repl',
    rhs = function(...)
        local cmd = { ... }

        if #cmd == 0 then
            if vim.b.relp_cmd then
                cmd = vim.b.relp_cmd
            else
                cmd = vim.opt_local.filetype:get()
            end
        end

        local direction = vim.opt.splitbelow:get() and 'botright' or 'topleft'
        vim.api.nvim_exec(direction .. ' 20new', false)

        local win = vim.api.nvim_get_current_win()

        vim.wo[win].number = false
        vim.wo[win].relativenumber = false

        vim.fn.termopen(type(cmd) == type {} and table.concat(cmd, ' ') or cmd)
        nvim.ex.startinsert()
    end,
    args = { nargs = '*', force = true, complete = 'filetype' },
}

if has_nvim_6 then
    vim.keymap.set('n', '=D', function()
        vim.diagnostic.setqflist()
        vim.cmd 'wincmd J'
    end, noremap_silent)
end

vim.opt.formatexpr = [[luaeval('require"utils.buffers".format()')]]
vim.keymap.set('n', '=F', [[<cmd>normal! gggqG``<CR>]], { noremap = true, silent = true })

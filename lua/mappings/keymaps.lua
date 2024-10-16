-- local sys = require 'sys'
local nvim = require 'nvim'

local M = {}

function M.backspace()
    local ok, _ = pcall(vim.cmd.pop)
    if not ok then
        local key = vim.keycode '<C-o>'
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
        --                 vim.cmd.edit{ args = {jump_buf} }
        --             end
        --         end
        --         nvim.win.set_cursor(0, jumps[current_jump - 1][2], jumps[current_jump - 1][3])
        --     end
        -- end
    end
end

function M.nicenext(dir)
    local view = vim.fn.winsaveview()
    local ok, msg = pcall(vim.cmd.normal, { args = { dir }, bang = true })
    if ok and view.topline ~= vim.fn.winsaveview().topline then
        vim.cmd.normal { args = { 'zz' }, bang = true }
    elseif not ok then
        local err = (msg:match 'Vim:E486: Pattern not found:.*')
        vim.api.nvim_err_writeln(err or msg)
    end
end

function M.smart_insert()
    local current_line = vim.fn.line '.'
    local last_line = vim.fn.line '$'
    local buftype = vim.bo.buftype
    if #vim.api.nvim_get_current_line() == 0 and last_line ~= current_line and buftype ~= 'terminal' then
        return '"_ddO'
    end
    return 'i'
end

function M.smart_quit()
    local tabs = nvim.list_tabpages()
    local wins = nvim.tab.list_wins(0)
    if #wins > 1 and vim.fn.expand '%' ~= '[Command Line]' then
        nvim.win.hide(0)
    elseif #tabs > 1 then
        vim.cmd.tabclose { bang = true }
    else
        vim.cmd.quit { bang = true }
    end
end

function M.move_line(down)
    -- local cmd
    local lines = { '' }
    local count = vim.v.count1

    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
        end
    end

    if down then
        -- cmd = ']e'
        count = vim.fn.line '$' < vim.fn.line '.' + count and vim.fn.line '$' or vim.fn.line '.' + count
    else
        -- cmd = '[e'
        count = vim.fn.line '.' - count - 1 < 1 and 1 or vim.fn.line '.' - count - 1
    end

    vim.cmd.move(count)
    vim.cmd.normal { bang = true, args = { '==' } }
    -- TODO: Make repeat work
    -- pcall(vim.fn['repeat#set'], cmd, count)
end

function M.add_nl(down)
    local cursor_pos = nvim.win.get_cursor(0)
    local lines = { '' }
    local count = vim.v['count1']
    if count > 1 then
        for _ = 2, count, 1 do
            table.insert(lines, '')
        end
    end

    local cmd
    if not down then
        cursor_pos[1] = cursor_pos[1] + count
        cmd = '[ '
    else
        cmd = '] '
    end

    nvim.put(lines, 'l', down, true)
    nvim.win.set_cursor(0, cursor_pos)
    pcall(vim.fn['repeat#set'], cmd, count)
end

return M

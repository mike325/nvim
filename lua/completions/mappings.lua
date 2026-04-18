local nvim = require 'nvim'

local has_cmp = nvim.plugins['nvim-cmp']

local M = {}

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

function M.prev_item(fallback)
    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    if cmp and cmp.visible() then
        cmp.select_prev_item()
    elseif vim.fn.pumvisible() ~= 0 then
        vim.api.nvim_feedkeys(vim.keycode '<c-p>', 'n', false)
    else
        local ls = vim.F.npcall(require, 'luasnip')
        if ls then
            ls.unlink_current_if_deleted()
        end

        if ls and ls.locally_jumpable(-1) then
            ls.jump(-1)
        elseif vim.snippet and vim.snippet.active { direction = -1 } then
            vim.snippet.jump(-1)
        elseif pcall(require, 'neogen') and require('neogen').jumpable(-1) then
            vim.api.nvim_feedkeys(vim.keycode "<cmd>lua require('neogen').jump_prev()<CR>", 'n', false)
        elseif fallback then
            fallback()
        else
            vim.api.nvim_feedkeys(vim.keycode '<S-tab>', 'n', false)
        end
    end
end

function M.next_item(fallback)
    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    if cmp and cmp.visible() then
        cmp.select_next_item()
    elseif vim.fn.pumvisible() ~= 0 then
        vim.api.nvim_feedkeys(vim.keycode '<c-n>', 'n', false)
    else
        local ls = vim.F.npcall(require, 'luasnip')
        if ls then
            ls.unlink_current_if_deleted()
        end

        if ls and ls.locally_jumpable(1) then
            ls.jump(1)
        elseif vim.snippet and vim.snippet.active { direction = 1 } then
            vim.snippet.jump(1)
        elseif pcall(require, 'neogen') and require('neogen').jumpable() then
            vim.api.nvim_feedkeys(vim.keycode "<cmd>lua require('neogen').jump_next()<CR>", 'n', false)
        elseif vim.version.ge(vim.version(), { 0, 12 }) and vim.lsp.inline_completion.get() then
            return
        elseif cmp and has_words_before() then
            cmp.complete()
        elseif fallback then
            fallback()
        else
            vim.api.nvim_feedkeys(vim.keycode '<tab>', 'n', false)
        end
    end
end

function M.enter_item(fallback)
    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    local ls = vim.F.npcall(require, 'luasnip')
    if ls and ls.expandable() then
        ls.expand()
    elseif cmp and cmp.visible() then
        if not cmp.get_selected_entry() then
            cmp.close()
        else
            cmp.confirm { behavior = cmp.ConfirmBehavior.Replace, select = false }
        end
    elseif vim.fn.pumvisible() ~= 0 then
        local item_selected = vim.fn.complete_info()['selected'] ~= -1
        if item_selected then
            vim.api.nvim_feedkeys(vim.keycode '<c-y>', 'n', false)
        elseif vim.version.ge(vim.version(), { 0, 12 }) and vim.lsp.inline_completion.get() then
            return
        else
            vim.api.nvim_feedkeys(vim.keycode '<c-e>', 'n', false)
        end
    elseif vim.version.ge(vim.version(), { 0, 12 }) and vim.lsp.inline_completion.get() then
        return
    elseif _G['MiniPairs'] then
        vim.api.nvim_feedkeys(vim.keycode(_G['MiniPairs'].cr()), 'n', false)
    elseif fallback then
        fallback()
    else
        vim.api.nvim_feedkeys(vim.keycode '<cr>', 'n', false)
    end
end

function M.close(fallback)
    local ls = vim.F.npcall(require, 'luasnip')

    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    if ls and ls.choice_active() then
        ls.change_choice(1)
    elseif cmp and cmp.visible() then
        cmp.close()
    elseif vim.fn.pumvisible() ~= 0 then
        local item_selected = vim.fn.complete_info()['selected'] ~= -1
        if item_selected then
            vim.api.nvim_feedkeys(vim.keycode '<c-y>', 'n', false)
        else
            vim.api.nvim_feedkeys(vim.keycode '<c-e>', 'n', false)
        end
    elseif _G['MiniPairs'] then
        vim.api.nvim_feedkeys(vim.keycode(_G['MiniPairs'].cr()), 'n', false)
    elseif fallback then
        fallback()
    else
        vim.api.nvim_feedkeys(vim.keycode '<cr>', 'n', false)
    end
end

return M

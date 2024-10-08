local nvim = require 'nvim'

local has_cmp = nvim.plugins['nvim-cmp']

local M = {}

local function has_words_before()
    local line, col = unpack(vim.api.nvim_win_get_cursor(0))
    return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match '%s' == nil
end

function M.next_item(fallback)
    local neogen = vim.F.npcall(require, 'neogen')

    local ls = vim.F.npcall(require, 'luasnip')
    if ls then
        ls.unlink_current_if_deleted()
    end

    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    if cmp and cmp.visible() then
        cmp.select_next_item()
    elseif vim.fn.pumvisible() ~= 0 then
        vim.fn.feedkeys(vim.keycode '<c-n>', 'n')
    else
        if ls and ls.locally_jumpable(1) then
            ls.jump(1)
        elseif vim.snippet and vim.snippet.active { direction = 1 } then
            vim.snippet.jump(1)
        elseif neogen and neogen.jumpable() then
            vim.fn.feedkeys(vim.keycode "<cmd>lua require('neogen').jump_next()<CR>", '')
        elseif has_words_before() then
            if cmp then
                cmp.complete()
            end
        else
            -- The fallback function is treated as original mapped key. In this case, it might be `<Tab>`.
            fallback()
        end
    end
end

function M.prev_item(fallback)
    local neogen = vim.F.npcall(require, 'neogen')

    local ls = vim.F.npcall(require, 'luasnip')
    if ls then
        ls.unlink_current_if_deleted()
    end

    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

    if cmp and cmp.visible() then
        cmp.select_prev_item()
    elseif vim.fn.pumvisible() ~= 0 then
        vim.fn.feedkeys(vim.keycode '<c-p>', 'n')
    else
        if ls and ls.locally_jumpable(-1) then
            ls.jump(-1)
        elseif vim.snippet and vim.snippet.active { direction = -1 } then
            vim.snippet.jump(-1)
        elseif neogen and neogen.jumpable(-1) then
            vim.fn.feedkeys(vim.keycode "<cmd>lua require('neogen').jump_prev()<CR>", '')
        else
            fallback()
        end
    end
end

function M.enter_item(fallback)
    local ls = vim.F.npcall(require, 'luasnip')

    local cmp
    if has_cmp then
        cmp = vim.F.npcall(require, 'cmp')
    end

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
            vim.fn.feedkeys(vim.keycode '<c-y>', 'n')
        else
            vim.fn.feedkeys(vim.keycode '<c-e>', 'n')
        end
    elseif _G['MiniPairs'] then
        vim.fn.feedkeys(_G['MiniPairs'].cr(), 'n')
    elseif fallback then
        fallback()
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
            vim.fn.feedkeys(vim.keycode '<c-y>', 'n')
        else
            vim.fn.feedkeys(vim.keycode '<c-e>', 'n')
        end
    elseif _G['MiniPairs'] then
        vim.fn.feedkeys(_G['MiniPairs'].cr(), 'n')
    elseif fallback then
        fallback()
    end
end

return M

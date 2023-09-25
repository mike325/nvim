local random_string = require('tests.utils').random_string
local random_generator = require('tests.utils').random_generator
local random_list = require('tests.utils').random_list
local random_map = require('tests.utils').random_map
local check_clear_lst = require('tests.utils').check_clear_lst

describe('has_attrs', function()
    local has_attrs = require('utils.tables').has_attrs

    it('Check attribute in list', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(5, 20))
            local node = math.random(1, #lst)
            assert.is_true(has_attrs(lst, lst[node]))

            node = random_string(math.random(2, 10))
            assert.is_false(has_attrs(lst, node))
            -- note: this may hit one node and generate a false negative
            node = random_generator()
            assert.is_false(has_attrs(lst, node))
        end
    end)

    it('Check attribute in table', function()
        for _ = 1, 10 do
            local tbl = random_map(math.random(5, 20))
            local keys = vim.tbl_keys(tbl)
            local idx = math.random(1, #keys)
            assert.is_true(has_attrs(tbl, tbl[keys[idx]]))

            local node = random_string(math.random(2, 10))
            assert.is_false(has_attrs(tbl, node))
            -- note: this may hit one node and generate a false negative
            node = random_generator()
            assert.is_false(has_attrs(tbl, node))
        end
    end)

    it('Check list in list', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(5, 20))
            local beg_idx = math.random(1, math.floor(#lst / 2))
            local end_idx = math.random(math.floor(#lst / 2), #lst)
            local tmp_lst = vim.list_slice(lst, beg_idx, end_idx)
            assert.is_true(has_attrs(lst, tmp_lst))

            table.insert(tmp_lst, random_generator())
            assert.is_false(has_attrs(lst, tmp_lst))

            beg_idx = math.random(1, math.floor(#lst / 2))
            end_idx = math.random(math.floor(#lst / 2), #lst)
            tmp_lst = vim.list_slice(lst, beg_idx, end_idx)
            table.insert(tmp_lst, random_generator())
            assert.is_false(has_attrs(lst, tmp_lst))
        end
    end)

    it('Check list in table', function()
        for _ = 1, 10 do
            local tbl = random_map(math.random(5, 20))
            local keys = vim.tbl_keys(tbl)
            local beg_idx = math.random(1, math.floor(#keys / 2))
            local end_idx = math.random(math.floor(#keys / 2), #keys)
            local keys_vals = vim.list_slice(keys, beg_idx, end_idx)
            local tbl_in_tbl = {}
            for _, key in ipairs(keys_vals) do
                table.insert(tbl_in_tbl, tbl[key])
            end
            assert.is_true(has_attrs(tbl, tbl_in_tbl))

            table.insert(tbl_in_tbl, random_generator())
            assert.is_false(has_attrs(tbl, tbl_in_tbl))
        end
    end)
end)

describe('Uniq lists', function()
    local merge_uniq_list = require('utils.tables').merge_uniq_list
    local uniq_list = require('utils.tables').uniq_list

    local merge_uniq_unorder = require('utils.tables').merge_uniq_unorder
    local uniq_unorder = require('utils.tables').uniq_unorder

    local function check_lists(src, dest, merge)
        for _, src_node in ipairs(src) do
            assert.is_true(vim.list_contains(merge, src_node))
        end

        for _, dest_node in ipairs(dest) do
            assert.is_true(vim.list_contains(merge, dest_node))
        end
    end

    it('merge random order', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local merged_lst = merge_uniq_list(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            assert.equals(#merged_lst, (#lst_src + #lst_dest))
            assert.same(vim.fn.sort(merged_lst), vim.fn.sort(merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src)))
        end
    end)

    it('merge overlap order', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local end_idx = math.random(2, #lst_src)
            vim.list_extend(lst_dest, lst_src, 1, end_idx)
            local merged_lst = merge_uniq_list(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            assert.equals(#merged_lst, (#lst_src + #lst_dest - end_idx))
            assert.same(vim.fn.sort(merged_lst), vim.fn.sort(merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src)))
        end
    end)

    it('order', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local end_idx = math.random(2, #lst_src)
            local lst_dest = vim.list_extend(vim.deepcopy(lst_src), lst_src, 1, end_idx)
            local uniq = uniq_list(lst_dest)

            for _, src_node in ipairs(lst_src) do
                assert.is_true(vim.list_contains(uniq, src_node))
            end
            assert.same(uniq, lst_src)
        end
    end)

    it('merge random unorder', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local merged_lst = merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            assert.same(vim.fn.sort(merged_lst), vim.fn.sort(merge_uniq_list(vim.deepcopy(lst_dest), lst_src)))
        end
    end)

    it('merge overlap unorder', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local end_idx = math.random(2, #lst_src)
            vim.list_extend(lst_dest, lst_src, 1, end_idx)
            local merged_lst = merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            assert.same(vim.fn.sort(merged_lst), vim.fn.sort(merge_uniq_list(vim.deepcopy(lst_dest), lst_src)))
        end
    end)

    it('unorder', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local end_idx = math.random(2, #lst_src)
            local lst_dest = vim.list_extend(vim.deepcopy(lst_src), lst_src, 1, end_idx)
            local uniq = uniq_unorder(lst_dest)

            for _, src_node in ipairs(lst_src) do
                assert.is_true(vim.list_contains(uniq, src_node))
            end
            assert.same(vim.fn.sort(uniq), vim.fn.sort(lst_src))
        end
    end)
end)

describe('clear_lst', function()
    local clear_lst = require('utils.tables').clear_lst

    it('Trim values', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(1, 20), function(n)
                if type(n) == type '' then
                    return n .. string.rep(' ', math.random(1, 5))
                end
                return n
            end)
            check_clear_lst(clear_lst(lst))
        end
    end)

    it('Remove empty strings', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(1, 20), function(n)
                if type(n) == type '' then
                    if math.random(1, 10) % 2 == 0 then
                        return string.rep(' ', math.random(1, 5))
                    end
                end
                return n
            end)
            check_clear_lst(clear_lst(lst))
        end
    end)
end)

describe('str_to_clean_tbl', function()
    local str_to_clean_tbl = require('utils.tables').str_to_clean_tbl

    local strings = {
        { 't,1,2,r5,6', ',' },
        { 't,,,,,,,,,,5', ',' },
        { 't                      q                   4                1' },
        { 't\t w\t\tyas\t  \t\taas fa' },
        { '                 ' },
    }

    it('Sample strings', function()
        for _, v in ipairs(strings) do
            local lst = str_to_clean_tbl(v[1], v[2])
            assert.is_true(vim.tbl_islist(lst))
            check_clear_lst(lst)
        end
    end)

    it('Random Strings', function()
        for _ = 1, 10 do
            local str = random_string(150)
            local sep = math.random(0, 10) % 2 == 0 and random_string(1) or ' '
            local lst = str_to_clean_tbl(str, sep)
            assert.is_true(vim.tbl_islist(lst))
            check_clear_lst(lst)
        end
    end)
end)

describe('shallowcopy', function()
    local shallowcopy = require('utils.tables').shallowcopy

    it('simple array', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(1, 20))
            local copied = shallowcopy(lst)
            assert.are.same(lst, copied)
        end
    end)

    it('simple table', function()
        for _ = 1, 10 do
            local tbl = random_map(math.random(1, 20))
            local copied = shallowcopy(tbl)
            assert.are.same(tbl, copied)
        end
    end)

    it('nested array', function()
        for _ = 1, 10 do
            local nested = random_list(math.random(1, 20))
            for _ = 1, 10 do
                table.insert(nested, random_list(math.random(1, 20)))
            end
            local copied = shallowcopy(nested)
            for idx, _ in ipairs(nested) do
                assert.equals(nested[idx], copied[idx])
            end
        end
    end)
end)

describe('isempty', function()
    local isempty = require('utils.tables').isempty

    it('table', function()
        assert.is_true(isempty {})
        assert.is_false(isempty { 1 })
        assert.is_false(isempty { test = 1 })
        assert.is_false(isempty { 1, 2, 3, test = 1 })
        assert.is_false(isempty(random_list(3)))
        assert.is_false(isempty(random_map(3)))
    end)
end)

local mini_test = require 'mini.test'
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
            mini_test.expect.equality(has_attrs(lst, lst[node]), true)

            node = random_string(math.random(2, 10))
            mini_test.expect.equality(has_attrs(lst, node), false)
            -- note: this may hit one node and generate a false negative
            node = random_generator()
            mini_test.expect.equality(has_attrs(lst, node), false)
        end
    end)

    it('Check attribute in table', function()
        for _ = 1, 10 do
            local tbl = random_map(math.random(5, 20))
            local keys = vim.tbl_keys(tbl)
            local idx = math.random(1, #keys)
            mini_test.expect.equality(has_attrs(tbl, tbl[keys[idx]]), true)

            local node = random_string(math.random(2, 10))
            mini_test.expect.equality(has_attrs(tbl, node), false)
            -- note: this may hit one node and generate a false negative
            node = random_generator()
            mini_test.expect.equality(has_attrs(tbl, node), false)
        end
    end)

    it('Check list in list', function()
        for _ = 1, 10 do
            local lst = random_list(math.random(5, 20))
            local beg_idx = math.random(1, math.floor(#lst / 2))
            local end_idx = math.random(math.floor(#lst / 2), #lst)
            local tmp_lst = vim.list_slice(lst, beg_idx, end_idx)
            mini_test.expect.equality(has_attrs(lst, tmp_lst), true)

            table.insert(tmp_lst, random_generator())
            mini_test.expect.equality(has_attrs(lst, tmp_lst), false)

            beg_idx = math.random(1, math.floor(#lst / 2))
            end_idx = math.random(math.floor(#lst / 2), #lst)
            tmp_lst = vim.list_slice(lst, beg_idx, end_idx)
            table.insert(tmp_lst, random_generator())
            mini_test.expect.equality(has_attrs(lst, tmp_lst), false)
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
            mini_test.expect.equality(has_attrs(tbl, tbl_in_tbl), true)

            table.insert(tbl_in_tbl, random_generator())
            mini_test.expect.equality(has_attrs(tbl, tbl_in_tbl), false)
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
            mini_test.expect.equality(vim.list_contains(merge, src_node), true)
        end

        for _, dest_node in ipairs(dest) do
            mini_test.expect.equality(vim.list_contains(merge, dest_node), true)
        end
    end

    it('merge random order', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local merged_lst = merge_uniq_list(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            mini_test.expect.equality(
                vim.fn.sort(merged_lst),
                vim.fn.sort(merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src))
            )
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
            mini_test.expect.equality(
                vim.fn.sort(merged_lst),
                vim.fn.sort(merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src))
            )
        end
    end)

    it('order', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local end_idx = math.random(2, #lst_src)
            local lst_dest = vim.list_extend(vim.deepcopy(lst_src), lst_src, 1, end_idx)
            local uniq = uniq_list(lst_dest)

            for _, src_node in ipairs(lst_src) do
                mini_test.expect.equality(vim.list_contains(uniq, src_node), true)
            end
            mini_test.expect.equality(uniq, lst_src)
        end
    end)

    it('merge random unorder', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local lst_dest = random_list(math.random(5, 20))
            local merged_lst = merge_uniq_unorder(vim.deepcopy(lst_dest), lst_src)

            check_lists(lst_src, lst_dest, merged_lst)
            mini_test.expect.equality(
                vim.fn.sort(merged_lst),
                vim.fn.sort(merge_uniq_list(vim.deepcopy(lst_dest), lst_src))
            )
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
            mini_test.expect.equality(
                vim.fn.sort(merged_lst),
                vim.fn.sort(merge_uniq_list(vim.deepcopy(lst_dest), lst_src))
            )
        end
    end)

    it('unorder', function()
        for _ = 1, 10 do
            local lst_src = random_list(math.random(1, 10))
            local end_idx = math.random(2, #lst_src)
            local lst_dest = vim.list_extend(vim.deepcopy(lst_src), lst_src, 1, end_idx)
            local uniq = uniq_unorder(lst_dest)

            for _, src_node in ipairs(lst_src) do
                mini_test.expect.equality(vim.list_contains(uniq, src_node), true)
            end
            mini_test.expect.equality(vim.fn.sort(uniq), vim.fn.sort(lst_src))
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
            mini_test.expect.equality(vim.islist(lst), true)
            check_clear_lst(lst)
        end
    end)

    it('Random Strings', function()
        for _ = 1, 10 do
            local str = random_string(150)
            local sep = math.random(0, 10) % 2 == 0 and random_string(1) or ' '
            local lst = str_to_clean_tbl(str, sep)
            mini_test.expect.equality(vim.islist(lst), true)
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
            mini_test.expect.equality(lst, copied)
        end
    end)

    it('simple table', function()
        for _ = 1, 10 do
            local tbl = random_map(math.random(1, 20))
            local copied = shallowcopy(tbl)
            mini_test.expect.equality(tbl, copied)
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
                mini_test.expect.equality(nested[idx], copied[idx])
            end
        end
    end)
end)

describe('isempty', function()
    local isempty = require('utils.tables').isempty

    it('table', function()
        mini_test.expect.equality(isempty {}, true)
        mini_test.expect.equality(isempty { 1 }, false)
        mini_test.expect.equality(isempty { test = 1 }, false)
        mini_test.expect.equality(isempty { 1, 2, 3, test = 1 }, false)
        mini_test.expect.equality(isempty(random_list(3)), false)
        mini_test.expect.equality(isempty(random_map(3)), false)
    end)
end)

describe('remove_empty', function()
    local remove_empty = require('utils.tables').remove_empty

    it('remove empty strings', function()
        mini_test.expect.equality(remove_empty { '', '' }, {})
        mini_test.expect.equality(remove_empty { ' ', ' ' }, { ' ', ' ' })
        mini_test.expect.equality(remove_empty { 'test', '' }, { 'test' })
        mini_test.expect.equality(remove_empty { '', 'test' }, { 'test' })
    end)
end)

describe('tbl_contains', function()
    local tbl_contains = require('utils.tables').tbl_contains

    it('in list', function()
        mini_test.expect.equality(tbl_contains({ 'a', 'b', 'c' }, 'b'), true)
        mini_test.expect.equality(tbl_contains({ 'a', 'b', 'c' }, 'd'), false)
        mini_test.expect.equality(tbl_contains({}, 'a'), false)
    end)

    it('in table', function()
        mini_test.expect.equality(tbl_contains({ a = 1, b = 2 }, 2), true)
        mini_test.expect.equality(tbl_contains({ a = 1, b = 2 }, 3), false)
    end)
end)

describe('list_contains', function()
    local list_contains = require('utils.tables').list_contains

    it('check items', function()
        mini_test.expect.equality(list_contains({ 'a', 'b', 'c' }, 'a'), true)
        mini_test.expect.equality(list_contains({ 'a', 'b', 'c' }, 'd'), false)
        mini_test.expect.equality(list_contains({}, 'x'), false)
    end)
end)

describe('islist', function()
    local islist = require('utils.tables').islist

    it('check array', function()
        mini_test.expect.equality(islist { 1, 2, 3 }, true)
        mini_test.expect.equality(islist {}, true)
        mini_test.expect.equality(islist { a = 1, b = 2 }, false)
        mini_test.expect.equality(islist 'string', false)
        mini_test.expect.equality(islist(42), false)
    end)
end)

describe('tbl_keys', function()
    local tbl_keys = require('utils.tables').tbl_keys

    it('get keys', function()
        local keys = tbl_keys { a = 1, b = 2, c = 3 }
        mini_test.expect.equality(#keys, 3)
        mini_test.expect.equality(vim.list_contains(keys, 'a'), true)
        mini_test.expect.equality(vim.list_contains(keys, 'b'), true)
        mini_test.expect.equality(vim.list_contains(keys, 'c'), true)
    end)

    it('empty table', function()
        mini_test.expect.equality(tbl_keys {}, {})
    end)
end)

describe('tbl_values', function()
    local tbl_values = require('utils.tables').tbl_values

    it('get values', function()
        local values = tbl_values { a = 1, b = 2, c = 3 }
        mini_test.expect.equality(#values, 3)
        mini_test.expect.equality(vim.list_contains(values, 1), true)
        mini_test.expect.equality(vim.list_contains(values, 2), true)
        mini_test.expect.equality(vim.list_contains(values, 3), true)
    end)
end)

describe('tbl_filter', function()
    local tbl_filter = require('utils.tables').tbl_filter

    it('filter table', function()
        local filtered = tbl_filter(function(v)
            return v > 5
        end, { a = 1, b = 10, c = 3, d = 7, e = 2 })
        mini_test.expect.equality(filtered.a, nil)
        mini_test.expect.equality(filtered.b, 10)
        mini_test.expect.equality(filtered.d, 7)
        mini_test.expect.equality(filtered.c, nil)
    end)
end)

describe('tbl_map', function()
    local tbl_map = require('utils.tables').tbl_map

    it('map values', function()
        local mapped = tbl_map(function(v)
            return v * 2
        end, { 1, 2, 3 })
        mini_test.expect.equality(mapped[1], 2)
        mini_test.expect.equality(mapped[2], 4)
        mini_test.expect.equality(mapped[3], 6)
    end)

    it('map table', function()
        local mapped = tbl_map(function(v)
            return v .. '!'
        end, { a = 'hello', b = 'world' })
        mini_test.expect.equality(mapped.a, 'hello!')
        mini_test.expect.equality(mapped.b, 'world!')
    end)
end)

describe('list_extend', function()
    local list_extend = require('utils.tables').list_extend

    it('extend list', function()
        local dest = { 1, 2, 3 }
        local result = list_extend(dest, { 4, 5, 6 })
        mini_test.expect.equality(result, { 1, 2, 3, 4, 5, 6 })
        mini_test.expect.equality(dest, { 1, 2, 3, 4, 5, 6 })
    end)

    it('extend empty', function()
        local dest = {}
        local result = list_extend(dest, { 'a', 'b' })
        mini_test.expect.equality(result, { 'a', 'b' })
    end)
end)

describe('inspect', function()
    local inspect = require('utils.tables').inspect

    it('inspect primitives', function()
        mini_test.expect.equality(inspect(42), 42)
        mini_test.expect.equality(type(inspect 'hello'), 'string')
        mini_test.expect.equality(inspect(true), true)
    end)

    it('inspect array', function()
        local result = inspect { 1, 2, 3 }
        mini_test.expect.equality(type(result), 'string')
        mini_test.expect.equality(result:match '1', '1')
        mini_test.expect.equality(result:match '2', '2')
    end)

    it('inspect table', function()
        local result = inspect { a = 1, b = 'test' }
        mini_test.expect.equality(type(result), 'string')
        mini_test.expect.equality(result:match 'a', 'a')
        mini_test.expect.equality(result:match 'test', 'test')
    end)

    it('inspect function', function()
        local result = inspect(function() end)
        mini_test.expect.equality(result, '<function>')
    end)
end)

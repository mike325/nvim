-- local random_string = require('tests.utils').random_string
local random_word = require('tests.utils').random_word
local random_int = require('tests.utils').random_int

describe('split_components', function()
    local split_components = require('utils.strings').split_components

    it('pattern', function()
        local tests = {
            { pattern = '%d+', generator = random_int },
            { pattern = '%w+', generator = random_word },
        }

        for _, test in ipairs(tests) do
            local pattern = test.pattern
            local generator = test.generator

            for _ = 1, 5 do
                local node = ''
                local size = math.random(1, 10)
                for _ = 1, size do
                    node = node .. tostring(generator()) .. '.'
                end
                local node_lst = split_components(node, pattern)
                assert.are.equal(size, #node_lst)
                for _, n in ipairs(node_lst) do
                    assert.is_truthy(n:match('^' .. pattern .. '$'))
                end
            end
        end
    end)
end)

describe('Capitalize', function()
    local capitalize = require('utils.strings').capitalize

    it('words', function()
        assert.equals('Directory', capitalize 'directory')
        assert.equals('Directory', capitalize 'Directory')
        assert.equals('Directory', capitalize 'DIRECTORY')
        assert.equals('D', capitalize 'd')
        assert.equals('', capitalize '')
    end)
end)

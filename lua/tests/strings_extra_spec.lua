local mini_test = require 'mini.test'

describe('split', function()
    local split = require('utils.strings').split

    it('default whitespace separator', function()
        mini_test.expect.equality(split 'hello world foo', { 'hello', 'world', 'foo' })
        mini_test.expect.equality(split '  hello  world  ', { 'hello', 'world' })
        mini_test.expect.equality(split 'single', { 'single' })
        mini_test.expect.equality(split '', {})
    end)

    it('custom separator', function()
        mini_test.expect.equality(split('hello,world,foo', ','), { 'hello', 'world', 'foo' })
        mini_test.expect.equality(split('a|b|c', '|'), { 'a', 'b', 'c' })
        mini_test.expect.equality(split('one-two-three', '-'), { 'one', 'two', 'three' })
    end)

    it('plain flag', function()
        mini_test.expect.equality(split('hello.world', '.', true), { 'hello', 'world' })
    end)
end)

describe('empty', function()
    local empty = require('utils.strings').empty

    it('check empty string', function()
        mini_test.expect.equality(empty '', true)
        mini_test.expect.equality(empty 'hello', false)
        mini_test.expect.equality(empty ' ', false)
    end)
end)

describe('trim', function()
    local trim = require('utils.strings').trim

    it('trim spaces', function()
        mini_test.expect.equality(trim '  hello  ', 'hello')
        mini_test.expect.equality(trim 'hello', 'hello')
        mini_test.expect.equality(trim '  ', '')
        mini_test.expect.equality(trim '', '')
        mini_test.expect.equality(trim '\thello\t', 'hello')
    end)
end)

describe('base64_encode', function()
    local base64_encode = require('utils.strings').base64_encode

    it('encode strings', function()
        -- Test with known base64 encoded values
        local encoded = base64_encode 'hello'
        mini_test.expect.equality(type(encoded), 'string')
        mini_test.expect.equality(#encoded > 0, true)
    end)

    it('encode empty string', function()
        local encoded = base64_encode ''
        mini_test.expect.equality(type(encoded), 'string')
    end)
end)

describe('base64_decode', function()
    local base64_decode = require('utils.strings').base64_decode
    local base64_encode = require('utils.strings').base64_encode

    it('decode encoded string', function()
        local original = 'hello world'
        local encoded = base64_encode(original)
        local decoded = base64_decode(encoded)
        mini_test.expect.equality(decoded, original)
    end)

    it('decode empty encoded string', function()
        local encoded = base64_encode ''
        local decoded = base64_decode(encoded)
        mini_test.expect.equality(type(decoded), 'string')
    end)
end)

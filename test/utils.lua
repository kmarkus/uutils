#!/usr/bin/lua

local utils = require("utils")
local lu = require("luaunit")

TestUtils={}

function TestUtils:setup()

end

function TestUtils:teardown()

end

function TestUtils:TestSeal()

end

function TestUtils:TestTableCmp()
   lu.assertTrue(utils.table_cmp(1,1))
   lu.assertFalse(utils.table_cmp(1,33))
   lu.assertFalse(utils.table_cmp(1,false))
   lu.assertFalse(utils.table_cmp({},1))
   lu.assertFalse(utils.table_cmp(2.2,{2.2}))
   lu.assertTrue(utils.table_cmp({},{}))
   lu.assertTrue(utils.table_cmp({{}},{{}}))
   lu.assertTrue(utils.table_cmp({{{}}},{{{}}}))
   lu.assertTrue(utils.table_cmp({22.2},{22.2}))
   lu.assertTrue(utils.table_cmp({22.2,foo={bar=3.3}},{22.2, foo={bar=3.3}}))
end

os.exit( lu.LuaUnit.run() )

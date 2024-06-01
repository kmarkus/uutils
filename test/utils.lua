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

function TestUtils:TestTableMerge()
   lu.assertEquals(utils.table_merge({1,2,3}, {2,3,4}), {1,2,3})
   lu.assertEquals(utils.table_merge({a=1},{a=2,b=3}),{a=1,b=3})
   lu.assertEquals(utils.table_merge({a=1},{a=2,b={x=2,y=3}}),{a=1,b={x=2,y=3}})
   lu.assertEquals(utils.table_merge({b={x=22,y=33}},{a=2,b={x=2,y=3}}),{a=2,b={x=22,y=33}})

   local a =   {a=1, b={x=22,y=33,       z={n=111,m=222}}}
   local b =   {a=2, b={x=2, y=3,  w=44, z={n=222,m=333,p=444}}}
   local exp = {a=1, b={x=22,y=33, w=44, z={n=111,m=222, p=444}}}
   lu.assertEquals(utils.table_merge(a, b), exp)
end

os.exit( lu.LuaUnit.run() )

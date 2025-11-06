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

function TestUtils.TestTableCmpInvalid()
   -- add testcases for testing mismatching tables
   local function do_check_err(a,b, experr)
      local e, m = utils.table_cmp(a,b)
      lu.assertFalse(e)
      lu.assertStrContains(m, experr)
   end

   do_check_err( {a=1},           {},                  "a values differ: 1 != nil")
   do_check_err( {a=1},           {a=2},               "a values differ: 1 != 2")
   do_check_err( {},              {a=3},               "a values differ: 3 != nil")
   do_check_err( {a={b={c={}}}},  {a={b={c={1,2,3}}}}, "a.b.c tables differ in number of elements: 0 vs 3")
   do_check_err( {a={b={c={2}}}}, {a={b={c={1}}}},     "a.b.c.1 values differ: 2 != 1")
   do_check_err( {a={b={c={}}}},  {a={b={}}},          "a.b.c differ in type: table vs nil")
   do_check_err( {1,2,3,4},       {1,2,3,true},        "4 values differ: 4 != true")
   do_check_err( {{{{}}}},        {{{{{}}}}},          "1.1.1 tables differ in number of elements: 0 vs 1")

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

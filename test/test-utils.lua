#!/usr/bin/env lua

local utils = require("utils")
local lu = require("luaunit")

TestUtils={}

function TestUtils:TestSeal()
   local t = utils.seal({a=1, b="foo"}, true, true)
   lu.assertEquals(t.a, 1)
   lu.assertEquals(t.b, "foo")
   -- writing to an immutable table errors
   lu.assertError(function() t.b = "bar" end)
   -- the original table is not modified
   local orig = {a=1}
   local s = utils.seal(orig, true)
   lu.assertError(function() s.a = 2 end)
   lu.assertEquals(orig.a, 1)
end

function TestUtils:TestStrictSeal()
   local t = utils.seal({a=1}, false, true)
   -- reading/assigning a non-existing key errors in strict mode
   lu.assertError(function() return t.nope end)
   lu.assertError(function() t.nope = 5 end)
   -- assigning an existing key is allowed (not immutable)
   t.a = 2
   lu.assertEquals(t.a, 2)
end

function TestUtils:TestPadTrim()
   lu.assertEquals(utils.lpad("x", 4), "   x")
   lu.assertEquals(utils.rpad("x", 4), "x   ")
   lu.assertEquals(utils.lpad("x", 4, "*"), "***x")
   lu.assertEquals(utils.trim("  hello  "), "hello")
   lu.assertEquals(utils.ltrim("  hello  "), "hello  ")
   lu.assertEquals(utils.rtrim("  hello  "), "  hello")
end

function TestUtils:TestSplit()
   lu.assertEquals(utils.split("a,b,c", ","), {"a", "b", "c"})
   lu.assertEquals(utils.split("a", ","), {"a"})
   lu.assertEquals(utils.split("/usr/local/bin", "/"), {"usr", "local", "bin"})
end

function TestUtils:TestBasename()
   lu.assertEquals(utils.basename("aaa"), "aaa")
   lu.assertEquals(utils.basename("aaa.bbb.ccc"), "ccc")
end

function TestUtils:TestConsCarCdr()
   -- regression: cons used to crash with "attempt to call a table value"
   lu.assertEquals(utils.cons(1, {2, 3}), {1, 2, 3})
   lu.assertEquals(utils.cons("a", {}), {"a"})
   lu.assertEquals(utils.car({1, 2, 3}), 1)
   lu.assertEquals(utils.cdr({1, 2, 3}), {2, 3})
   lu.assertEquals(utils.cdr({1}), {})
end

function TestUtils:TestAppend()
   lu.assertEquals(utils.append({1, 2}, {3, 4}), {1, 2, 3, 4})
   lu.assertEquals(utils.append({1}, {2}, {3}), {1, 2, 3})
end

function TestUtils:TestFlatten()
   lu.assertEquals(utils.flatten({1, {2, {3, 4}}, 5}), {1, 2, 3, 4, 5})
   lu.assertEquals(utils.flatten({}), {})
end

function TestUtils:TestDeepcopy()
   local orig = {a=1, b={c=2, d={3, 4}}}
   local copy = utils.deepcopy(orig)
   lu.assertEquals(copy, orig)
   copy.b.c = 99
   lu.assertEquals(orig.b.c, 2)   -- original unaffected
end

function TestUtils:TestMapImapFilterFold()
   lu.assertEquals(utils.imap(function(x) return x*2 end, {1, 2, 3}), {2, 4, 6})
   lu.assertEquals(utils.imap(function(x) return x end, nil), {})
   lu.assertEquals(utils.filter(function(x) return x % 2 == 0 end, {1, 2, 3, 4}), {2, 4})
   lu.assertEquals(utils.foldr(function(acc, v) return acc + v end, 0, {1, 2, 3, 4}), 10)
end

function TestUtils:TestFill()
   lu.assertEquals(utils.fill(0, 3), {0, 0, 0})
   -- deepcopy semantics: nested values are independent
   local f = utils.fill({x=1}, 2)
   f[1].x = 9
   lu.assertEquals(f[2].x, 1)
end

function TestUtils:TestNumElem()
   lu.assertEquals(utils.num_elem({1, 2, 3}), 3)
   lu.assertEquals(utils.num_elem({a=1, b=2, 3}), 3)
   lu.assertEquals(utils.num_elem({}), 0)
end

function TestUtils:TestTableHasUnique()
   lu.assertTrue(utils.table_has({1, 2, 3}, 2))
   lu.assertFalse(utils.table_has({1, 2, 3}, 9))
   lu.assertEquals(utils.table_unique({1, 2, 2, 3, 3, 3}), {1, 2, 3})
end

function TestUtils:TestTab2str()
   lu.assertEquals(utils.tab2str({1, 2, 3}), '{1,2,3}')
   lu.assertEquals(utils.tab2str({a=1}), '{a=1}')
   lu.assertEquals(utils.tab2str("plain"), "plain")
end

function TestUtils:TestStrsetlen()
   lu.assertEquals(utils.strsetlen("hi", 5), "hi   ")
   lu.assertEquals(utils.strsetlen("hello", 3), "hel")
   lu.assertEquals(utils.strsetlen("hello world", 8, true), "hell... ")
end

function TestUtils:TestStripAnsi()
   local s = utils.strip_ansi("\27[31mred\27[0m")
   lu.assertEquals(s, "red")
end

function TestUtils:TestStrToHexstr()
   lu.assertEquals(utils.str_to_hexstr("AB"), "4142")
   lu.assertEquals(utils.str_to_hexstr("AB", " "), "41 42 ")
end

function TestUtils:TestMaxMin()
   lu.assertEquals(utils.max(3, 7), 7)
   lu.assertEquals(utils.max(7, 3), 7)
   lu.assertEquals(utils.min(3, 7), 3)
   lu.assertEquals(utils.min(7, 3), 3)
end

function TestUtils:TestWrap()
   local wrapped = utils.wrap("aaa bbb ccc ddd", 7)
   lu.assertStrContains(wrapped, "\n")
end

function TestUtils:TestExpand()
   local exp, unexp = utils.expand("Hello $WHO", {WHO="World"})
   lu.assertEquals(exp, "Hello World")
   lu.assertEquals(#unexp, 0)
   -- unexpanded parameters are reported
   local _, missing = utils.expand("$A and $B", {A="x"})
   lu.assertEquals(missing, {"B"})
end

function TestUtils:TestExpandPercentValue()
   -- regression: a '%' in the value used to error with
   -- "invalid use of '%' in replacement string"
   local exp = utils.expand("x=$V", {V="100%done"})
   lu.assertEquals(exp, "x=100%done")
end

function TestUtils:TestPreproc()
   local ok, res = utils.preproc("a $(1+1) b\n", {})
   lu.assertTrue(ok)
   lu.assertStrContains(res, "a 2 b")
end

function TestUtils:TestPreprocLoop()
   local ok, res = utils.preproc(
      "@ for i,v in ipairs(rows) do\n$(i): $(v)\n@ end\n",
      {ipairs=ipairs, rows={"a", "b"}})
   lu.assertTrue(ok)
   lu.assertStrContains(res, "1: a")
   lu.assertStrContains(res, "2: b")
end

function TestUtils:TestEvalSandbox()
   local ok, res = utils.eval_sandbox("return 1 + 2")
   lu.assertTrue(ok)
   lu.assertEquals(res, 3)
   -- failure returns false and a message
   local bad = utils.eval_sandbox("this is not lua (")
   lu.assertFalse(bad)
end

function TestUtils:TestEval()
   lu.assertEquals(utils.eval("return 6 * 7"), 42)
end

function TestUtils:TestProcArgs()
   local r = utils.proc_args({"-f", "file1", "file2", "-v"})
   lu.assertEquals(r["-f"], {"file1", "file2"})
   lu.assertEquals(r["-v"], {})
end

function TestUtils:TestTabulate()
   local hdr, rows = utils.tabulate({{a=1, b=2}, {a=3, b=4}})
   lu.assertEquals(hdr, {"a", "b"})
   lu.assertEquals(rows, {{1, 2}, {3, 4}})
end

function TestUtils:TestAdvise()
   local log = {}
   local base = function() log[#log+1] = "base" end
   local before = utils.advise("before", base, function() log[#log+1] = "before" end)
   before()
   lu.assertEquals(log, {"before", "base"})
   log = {}
   local after = utils.advise("after", base, function() log[#log+1] = "after" end)
   after()
   lu.assertEquals(log, {"base", "after"})
   -- nil oldfun returns newfun
   local nf = function() end
   lu.assertIs(utils.advise("before", nil, nf), nf)
end

function TestUtils:TestMemoize()
   local calls = 0
   local f = utils.memoize(function(x) calls = calls + 1; return x * x end)
   lu.assertEquals(f(4), 16)
   lu.assertEquals(f(4), 16)
   lu.assertEquals(calls, 1)   -- second call served from cache
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

return TestUtils

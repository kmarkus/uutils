#!/usr/bin/env lua

local time = require("time")
local lu = require("luaunit")

local NS = time.ns_per_s

TestTime = {}

function TestTime:test_normalize_noop()
   lu.assertEquals({time.normalize(1, 500000000)}, {1, 500000000})
   lu.assertEquals({time.normalize(0, 0)}, {0, 0})
   lu.assertEquals({time.normalize(-3, -250000000)}, {-3, -250000000})
end

-- regression: with sec == 0 the old implementation failed to carry an
-- nsec overflow into sec and returned a denormalized value
function TestTime:test_normalize_sec_zero_overflow()
   lu.assertEquals({time.normalize(0, NS + 5)}, {1, 5})
   lu.assertEquals({time.normalize(0, 2*NS - 2)}, {1, NS - 2})
   lu.assertEquals({time.normalize(0, -(NS + 5))}, {-1, -5})
end

function TestTime:test_normalize_multi_second_overflow()
   lu.assertEquals({time.normalize(0, 3*NS + 7)}, {3, 7})
   lu.assertEquals({time.normalize(0, -3*NS - 7)}, {-3, -7})
end

function TestTime:test_normalize_sign_agreement()
   -- positive sec, negative nsec -> borrow
   lu.assertEquals({time.normalize(5, -500000000)}, {4, 500000000})
   -- negative sec, positive nsec -> carry
   lu.assertEquals({time.normalize(-5, 500000000)}, {-4, -500000000})
end

function TestTime:test_add()
   lu.assertEquals({time.add({sec=1, nsec=0}, {sec=2, nsec=0})}, {3, 0})
   -- two near-full-second values carry into sec
   lu.assertEquals({time.add({sec=0, nsec=NS-1}, {sec=0, nsec=NS-1})}, {1, NS-2})
   lu.assertEquals({time.add({sec=1, nsec=600000000}, {sec=1, nsec=600000000})}, {3, 200000000})
end

function TestTime:test_sub()
   lu.assertEquals({time.sub({sec=3, nsec=0}, {sec=1, nsec=0})}, {2, 0})
   -- borrow across the second boundary
   lu.assertEquals({time.sub({sec=2, nsec=100000000}, {sec=1, nsec=500000000})}, {0, 600000000})
end

function TestTime:test_cmp()
   lu.assertEquals(time.cmp({sec=1, nsec=0}, {sec=0, nsec=0}), 1)
   lu.assertEquals(time.cmp({sec=0, nsec=0}, {sec=1, nsec=0}), -1)
   lu.assertEquals(time.cmp({sec=1, nsec=5}, {sec=1, nsec=5}), 0)
   lu.assertEquals(time.cmp({sec=1, nsec=6}, {sec=1, nsec=5}), 1)
   lu.assertEquals(time.cmp({sec=1, nsec=4}, {sec=1, nsec=5}), -1)
end

function TestTime:test_div()
   lu.assertEquals({time.div({sec=4, nsec=0}, 2)}, {2, 0})
   lu.assertEquals({time.div({sec=2, nsec=0}, 2)}, {1, 0})
end

function TestTime:test_abs()
   lu.assertEquals({time.abs({sec=-2, nsec=-5})}, {2, 5})
   lu.assertEquals({time.abs({sec=3, nsec=7})}, {3, 7})
end

function TestTime:test_conversions()
   lu.assertEquals(time.ts2us({sec=1, nsec=0}), time.us_per_s)
   lu.assertEquals(time.tous(1, 0), time.us_per_s)
   -- string form ends in "us" (numeric formatting differs between Lua
   -- versions: "1us" on 5.1/5.2, "1.0us" on 5.3+)
   lu.assertStrMatches(time.ts2str({sec=0, nsec=1000}), "1%.?0?us")
   lu.assertStrMatches(time.tostr_us(0, 1000), "1%.?0?us")
end

return TestTime

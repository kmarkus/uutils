--- Various `sys/time.h` like operations.
--
-- Functions take `struct timespec` like tables with `sec` and `nsec`
-- fields as input and return two values `sec, nsec`.
--
-- @module time
-- @author Markus Klotzbuecher <mk@mkio.de>
-- @copyright 2010-2013 Markus Klotzbuecher (KU Leuven), 2014-2026 Markus Klotzbuecher
-- @license BSD-3-Clause
-- @usage
-- local time = require("time")
-- local sec, nsec = time.add({sec=1, nsec=5e8}, {sec=0, nsec=6e8})
-- -- sec == 2, nsec == 100000000

local M = {}

M.VERSION = "1.0.1"

-- constants
local ns_per_s = 1000000000
local us_per_s = 1000000

M.ns_per_s = ns_per_s
M.us_per_s = us_per_s

--- Normalize a (sec, nsec) pair.
-- Carries any nsec over/underflow into sec and makes sec and nsec
-- agree in sign, so that the represented value is always
-- `sec*1e9 + nsec`. Unlike a naive implementation this also handles
-- the `sec == 0` case and multi-second overflows.
-- @param sec seconds
-- @param nsec nanoseconds
-- @return normalized sec
-- @return normalized nsec
function M.normalize(sec, nsec)
   -- carry any nsec over/underflow into sec
   while nsec >= ns_per_s do
      sec = sec + 1
      nsec = nsec - ns_per_s
   end
   while nsec <= -ns_per_s do
      sec = sec - 1
      nsec = nsec + ns_per_s
   end
   -- make sec and nsec agree in sign
   if sec > 0 and nsec < 0 then
      sec = sec - 1
      nsec = nsec + ns_per_s
   elseif sec < 0 and nsec > 0 then
      sec = sec + 1
      nsec = nsec - ns_per_s
   end
   return sec, nsec
end

--- Subtract a timespec from another and normalize
-- @param a timespec to subtract from
-- @param b timespec to subtract
function M.sub(a, b)
   local sec = a.sec - b.sec
   local nsec = a.nsec - b.nsec
   return M.normalize(sec, nsec)
end

--- Add a timespec from another and normalize
-- @param a timespec a
-- @param b timespec b
function M.add(a, b)
   local sec = a.sec + b.sec
   local nsec = a.nsec + b.nsec
   return M.normalize(sec, nsec)
end

--- Divide a timespec inplace
-- @param t timespec to divide
-- @param d divisor
function M.div(t, d)
   return M.normalize(t.sec / d, t.nsec / d)
end

--- Compare two timespecs.
-- @param t1 timespec a
-- @param t2 timespec b
-- @return 1 if t1 > t2, -1 if t1 < t2, 0 if t1 == t2
function M.cmp(t1, t2)
   if(t1.sec > t2.sec) then return 1
   elseif (t1.sec < t2.sec) then return -1
   elseif (t1.nsec > t2.nsec) then return 1
   elseif (t1.nsec < t2.nsec) then return -1
   else return 0 end
end

--- Return absolute timespec.
-- @param ts timespec
-- @return absolute sec
-- @return absolute nsec
function M.abs(ts)
   return math.abs(ts.sec), math.abs(ts.nsec)
end

--- Convert timespec to microseconds
-- @param ts timespec
-- @return number of microseconds
function M.ts2us(ts)
   return ts.sec * us_per_s + ts.nsec / 1000
end

--- Convert a timespec to a string (in micro-seconds)
--- for pretty printing purposes
function M.ts2str(ts)
   return ("%sus"):format(M.ts2us(ts))
end

--- Convert timespec to us
-- @param sec
-- @param nsec
-- @return time is us
function M.tous(sec, nsec)
   return sec * us_per_s + nsec / 1000
end

--- Convert timespec to us string
-- @param sec
-- @param nsec
-- @return time string
function M.tostr_us(sec, nsec)
   return ("%sus"):format(M.tous(sec, nsec))
end

return M

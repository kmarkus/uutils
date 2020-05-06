--
-- (C) 2010-2017 Markus Klotzbuecher, mk@marumbi.de
--
-- Permission is hereby granted, free of charge, to any person obtaining a copy
-- of this software and associated documentation files (the "Software"), to deal
-- in the Software without restriction, including without limitation the rights
-- to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
-- copies of the Software, and to permit persons to whom the Software is
-- furnished to do so, subject to the following conditions:
--
-- The above copyright notice and this permission notice shall be included in
-- all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
-- IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
-- FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
-- AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
-- LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
-- OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
-- THE SOFTWARE.

--- Various sys/time.h like operations.
-- Take struct timespec tables with 'sec' and 'nsec' fields as input
-- and return two values sec, nsec
-- @release Released under MIT
-- @copyright Markus Klotzbuecher, Katholieke Universiteit Leuven, Belgium.



local M = {}

M.VERSION = "1.0.0"

-- constants
local ns_per_s = 1000000000
local us_per_s = 1000000

M.ns_per_s = ns_per_s
M.us_per_s = us_per_s

--- Normalize time.
-- @param sec seconds
-- @param nsec nanoseconds
function M.normalize(sec, nsec)
   if sec > 0 and nsec > 0 then
      while nsec >= ns_per_s do
	 sec = sec + 1
	 nsec = nsec - ns_per_s
      end
   elseif sec > 0 and nsec < 0 then
      while nsec <= 0 do
	 sec = sec - 1
	 nsec = nsec + ns_per_s
      end
   elseif sec < 0 and nsec > 0 then
      while nsec > 0 do
	 sec = sec + 1
	 nsec = nsec - ns_per_s
      end
   elseif sec < 0 and nsec < 0 then
      while nsec <= -ns_per_s do
	 sec = sec - 1
	 nsec = nsec + ns_per_s
      end
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

--- Compare to timespecs
-- @result return 1 if t1 is greater than t2, -1 if t1 is less than t2 and 0 if t1 and t2 are equal
function M.cmp(t1, t2)
   if(t1.sec > t2.sec) then return 1
   elseif (t1.sec < t2.sec) then return -1
   elseif (t1.nsec > t2.nsec) then return 1
   elseif (t1.nsec < t2.nsec) then return -1
   else return 0 end
end

-- Return absolute timespec.
-- @param ts timespec
-- @return absolute sec
-- @return absolute nsec
function M.abs(ts)
   return math.abs(ts.sec), math.abs(ts.nsec)
end

--- Convert timespec to microseconds
-- @param ts timespec
-- @result number of microseconds
function M.ts2us(ts)
   return ts.sec * us_per_s + ts.nsec / 1000
end

--- Convert a timespec to a string (in micro-seconds)
--- for pretty printing purposes
function M.ts2str(ts)
   return ("%dus"):format(M.ts2us(ts))
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
   return ("%dus"):format(M.tous(sec, nsec))
end

return M

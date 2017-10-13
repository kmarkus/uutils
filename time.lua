--
-- (C) 2010,2011 Markus Klotzbuecher, markus.klotzbuecher@mech.kuleuven.be,
-- Department of Mechanical Engineering, Katholieke Universiteit
-- Leuven, Belgium.
--
-- You may redistribute this software and/or modify it under either
-- the terms of the GNU Lesser General Public License version 2.1
-- (LGPLv2.1 <http://www.gnu.org/licenses/old-licenses/lgpl-2.1.html>)
-- or (at your discretion) of the Modified BSD License: Redistribution
-- and use in source and binary forms, with or without modification,
-- are permitted provided that the following conditions are met:
--    1. Redistributions of source code must retain the above copyright
--       notice, this list of conditions and the following disclaimer.
--    2. Redistributions in binary form must reproduce the above
--       copyright notice, this list of conditions and the following
--       disclaimer in the documentation and/or other materials provided
--       with the distribution.
--    3. The name of the author may not be used to endorse or promote
--       products derived from this software without specific prior
--       written permission.
--
-- THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS
-- OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
-- WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
-- ARE DISCLAIMED. IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY
-- DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
-- DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE
-- GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
-- INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
-- WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
-- NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
-- SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--

--- Various sys/time.h like operations.
-- Take struct timespec tables with 'sec' and 'nsec' fields as input
-- and return two values sec, nsec
-- @release Released under DualBSD/LGPG
-- @copyright Markus Klotzbuecher, Katholieke Universiteit Leuven, Belgium.



local M = {}

M.VERSION = "1.0.0"

-- constants
local ns_per_s = 1000000000
local us_per_s = 1000000

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

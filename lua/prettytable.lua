local M = {}

local MAX_LINE_LENGTH = 100

local fmt, rep = string.format, string.rep
local insert, concat, sort = table.insert, table.concat, table.sort


--- Pretty print Lua values in a human readable way
-- Table will be printed in one line if possible and newlines only
-- added if the resulting line is larger than max_line.
-- @param val value to format
-- @param indent number of space to indent with
-- @param max_line maximum line length.
-- @param keysort optional function to sort keys
function M.tostr(val, indent, max_line_length, keysort)
   if type(val) ~= 'table' then return tostring(val) end

   indent = indent or 0
   max_line_length = max_line_length or MAX_LINE_LENGTH
   keysort = keysort or function(a, b) return tostring(a) < tostring(b) end

   local function serialize_value(v, ind)
      if type(v) == "table" then
	 return M.tostr(v, ind, max_line_length, keysort)
      elseif type(v) == "string" then
	 return fmt("%q", v)
      else
	 return tostring(v)
      end
   end

   -- try to format on one line first
   local function try_one_line(t)
      local parts = {}
      local keys = {}

      -- Separate array part and hash part
      local array_len = #t

      for k, v in pairs(t) do
	 if type(k) ~= "number" or k > array_len or k < 1 then
	    insert(keys, k)
	 end
      end

      sort(keys, keysort)

      -- add array elements first
      for i = 1, array_len do
	 insert(parts, serialize_value(t[i], indent + 1))
      end

      -- add hash elements
      for _, k in ipairs(keys) do
	 local key_str
	 if type(k) == "string" and k:match("^[%a_][%w_]*$") then
	    key_str = k
	 elseif type(k) == "number" then
	    key_str = fmt("[%d]", k)
	 else
	    key_str = fmt("[%s]", serialize_value(k, indent + 1))
	 end
	 insert(parts, key_str .. "=" .. serialize_value(t[k], indent + 1))
      end

      return "{" .. concat(parts, ", ") .. "}"
   end

   local one_line = try_one_line(val)
   local current_indent = rep("  ", indent)

   -- if it fits on one line, use it
   if #(current_indent .. one_line) <= max_line_length then
      return one_line
   end

   -- otherwise, format with newlines
   local parts = {}
   local keys = {}
   local array_len = #val

   for k, v in pairs(val) do
      if type(k) ~= "number" or k > array_len or k < 1 then
	 insert(keys, k)
      end
   end

   sort(keys, keysort)

   local inner_indent = rep("  ", indent + 1)
   insert(parts, "{")

   -- add array elements
   for i = 1, array_len do
      local value = serialize_value(val[i], indent + 1)
      insert(parts, inner_indent .. value .. ",")
   end

   -- add hash elements
   for _, k in ipairs(keys) do
      local key_str
      if type(k) == "string" and k:match("^[%a_][%w_]*$") then
	 key_str = k
      elseif type(k) == "number" then
	 key_str = fmt("[%d]", k)
      else
	 key_str = fmt("[%s]", serialize_value(k, indent + 1))
      end
      local value = serialize_value(val[k], indent + 1)
      insert(parts, inner_indent .. key_str .. "=" .. value .. ",")
   end

   insert(parts, current_indent .. "}")

   return concat(parts, "\n")
end

return M

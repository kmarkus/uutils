local M = {}

M.MAX_LINE_LENGTH = 100
M.INDENT = 2
M.INITIAL_INDENT = 0

local fmt, rep = string.format, string.rep
local insert, concat, sort = table.insert, table.concat, table.sort

--- Pretty print Lua values in a human readable way
-- Table will be printed in one line if possible and newlines only
-- added if the resulting line is larger than max_line.
-- @param val value to format
-- @param max_line maximum line length.
-- @param initial_indent initial indentation depth
-- @param indent number of spaces per indentation level
-- @param keysort optional function to sort keys
-- @param parent_key_len length of parent key (for nested tables)
function M.tostr(val, max_line_length, initial_indent, indent, keysort, parent_key_len)
   if type(val) ~= 'table' then return tostring(val) end

   indent = indent or M.INDENT
   initial_indent = initial_indent or M.INITIAL_INDENT
   max_line_length = max_line_length or M.MAX_LINE_LENGTH
   keysort = keysort or function(a, b) return tostring(a) < tostring(b) end
   parent_key_len = parent_key_len or 0

   local function serialize_value(v, ind, key_len)
      if type(v) == "table" then
	 return M.tostr(v, max_line_length, ind, indent, keysort, key_len)
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
	 insert(parts, serialize_value(t[i], initial_indent + 1, 0))
      end

      -- add hash elements
      for _, k in ipairs(keys) do
	 local key_str
	 if type(k) == "string" and k:match("^[%a_][%w_]*$") then
	    key_str = k
	 elseif type(k) == "number" then
	    key_str = fmt("[%d]", k)
	 else
	    key_str = fmt("[%s]", serialize_value(k, initial_indent + 1, 0))
	 end
	 local kv_str = key_str .. "=" .. serialize_value(t[k], initial_indent + 1, #key_str + 1)
	 insert(parts, kv_str)
      end

      return "{" .. concat(parts, ", ") .. "}"
   end

   local one_line = try_one_line(val)
   local current_indent = rep(" ", indent * initial_indent)

   -- if it fits on one line, use it (accounting for parent key)
   if #(current_indent .. one_line) + parent_key_len <= max_line_length then
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

   local inner_indent = rep(" ", indent * (initial_indent + 1))
   insert(parts, "{")

   -- add array elements
   for i = 1, array_len do
      local value = serialize_value(val[i], initial_indent + 1, 0)
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
	 key_str = fmt("[%s]", serialize_value(k, initial_indent + 1, 0))
      end
      local value = serialize_value(val[k], initial_indent + 1, #key_str + 1)
      insert(parts, inner_indent .. key_str .. "=" .. value .. ",")
   end

   insert(parts, current_indent .. "}")

   return concat(parts, "\n")
end

return M

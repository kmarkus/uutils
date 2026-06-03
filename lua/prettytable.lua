--- Pretty-printer for arbitrary Lua values.
--
-- Formats a value (typically a table) as valid, human readable Lua
-- source. Tables are kept on a single line when they fit within
-- `max_line_length`, and broken across indented lines otherwise.
--
-- @module prettytable
-- @author Markus Klotzbuecher <mk@mkio.de>
-- @license MIT
-- @usage
-- local pt = require("prettytable")
-- print(pt.tostr({a=1, b={2, 3}}, 80))

local M = {}

M.MAX_LINE_LENGTH = 100
M.INDENT = 2
M.INITIAL_INDENT = 0

local fmt, rep = string.format, string.rep
local insert, concat, sort = table.insert, table.concat, table.sort

--- Pretty print Lua values in a human readable way.
-- A table is printed on one line if possible; newlines are only
-- added when the resulting line would be longer than `max_line_length`.
-- @param val value to format
-- @param max_line_length maximum line length (default `M.MAX_LINE_LENGTH`)
-- @param initial_indent initial indentation depth (default `M.INITIAL_INDENT`)
-- @param indent number of spaces per indentation level (default `M.INDENT`)
-- @param keysort optional function to sort keys
-- @param parent_key_len length of parent key (for nested tables)
-- @return a string of valid Lua source representing val
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

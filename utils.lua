--
-- Useful code snips
-- some own ones, some collected from the lua wiki
--

local type, pairs, ipairs, setmetatable, getmetatable, assert, table, print, tostring, string, io, unpack =
   type, pairs, ipairs, setmetatable, getmetatable, assert, table, print, tostring, string, io, unpack

module('utils')

-- increment major on API breaks
-- increment minor on non breaking changes
VERSION=0.4

function append(car, ...)
   assert(type(car) == 'table')
   local new_array = {}

   for i,v in pairs(car) do
      table.insert(new_array, v)
   end
   for _, tab in ipairs(arg) do
      for k,v in pairs(tab) do
	 table.insert(new_array, v)
      end
   end
   return new_array
end

function tab2str( tbl )

   local function val_to_str ( v )
      if "string" == type( v ) then
	 v = string.gsub( v, "\n", "\\n" )
	 if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
	    return "'" .. v .. "'"
	 end
	 return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
      else
	 return "table" == type( v ) and tab2str( v ) or tostring( v )
      end
   end

   local function key_to_str ( k )
      if "string" == type( k ) and string.match( k, "^[_%a][_%a%d]*$" ) then
	 return k
      else
	 return "[" .. val_to_str( k ) .. "]"
      end
   end

   if type(tbl) ~= 'table' then return tostring(tbl) end

   local result, done = {}, {}
   for k, v in ipairs( tbl ) do
      table.insert( result, val_to_str( v ) )
      done[ k ] = true
   end
   for k, v in pairs( tbl ) do
      if not done[ k ] then
	 table.insert( result, key_to_str( k ) .. "=" .. val_to_str(v))
      end
   end
   return "{" .. table.concat( result, "," ) .. "}"
end

function pp(val)
   if type(val) == 'table' then print(tab2str(val)) 
   else print(val) end
end

function lpad(str, len, char)
   if char == nil then char = ' ' end
   return string.rep(char, len - #str) .. str
end

function rpad(str, len, char)
   if char == nil then char = ' ' end
   return str .. string.rep(char, len - #str)
end

function stderr(...)
   io.stderr:write(unpack(arg))
   io.stderr:write("\n")
end

function stdout(...)
   print(unpack(arg))
end

function split(str, pat)
   local t = {}  -- NOTE: use {n = 0} in Lua-5.0
   local fpat = "(.-)" .. pat
   local last_end = 1
   local s, e, cap = str:find(fpat, 1)
   while s do
      if s ~= 1 or cap ~= "" then
	 table.insert(t,cap)
      end
      last_end = e+1
      s, e, cap = str:find(fpat, last_end)
   end
   if last_end <= #str then
      cap = str:sub(last_end)
      table.insert(t, cap)
   end
   return t
end

-- basename("aaa") -> "aaa"
-- basename("aaa.bbb.ccc") -> "ccc"
function basename(n)
   if not string.find(n, '[\\.]') then
      return n
   else
      local t = utils.split(n, "[\\.]")
      return t[#t]
   end
end

function car(tab)
   return tab[1]
end

function cdr(tab)
   local new_array = {}
   for i = 2, table.getn(tab) do
      table.insert(new_array, tab[i])
   end
   return new_array
end

function cons(car, cdr)
   local new_array = {car}
  for _,v in cdr do
     table.insert(new_array, v)
  end
  return new_array
end

function flatten(t)
   function __flatten(res, t)
      if type(t) == 'table' then
	 for k,v in ipairs(t) do __flatten(res, v) end
      else
	 res[#res+1] = t
      end
      return res
   end

   return __flatten({}, t)
end

function deepcopy(object)
   local lookup_table = {}
   local function _copy(object)
      if type(object) ~= "table" then
	    return object
      elseif lookup_table[object] then
	 return lookup_table[object]
      end
      local new_table = {}
      lookup_table[object] = new_table
      for index, value in pairs(object) do
	 new_table[_copy(index)] = _copy(value)
      end
      return setmetatable(new_table, getmetatable(object))
   end
   return _copy(object)
end

function map(f, tab)
   local newtab = {}
   if tab == nil then return newtab end
   for i,v in pairs(tab) do
      local res = f(v,i)
      table.insert(newtab, res)
   end
   return newtab
end

function filter(f, tab)
   local newtab= {}
   if not tab then return newtab end
   for i,v in pairs(tab) do
      if f(v,i) then
	 table.insert(newtab, v)
      end
   end
   return newtab
end

function foreach(f, tab)
   if not tab then return end
   for i,v in pairs(tab) do f(v,i) end
end

function foldr(func, val, tab)
   if not tab then return val end
   for i,v in pairs(tab) do
      val = func(val, v)
   end
   return val
end

-- O' Scheme, where art thou?
-- turn operator into function
function AND(a, b) return a and b end

-- and which takes table
function andt(...)
   local res = true
   for _,t in ipairs(arg) do
      res = res and foldr(AND, true, t)
   end
   return res
end

function eval(str)
   return assert(loadstring(str))()
end

-- compare two tables
function table_cmp(t1, t2)
   local function __cmp(t1, t2)
      -- t1 _and_ t2 are not tables
      if not (type(t1) == 'table' and type(t2) == 'table') then
	 if t1 == t2 then return true
	 else return false end
      elseif type(t1) == 'table' and type(t2) == 'table' then
	 if #t1 ~= #t2 then return false
	 else
	    -- iterate over all keys and compare against k's keys
	    for k,v in pairs(t1) do
	       if not __cmp(t1[k], t2[k]) then
		  return false
	       end
	    end
	    return true
	 end
      else -- t1 and t2 are not of the same type
	 return false
      end
   end
   return __cmp(t1,t2) and __cmp(t2,t1)
end

function table_has(t, x)
   for _,e in ipairs(t) do
      if e==x then return true end
   end
   return false
end
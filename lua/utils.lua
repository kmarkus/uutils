--
-- Useful code snips
-- some own ones, some collected from the lua wiki
--
-- Permission is hereby granted, free of charge, to any person obtaining
-- a copy of this software and associated documentation files (the
-- "Software"), to deal in the Software without restriction, including
-- without limitation the rights to use, copy, modify, merge, publish,
-- distribute, sublicense, and/or sell copies of the Software, and to
-- permit persons to whom the Software is furnished to do so, subject to
-- the following conditions:
--
-- The above copyright notice and this permission notice shall be
-- included in all copies or substantial portions of the Software.
--
-- THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
-- EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES
-- OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
-- NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
-- HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
-- WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
-- FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
-- OTHER DEALINGS IN THE SOFTWARE.
--

local M = {}

-- increment major on API breaks
-- increment minor on non breaking changes
M.VERSION="2.1.0"

local pack = table.pack or function(...) return { n = select('#', ...), ... } end
local fmt = string.format

-- Immutable (ro)
-- strict (no-unitialized)

-- Seal a table immutable
-- @param t table to freeze
-- @param immutable if true, make the table immutable
-- @param strict if true, only allow access to existing keys
-- @return a new immutable version of t
-- the original table is not modified
function M.seal(t, immutable, strict)
   local function newindex_reject(_,k,_)
      error(fmt("attempt to set key '%s' in immutable table", k))
   end
   local function newindex_strict(_,k,v)
      if t[k] == nil then
	 error(fmt("attempt to assign non-existing key '%s' in strict table", k))
      end
      rawset(t, k, v)
   end
   local function index_strict(_, k)
      local r = t[k]
      if r == nil then
	 error(fmt("attempt to index non-existing key '%s' in strict table", k))
      end
      return r
   end
   local index, newindex
   if strict then
      index = index_strict
      newindex = newindex_strict
   end
   if immutable then
      newindex = newindex_reject
   end
   return setmetatable({}, {__index=index or t, __newindex=newindex})
end

function M.lock(t)
   return M.seal(t, true, true)
end

function M.append(car, ...)
   assert(type(car) == 'table')
   local new_array = {}

   for i,v in pairs(car) do
      table.insert(new_array, v)
   end
   for _, tab in ipairs({...}) do
      for _,v in pairs(tab) do
	 table.insert(new_array, v)
      end
   end
   return new_array
end

function M.tab2str( tbl )

   local function val_to_str ( v )
      if "string" == type( v ) then
	 v = string.gsub( v, "\n", "\\n" )
	 if string.match( string.gsub(v,"[^'\"]",""), '^"+$' ) then
	    return "'" .. v .. "'"
	 end
	 return '"' .. string.gsub(v,'"', '\\"' ) .. '"'
      else
	 return "table" == type( v ) and M.tab2str( v ) or tostring( v )
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

--- Wrap a long string.
-- source: http://lua-users.org/wiki/StringRecipes
-- @param str string to wrap
-- @param limit maximum line length
-- @param indent regular indentation
-- @param indent1 indentation of first line
function M.wrap(str, limit, indent, indent1)
   indent = indent or ""
   indent1 = indent1 or indent
   limit = limit or 72
   local here = 1-#indent1
   return indent1..str:gsub("(%s+)()(%S+)()",
			    function(sp, st, word, fi)
			       if fi-here > limit then
				  here = st - #indent
				  return "\n"..indent..word
			       end
			    end)
end


function M.pp(...)
   local vals = pack(...)
   local t = {}
   for i=1,vals.n do
      if type(vals[i]) == 'table' then t[#t+1] = M.tab2str(vals[i])
      else t[#t+1] = tostring(vals[i]) end
   end
   print(table.concat(t, ', '))
end

function M.lpad(str, len, char, strlen)
   strlen = strlen or #str
   if char == nil then char = ' ' end
   return string.rep(char, len - strlen) .. str
end

function M.rpad(str, len, char, strlen)
   strlen = strlen or #str
   if char == nil then char = ' ' end
   return str .. string.rep(char, len - strlen)
end

-- Trim functions: http://lua-users.org/wiki/CommonFunctions
-- Licensed under the same terms as Lua itself.--DavidManura
function M.trim(s)
   return (s:gsub("^%s*(.-)%s*$", "%1"))    -- from PiL2 20.4
end

-- remove leading whitespace from string.
function M.ltrim(s) return (s:gsub("^%s*", "")) end

-- remove trailing whitespace from string.
function M.rtrim(s)
   local n = #s
   while n > 0 and s:find("^%s", n) do n = n - 1 end
   return s:sub(1, n)
end

--- Strip ANSI color escape sequence from string.
-- @param str string
-- @return stripped string
-- @return number of replacements
function M.strip_ansi(str) return string.gsub(str, "\27%[%d+m", "") end

--- write the given table in a human readable form
-- rows (and headers) are arrays (dictionary entries are ignored)
-- @param fd file descriptor
-- @param hdrtab table of headers
-- @param tab table of row tables
-- @param opts table of addtional options
function M.write_table(fd, hdrtab, tab, opts)
   local cntpad
   opts = opts or {count=true}
   if opts.count then cntpad = #(tostring(#tab))+2 else cntpad = 0 end
   -- write row table values and pad with value from corresponding pad tab
   local function clean(x) return M.strip_ansi(tostring(x)) end
   local function write_row(i, row, colpad)
      i = i or " "
      i=M.rpad(tostring(i), cntpad)

      local r_padded =
	 M.imap(
	    function(x,i)
	       return M.rpad(tostring(x), colpad[i]+1, ' ', #clean(x))
	    end, row)

      fd:write(i .. table.concat(r_padded, " ") ..'\n')
   end

   local maxlens = M.imap(string.len, hdrtab)

   for _,row in ipairs(tab) do
      for i=1,#maxlens-1 do
	 if #clean(row[i]) > maxlens[i] then maxlens[i] = #clean(row[i]) end
      end
   end

   write_row(nil, hdrtab, maxlens)

   if opts.count then
      for i,r in ipairs(tab) do write_row(i, r, maxlens) end
   else
      for _,r in ipairs(tab) do write_row(nil, r, maxlens) end
   end
end

--- Convert a array of dictionaries into header and rows
-- the output can be directly fed to write_table
-- @param t a table of tables
-- @return hdr and rows tables
function M.tabulate(t, hdr)
   local rows = {}
   hdr = hdr or {}

   -- use first row to extract the hdr fields
   if #hdr == 0 then
      for k,_ in pairs(t[1]) do hdr[#hdr+1] = k end
      table.sort(hdr)
   end

   for _,row in ipairs(t) do
      local newrow = {}
      for _,h in ipairs(hdr) do
	 newrow[#newrow+1] = row[h]
      end
      rows[#rows+1] = newrow
   end
   return hdr, rows
end

--- Convert string to string of fixed lenght.
-- Will either pad with whitespace if too short or will cut of tail if
-- too long. If dots is true add '...' to truncated string.
-- @param str string
-- @param len lenght to set to.
-- @param dots boolean, if true append dots to truncated strings.
-- @return processed string.
function M.strsetlen(str, len, dots)
   if string.len(str) > len and dots then
      return string.sub(str, 1, len - 4) .. "... "
   elseif string.len(str) > len then
      return string.sub(str, 1, len)
   else return M.rpad(str, len, ' ') end
end

function M.stderr(...)
   io.stderr:write(...)
   io.stderr:write("\n")
end

function M.stdout(...)
   print(...)
end

function M.split(str, pat)
   assert(pat, "missing arg2: expected pattern")
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
function M.basename(n)
   if not string.find(n, '[\\.]') then
      return n
   else
      local t = M.split(n, "[\\.]")
      return t[#t]
   end
end

function M.car(tab)
   return tab[1]
end

function M.cdr(tab)
   local new_array = {}
   for i = 2, #tab do
      table.insert(new_array, tab[i])
   end
   return new_array
end

function M.cons(car, cdr)
   local new_array = {car}
  for _,v in cdr do
     table.insert(new_array, v)
  end
  return new_array
end

function M.flatten(t)
   local function __flatten(res, t)
      if type(t) == 'table' then
	 for k,v in ipairs(t) do __flatten(res, v) end
      else
	 res[#res+1] = t
      end
      return res
   end

   return __flatten({}, t)
end

function M.deepcopy(object)
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

function M.imap(f, tab)
   local newtab = {}
   if tab == nil then return newtab end
   for i,v in ipairs(tab) do
      local res = f(v,i)
      newtab[#newtab+1] = res
   end
   return newtab
end

function M.map(f, tab)
   local newtab = {}
   if tab == nil then return newtab end
   for i,v in pairs(tab) do
      local res = f(v,i)
      table.insert(newtab, res)
   end
   return newtab
end

function M.filter(f, tab)
   local newtab= {}
   if not tab then return newtab end
   for i,v in pairs(tab) do
      if f(v,i) then
	 table.insert(newtab, v)
      end
   end
   return newtab
end

function M.foreach(f, tab)
   if not tab then return end
   for i,v in pairs(tab) do f(v,i) end
end

function M.foldr(func, val, tab)
   if not tab then return val end
   for i,v in pairs(tab) do
      val = func(val, v, i)
   end
   return val
end

--- Fill a table with num val's
-- @param val value
-- @param num number
-- @param table of num val's
function M.fill(val, num)
   local res = {}
   for i=1,num do res[i] = M.deepcopy(val) end
   return res
end

--- Count the number of elements in a table
-- this counts both dict and array parts
-- @param x table
-- @return number of values in x
function M.num_elem(x)
   local n = 0
   for _,_ in pairs(x) do n = n + 1 end
   return n
end

--- Pre-order tree traversal.
-- @param fun function to apply to each node
-- @param root root to start from
-- @param pred predicate that nodes must be satisfied for function application.
-- @return table of return values
function M.maptree(fun, root, pred)
   local res = {}
   local function __maptree(tab)
      M.foreach(function(v, k)
		 if not pred or pred(v, tab, k) then
		    res[#res+1] = fun(v, tab, k)
		 end
		 if type(v) == 'table' then __maptree(v) end
	      end, tab)
   end
   __maptree(root)
   return res
end

-- O' Scheme, where art thou?
-- turn operator into function
function M.AND(a, b) return a and b end

-- and which takes table
function M.andt(...)
   local res = true
   local tab = {...}
   for _,t in ipairs(tab) do
      res = res and M.foldr(AND, true, t)
   end
   return res
end

function M.eval(str)
   local l = load or loadstring -- 5.1 backward compat
   return assert(l(str))()
end

function M.unrequire(m)
   package.loaded[m] = nil
   _G[m] = nil
end

-- Compare two values (potentially recursively).
-- @param t1 value 1
-- @param t2 value 2
-- @return true if the same, false otherwise.
function M.table_cmp(t1, t2)
   local function __cmp(t1, t2)
      -- t1 _and_ t2 are not tables
      if type(t1) ~= 'table' and type(t2) ~= 'table' then
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

function M.table_has(t, x)
   for _,e in ipairs(t) do
      if e==x then return true end
   end
   return false
end

--- Return a new table with unique elements.
function M.table_unique(t)
   local res = {}
   for i,v in ipairs(t) do
      if not M.table_has(res, v) then res[#res+1]=v end
   end
   return res
end

--- Merge two tables
-- @param a first table
-- @param b second table
-- @return a new table with a and b merged
-- in case of duplicate elements, the value of a is taken
function M.table_merge(a, b)
   assert(type(a) == 'table' and type(b) == 'table', "invalid arguments")

   local r = M.deepcopy(b)

   for k,v in pairs(a) do
      if type(v)=='table' and type(r[k])=='table' then
         r[k] = M.table_merge(v, r[k])
      else
         r[k] = v
      end
   end

   return r
end


--- Convert arguments list into key-value pairs.
-- The return table is indexable by parameters (i.e. ["-p"]) and the
-- value is an array of zero to many option parameters.
-- @param standard Lua argument table
-- @return key-value table
function M.proc_args(args)
   local function is_opt(s) return string.sub(s, 1, 1) == '-' end
   local res = { [0]={} }
   local last_key = 0
   for i=1,#args do
      if is_opt(args[i]) then -- new key
	 last_key = args[i]
	 res[last_key] = {}
      else -- option parameter, append to existing tab
	 local list = res[last_key]
	 list[#list+1] = args[i]
      end
   end
   return res
end

--- Simple advice functionality
-- If oldfun is not nil then returns a closure that invokes both
-- oldfun and newfun. If newfun is called before or after oldfun
-- depends on the where parameter, that can take the values of
-- 'before' or 'after'.
-- If oldfun is nil, newfun is returned.
-- @param where string <code>before</code>' or <code>after</code>
-- @param oldfun (can be nil)
-- @param newfunc
function M.advise(where, oldfun, newfun)
   assert(where == 'before' or where == 'after',
	  "advise: Invalid value " .. tostring(where) .. " for where")

   if oldfun == nil then return newfun end

   if where == 'before' then
      return function (...) newfun(...); oldfun(...); end
   else
      return function (...) oldfun(...); newfun(...); end
   end
end

--- Check wether a file exists.
-- @param fn filename to check.
-- @return true or false
function M.file_exists(fn)
   local f=io.open(fn);
   if f then io.close(f); return true end
   return false
end

--- From Book  "Lua programming gems", Chapter 2, pg. 26.
function M.memoize (f)
   local mem = {}			-- memoizing table
   setmetatable(mem, {__mode = "kv"})	-- make it weak
   return function (x)			-- new version of ’f’, with memoizing
	     local r = mem[x]
	     if r == nil then	-- no previous result?
		r = f(x)	-- calls original function
		mem[x] = r	-- store result for reuse
	     end
	     return r
	  end
end

--- call thunk every s+ns seconds.
function M.gen_do_every(s, ns, thunk, gettime)
   local next = { sec=0, nsec=0 }
   local cur = { sec=0, nsec=0 }
   local inc = { sec=s, nsec=ns }

   if not type(time) == 'table' then
      error ("gen_do_every requires the time module")
   end
   return function()
	     cur.sec, cur.nsec = gettime()

	     if time.cmp(cur, next) == 1 then
		thunk()
		next.sec, next.nsec = time.add(cur, inc)
	     end
	  end
end

--- Expand parameters in string template.
-- @param tpl string containing $NAME parameters.
-- @param params table of NAME=value pairs for substitution.
-- @return expanded template string
-- @return array of unexpanded parameters
function M.expand(tpl, params, warn)
   local unexp = {}

   for name,val in pairs(params) do
      tpl=string.gsub(tpl, "%$"..name, val)
   end

   -- check for unexpanded
   for name in tpl:gmatch("%$([%w_]+)") do
      unexp[#unexp+1] = name
   end

   return tpl, unexp
end

--- Execute command
-- @param cmd command to execute
-- @return res output of command without newline
-- @return status true if succesfull or false if error
-- @return 'exit' or 'signal'
-- @return return value or signal that killed cmd
function M.exec(cmd)
   local f = io.popen(cmd)
   local res = string.gsub(f:read("*a"), '\n$', '')
   return res, f:close()
end

local function pcall_bt(func, ...)
   return xpcall(func, debug.traceback, ...)
end

--- Evaluate a chunk of code in a constrained environment.
-- @param unsafe_code code string
-- @param optional environment table.
-- @return true or false depending on success
-- @return function or error message
function M.eval_sandbox(unsafe_code, env)
   env = env or {}
   local unsafe_fun, msg = load(unsafe_code, nil, 't', env)
   if not unsafe_fun then return false, msg end
   return pcall_bt(unsafe_fun)
end


--- Preprocess the given string.
-- Lines starting with @ are executed as Lua code
-- Other lines are passed through verbatim, except those contained in
-- $(...) which are evaluated and the result inserted.
--
-- Adapted from: http://lua-users.org/wiki/SimpleLuaPreprocessor
--
-- @param str string to preprocess
-- @param env environment for sandbox (default {})
-- @param verbose print verbose error message in case of failure
-- @return preprocessed result.
function M.preproc(str, env, verbose)
   local chunk = {"__res={}\n" }
   local lines = M.split(str, "\n")

   env["__concat__"] = table.concat

   for _,line in ipairs(lines) do
      -- line = trim(line)
      local s,e = string.find(line, "^%s*@")
      if s then
	 chunk[#chunk+1] = string.sub(line, e+1) .. "\n"
      else
	 local last = 1
	 for text, expr, index in string.gmatch(line, "(.-)$(%b())()") do
	    last = index
	    if text ~= "" then
	       -- write part before expression
	       chunk[#chunk+1] = string.format('__res[#__res+1] = %q\n ', text)
	    end
	    -- write expression
	    chunk[#chunk+1] = string.format('__res[#__res+1] = %s\n', expr)
	 end
	 -- write remainder of line (without further $()
	 chunk[#chunk+1] = string.format('__res[#__res+1] = %q\n', string.sub(line, last).."\n")
      end
   end
   chunk[#chunk+1] = "return __concat__(__res, '')\n"
   local ret, str = M.eval_sandbox(table.concat(chunk), env)
   if not ret and verbose then
      print("preproc failed: start of error report")
      local code_dump = table.concat(chunk)
      for i,l in ipairs(M.split(code_dump, "\n")) do
	 print(tostring(i)..":\t"..string.format("%q", l))
      end
      print(str.."\npreproc failed: end of error message")
   end
   return ret, str
end

--- Convert a string to a hex representation of a string.
-- @param str string to convert
-- @param space space between values (default: "")
-- @return hex string
function M.str_to_hexstr(str,spacer)
   return string.lower(
      (string.gsub(str,"(.)",
		   function (c)
		      return string.format("%02X%s",string.byte(c), spacer or "")
		   end ) ) )
end

--- Return the maximum of two numbers
-- @param x1
-- @param x2
-- @return the maximum
function M.max(x1, x2) if x1>x2 then return x1; else return x2; end end

--- Return the minimum of two numbers
-- @param x1
-- @param x2
-- @return the minimum
function M.min(x1, x2) if x1>x2 then return x2; else return x1; end end

return M

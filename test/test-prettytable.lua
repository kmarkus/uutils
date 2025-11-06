local lu = require('luaunit')
local pretty = require('prettytable')

TestPrettyTable = {}

-- Helper function to load serialized table back
local function deserialize(str)
   local func, err = load("return " .. str)
   if not func then
      error("Failed to deserialize: " .. err)
   end
   return func()
end

function TestPrettyTable:test_simple_values()
   lu.assertEquals(pretty.tostr(42), "42")
   lu.assertEquals(pretty.tostr("hello"), "hello")
   lu.assertEquals(pretty.tostr(true), "true")
   lu.assertEquals(pretty.tostr(nil), "nil")
end

function TestPrettyTable:test_empty_table()
   local t = {}
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_simple_array()
   local t = {1, 2, 3, 4, 5}
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_array_with_strings()
   local t = {"apple", "banana", "cherry"}
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_array_with_mixed_types()
   local t = {1, "two", 3.14, true, false}
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_simple_dict()
   local t = {name = "John", age = 30, city = "NYC"}
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_dict_with_various_types()
   local t = {
      str = "value",
      num = 42,
      float = 3.14,
      bool_true = true,
      bool_false = false
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_mixed_array_and_dict()
   local t = {
      "first",
      "second",
      "third",
      name = "Mixed",
      count = 3
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_nested_tables_depth_2()
   local t = {
      person = {
         name = "Alice",
         age = 25
      },
      scores = {90, 85, 95}
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_nested_tables_depth_3()
   local t = {
      company = {
         name = "TechCorp",
         employees = {
            {name = "Bob", role = "Dev"},
            {name = "Carol", role = "Designer"}
         },
         location = {
            city = "SF",
            country = "USA"
         }
      }
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_deeply_nested_arrays()
   local t = {
      {
         {1, 2, 3},
         {4, 5, 6}
      },
      {
         {7, 8, 9},
         {10, 11, 12}
      }
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_special_string_characters()
   local t = {
      quote = 'He said "hello"',
      newline = "Line1\nLine2",
      tab = "Col1\tCol2",
      backslash = "path\\to\\file"
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_keys_with_special_chars()
   local t = {
      ["key with spaces"] = "value1",
      ["key-with-dashes"] = "value2",
      ["123numeric"] = "value3"
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_numeric_keys()
   local t = {
      [1] = "one",
      [2] = "two",
      [10] = "ten",
      [100] = "hundred"
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_mixed_numeric_and_string_keys()
   local t = {
      [1] = "first",
      [2] = "second",
      name = "test",
      [5] = "fifth",
      type = "mixed"
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_max_line_length_short()
   local t = {a = 1, b = 2, c = 3, d = 4, e = 5, f = 6, g = 7}
   local serialized = pretty.tostr(t, 30, 0)
   -- Should use multiple lines due to short max_line_length
   lu.assertTrue(serialized:match("\n") ~= nil)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_max_line_length_long()
   local t = {a = 1, b = 2, c = 3}
   local serialized = pretty.tostr(t, 200, 0)
   -- Should fit on one line with long max_line_length
   lu.assertTrue(serialized:match("\n") == nil)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_complex_real_world_example()
   local t = {
      config = {
         server = {
            host = "localhost",
            port = 8080,
            ssl = true
         },
         database = {
            type = "postgres",
            connection = {
               host = "db.example.com",
               port = 5432,
               credentials = {
                  user = "admin",
                  password = "secret123"
               }
            }
         },
         features = {"auth", "logging", "caching"}
      },
      status = "active",
      version = "1.2.3"
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_array_with_nested_dicts()
   local t = {
      {name = "Item1", value = 10},
      {name = "Item2", value = 20},
      {name = "Item3", value = 30}
   }
   local serialized = pretty.tostr(t)
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

function TestPrettyTable:test_custom_key_sort()
   local t = {zebra = 1, apple = 2, mango = 3}
   local serialized = pretty.tostr(t, 80, 0, 2, function(a, b)
      return tostring(a) > tostring(b)  -- reverse sort
   end)
   -- Just verify it deserializes correctly
   local result = deserialize(serialized)
   lu.assertEquals(result, t)
end

-- Run tests
os.exit(lu.LuaUnit.run())

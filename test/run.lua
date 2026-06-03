#!/usr/bin/env lua

local lu = require("luaunit")

-- aggregate all test suites
TestUtils = require("test-utils")
TestTime = require("test-time")
TestPrettyTable = require("test-prettytable")

local runner = lu.LuaUnit.new()

os.exit( runner:runSuite() )

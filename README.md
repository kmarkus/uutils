# uutils

A small collection of frequently used, **pure Lua** modules. No C
dependencies, compatible with **Lua 5.1 – 5.5** (and LuaJIT).

## Modules

| Module        | Description                                                                                   |
|---------------|-----------------------------------------------------------------------------------------------|
| `utils`       | Miscellaneous string handling, formatting, table and functional-programming helpers.          |
| `time`        | `sys/time.h`-like precision time arithmetic on `{sec, nsec}` timespecs. Useful together with the [rtp](https://github.com/kmarkus/rtp) module. |
| `prettytable` | Format any Lua value as compact, human-readable Lua source, wrapping to newlines past a maximum line length. |
| `strict`      | Catch accidental use of undeclared global variables.                                          |
| `ansicolors`  | Tiny helper for ANSI terminal colors.                                                         |

## Requirements

- Lua 5.1, 5.2, 5.3, 5.4 or 5.5 (or LuaJIT)
- [luaunit](https://github.com/bluebird75/luaunit) — only to run the test suite
- [ldoc](https://github.com/lunarmodules/LDoc) — only to (re)build the API docs

## Installation

```sh
make install                       # installs into /usr/share/lua/<ver>/
make install luamod_prefix=/opt/lua
make install DESTDIR=/tmp/stage     # staged install (packaging)
```

`make install` copies every module into the per-version Lua module
directory for each version listed in `LUA_VERSIONS` (default `5.1 5.2
5.3 5.4 5.5`). Use `make uninstall` to remove them.

## Usage

```lua
local utils = require("utils")

-- pretty-print arbitrary values
print(utils.tab2str({1, 2, foo = "bar"}))      --> {1,2,foo="bar"}

-- functional helpers
utils.imap(function(x) return x * 2 end, {1, 2, 3})   --> {2, 4, 6}
utils.filter(function(x) return x % 2 == 0 end, {1, 2, 3, 4})  --> {2, 4}

-- recursive table comparison with a diff message
local equal, msg = utils.table_cmp({a = 1}, {a = 2})
print(equal, msg)        --> false   .a values differ: 1 != 2

-- string templating ($NAME substitution)
local out, missing = utils.expand("Hello $WHO", {WHO = "World"})
print(out)               --> Hello World
```

```lua
local time = require("time")

-- timespec arithmetic, results are normalized (sec, nsec)
print(time.add({sec = 0, nsec = 800000000}, {sec = 0, nsec = 600000000}))  --> 1  400000000
print(time.cmp({sec = 1, nsec = 0}, {sec = 2, nsec = 0}))      --> -1
```

```lua
local pt = require("prettytable")

print(pt.tostr({a = 1, b = {2, 3}, name = "demo"}, 80))
--> {a=1, b={2, 3}, name="demo"}
```

See `examples.org` for more worked examples (`seal`, `expand`, `preproc`).

## Tests

The test suite uses [luaunit](https://github.com/bluebird75/luaunit).
`test/run.lua` aggregates every suite and `make test` runs it against
each installed Lua version:

```sh
make test                          # all suites against every installed Lua version
make test LUA_VERSIONS="5.4 5.5"   # restrict to specific versions
make test LUAUNIT=/path/to/luaunit # point at a luaunit source checkout
```

If luaunit is not installed for some Lua version, set `LUAUNIT` to a
luaunit source tree; it is added to the `LUA_PATH` as a fallback. You
can also run the suite directly:

```sh
LUA_PATH="./lua/?.lua;./test/?.lua;;" lua5.4 test/run.lua
```

## Documentation

API documentation is generated from the in-source
[ldoc](https://github.com/lunarmodules/LDoc) comments:

```sh
make doc        # writes HTML into docs/
```

## License

MIT (see `License`). `ansicolors` is © Rob Hoelz and `time` is
BSD-3-Clause; see the file headers for details.

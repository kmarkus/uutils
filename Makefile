luamod_prefix=/usr/share/lua

# Lua versions to install for and to run the test suite against.
LUA_VERSIONS = 5.1 5.2 5.3 5.4 5.5

# luaunit must be resolvable: either installed system-wide or via a source
# checkout pointed to by LUAUNIT (used as a fallback on the LUA_PATH).
LUAUNIT ?= $(HOME)/src/git/lua/luaunit
LUA_PATH_TEST = ./lua/?.lua;./test/?.lua;$(LUAUNIT)/?.lua;;

MODULES = strict ansicolors utils time prettytable

default:
	@echo "Targets:"
	@echo "  make install     install Lua modules (override luamod_prefix/DESTDIR)"
	@echo "  make uninstall   remove installed modules"
	@echo "  make test        run the test suite against $(LUA_VERSIONS)"
	@echo "  make doc         generate API documentation with ldoc"
	@echo "  make clean       remove generated files"

# Run the whole test suite (via test/run.lua) against every available
# Lua version. Versions that are not installed are skipped with a notice.
test:
	@fail=0; \
	for v in $(LUA_VERSIONS); do \
		lua=lua$$v; \
		command -v $$lua >/dev/null 2>&1 || { echo "-- $$lua not found, skipping"; continue; }; \
		echo "== $$lua test/run.lua =="; \
		LUA_PATH="$(LUA_PATH_TEST)" $$lua test/run.lua || fail=1; \
	done; \
	exit $$fail

doc:
	ldoc .

clean:
	rm -f *~
	rm -rf docs

install:
	@for v in $(LUA_VERSIONS); do \
		dir="${DESTDIR}/${luamod_prefix}/$$v"; \
		install -d -m 755 "$$dir"; \
		install -m 644 lua/*.lua "$$dir"; \
	done

uninstall:
	@for m in $(MODULES); do \
		rm -f ${DESTDIR}/${luamod_prefix}/*/$$m.lua; \
	done

.PHONY: default test doc clean install uninstall


luamod_prefix=/usr/share/lua

default:
	@echo "run make install to install Lua modules"

clean:
	rm -f *~

install:
	@install  lua/*.lua ${luamod_prefix}/5.1/
	@install  lua/*.lua ${luamod_prefix}/5.2/
	@install  lua/*.lua ${luamod_prefix}/5.3/

uninstall:
	@rm -f ${luamod_prefix}/*/utils.lua
	@rm -f ${luamod_prefix}/*/time.lua
	@rm -f ${luamod_prefix}/*/strict.lua
	@rm -f ${luamod_prefix}/*/ansicolors.lua

PHONY: install

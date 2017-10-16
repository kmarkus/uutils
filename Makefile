
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
	@rm -f ${luamod_prefix}/5.1/utils.lua ${luamod_prefix}/5.1/strict.lua ${luamod_prefix}/5.1/time.lua
	@rm -f ${luamod_prefix}/5.2/utils.lua ${luamod_prefix}/5.2/strict.lua ${luamod_prefix}/5.2/time.lua
	@rm -f ${luamod_prefix}/5.3/utils.lua ${luamod_prefix}/5.3/strict.lua ${luamod_prefix}/5.3/time.lua

PHONY: install

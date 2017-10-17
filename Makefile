
luamod_prefix=/usr/share/lua

default:
	@echo "run make install to install Lua modules"

clean:
	rm -f *~

install:
	@install  lua/*.lua ${DESTDIR}/${luamod_prefix}/5.1/
	@install  lua/*.lua ${DESTDIR}/${luamod_prefix}/5.2/
	@install  lua/*.lua ${DESTDIR}/${luamod_prefix}/5.3/

uninstall:
	@rm -f ${DESTDIR}/${luamod_prefix}/*/utils.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/time.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/strict.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/ansicolors.lua

PHONY: install

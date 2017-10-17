
luamod_prefix=/usr/share/lua

default:
	@echo "run make install to install Lua modules"

clean:
	rm -f *~

install:
	@install -d -m 755 ${DESTDIR}/${luamod_prefix}/5.1/
	@install -m 644 lua/*.lua ${DESTDIR}/${luamod_prefix}/5.1/

	@install -d -m 755 ${DESTDIR}/${luamod_prefix}/5.2/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/strict.lua ${DESTDIR}/${luamod_prefix}/5.2/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/ansicolors.lua ${DESTDIR}/${luamod_prefix}/5.2/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/utils.lua ${DESTDIR}/${luamod_prefix}/5.2/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/time.lua ${DESTDIR}/${luamod_prefix}/5.2/

	@install -d -m 755 ${DESTDIR}/${luamod_prefix}/5.3/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/strict.lua ${DESTDIR}/${luamod_prefix}/5.3/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/ansicolors.lua ${DESTDIR}/${luamod_prefix}/5.3/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/utils.lua ${DESTDIR}/${luamod_prefix}/5.3/
	@ln -sr ${DESTDIR}/${luamod_prefix}/5.1/time.lua ${DESTDIR}/${luamod_prefix}/5.3/


uninstall:
	@rm -f ${DESTDIR}/${luamod_prefix}/*/utils.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/time.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/strict.lua
	@rm -f ${DESTDIR}/${luamod_prefix}/*/ansicolors.lua

PHONY: install

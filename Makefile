Version=16.06-devel

PREFIX = /usr/local

BIN = \
	bin/cli-installer \
	bin/km \
	bin/lg

LIBS = \
	lib/util-inst.sh \
	lib/util-mnt.sh

SHARED = \
	data/km-en.lng \
	data/lg-en.lng \
	data/cli-installer-en.lng

LAUNCHER = \
	data/cli-installer.desktop

all: $(BIN)

edit = sed -e "s|@datadir[@]|$(DESTDIR)$(PREFIX)/share/manjaro-tools|g" \
	-e "s|@libdir[@]|$(DESTDIR)$(PREFIX)/lib/manjaro-tools|g" \
	-e "s|@VER@|${Version}|"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@m4 -P $@.in | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"

clean:
	rm -f $(BIN)

install:
	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN} $(DESTDIR)$(PREFIX)/bin

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/manjaro-tools
	install -m0644 ${LIBS} $(DESTDIR)$(PREFIX)/lib/manjaro-tools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/manjaro-tools
	install -m0644 ${SHARED} $(DESTDIR)$(PREFIX)/share/manjaro-tools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/applications
	install -m0644 ${LAUNCHER} $(DESTDIR)$(PREFIX)/share/applications


uninstall:
	for f in ${BIN}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${SHARED}; do rm -f $(DESTDIR)$(PREFIX)/share/manjaro-tools/$$f; done
	for f in ${LIBS}; do rm -f $(DESTDIR)$(PREFIX)/lib/manjaro-tools/$$f; done
	for f in ${LAUNCHER}; do rm -f $(DESTDIR)$(PREFIX)/share/applications/$$f; done

install: install

uninstall: uninstall

dist:
	git archive --format=tar --prefix=manjaro-cli-installer-$(Version)/ $(Version) | gzip -9 > manjaro-cli-installer-$(Version).tar.gz
	gpg --detach-sign --use-agent manjaro-cli-installer-$(Version).tar.gz

.PHONY: all clean install uninstall dist

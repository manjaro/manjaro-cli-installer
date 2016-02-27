Version=16.06

PREFIX = /usr/local
SYSCONFDIR = /etc

SYSCONF = \
	data/cli-installer.conf

BIN = \
	bin/setup \
	bin/km \
	bin/lg

LIBS = \
	lib/util-inst.sh \
	lib/util-mnt.sh

SHARED = \
	data/installer-launcher-cli.desktop \
	data/km-en.lng \
	data/lg-en.lng \
	data/setup-en.lng

all: $(BIN_BASE) $(BIN_PKG) $(BIN_ISO) doc

edit = sed -e "s|@datadir[@]|$(DESTDIR)$(PREFIX)/share/manjaro-tools|g" \
	-e "s|@sysconfdir[@]|$(DESTDIR)$(SYSCONFDIR)/manjaro-tools|g" \
	-e "s|@libdir[@]|$(DESTDIR)$(PREFIX)/lib/manjaro-tools|g" \
	-e "s|@version@|${Version}|"

%: %.in Makefile
	@echo "GEN $@"
	@$(RM) "$@"
	@m4 -P $@.in | $(edit) >$@
	@chmod a-w "$@"
	@chmod +x "$@"

clean:
	rm -f $(BIN)
	rm -rf man

install:
	install -dm0755 $(DESTDIR)$(SYSCONFDIR)/manjaro-tools
	install -m0644 ${SYSCONF} $(DESTDIR)$(SYSCONFDIR)/manjaro-tools

	install -dm0755 $(DESTDIR)$(PREFIX)/bin
	install -m0755 ${BIN_BASE} $(DESTDIR)$(PREFIX)/bin

	install -dm0755 $(DESTDIR)$(PREFIX)/lib/manjaro-tools
	install -m0644 ${LIBS_BASE} $(DESTDIR)$(PREFIX)/lib/manjaro-tools

	install -dm0755 $(DESTDIR)$(PREFIX)/share/manjaro-tools
	install -m0644 ${SHARED_BASE} $(DESTDIR)$(PREFIX)/share/manjaro-tools


uninstall_base:
	for f in ${SYSCONF}; do rm -f $(DESTDIR)$(SYSCONFDIR)/manjaro-tools/$$f; done
	for f in ${BIN_BASE}; do rm -f $(DESTDIR)$(PREFIX)/bin/$$f; done
	for f in ${SHARED_BASE}; do rm -f $(DESTDIR)$(PREFIX)/share/manjaro-tools/$$f; done
	for f in ${LIBS_BASE}; do rm -f $(DESTDIR)$(PREFIX)/lib/manjaro-tools/$$f; done

install: install

uninstall: uninstall

dist:
	git archive --format=tar --prefix=manjaro-cli-installer-$(Version)/ $(Version) | gzip -9 > manjaro-cli-installer-$(Version).tar.gz
	gpg --detach-sign --use-agent manjaro-cli-installer-$(Version).tar.gz

.PHONY: all clean install uninstall dist

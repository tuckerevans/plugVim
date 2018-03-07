PREFIX ?= /usr/local
BINDIR ?= $(PREFIX)/bin
MANSUB ?= share/man
MANDIR ?= $(PREFIX)/$(MANSUB)

install:
	cp src/plug.sh $(BINDIR)/plug
	cp man/plug.1 $(MANDIR)/

uninstall:
	rm -f $(BINDER)/plug
	rm -f $(MANDIR)/plug.1

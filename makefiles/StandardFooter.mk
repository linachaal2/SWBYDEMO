all: default

clean:
	-@rm -f $(OFILES)
	-@rm -f $(LIBNAME).a
	-@rm -f $(LIBNAME)$(SHLIBEXT)
	-@rm -f $(APPNAME)

debug: all

install: all INSTALL-SOFTWARE

dinstall: all INSTALL-SOFTWARE

nodebug:
	$(MAKE) DEBUG=-O

hinstall: $(IFILES)
	@if [ -n "$(IFILES)" ]; then \
	    $(INSTALL) $(INCMODE) $(LESDIR)/include $?; \
	fi

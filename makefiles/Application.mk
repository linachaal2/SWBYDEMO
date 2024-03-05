VPATH=.:$(LESDIR)/lib

include $(LESDIR)/makefiles/ApplicationLibs.mk

default: $(APPNAME)

$(APPNAME): $(OFILES)
	$(CC) $(CFLAGS) $(LDFLAGS) $(OFILES) $(LIBS) $(LIBOPTS) -o $@

INSTALL-SOFTWARE:
	$(INSTALL) $(APPMODE) $(BINDIR) $(APPNAME)


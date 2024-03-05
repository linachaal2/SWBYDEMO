include $(LESDIR)/makefiles/ComponentLibs.mk

default: $(LIBNAME)

INSTALL-SOFTWARE:
	$(INSTALL) $(LIBMODE) $(LIBDIR) $(LIBNAME)$(SHLIBEXT)

$(LIBNAME): $(OFILES)
	$(LD) $(SHLDFLAGS) $(OFILES) $(LIBS) -lc -o $(LIBNAME)$(SHLIBEXT)

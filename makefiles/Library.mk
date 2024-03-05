include $(LESDIR)/makefiles/LibraryLibs.mk

default: $(LIBNAME)

INSTALL-SOFTWARE:
	$(INSTALL) $(LIBMODE) $(LIBDIR) $(LIBNAME)$(SHLIBEXT) $(LIBNAME).a

$(LIBDEPEND) dummy:
	-@for i in `ls $(LESDIR)/src/libsrc/$@/*.o`; do \
		rm -f `basename $$i`; \
	done
	ln -sf $(LESDIR)/src/libsrc/$@/*.o .

$(OFILES):

$(LIBNAME).static: $(OFILES)
	ar r $(LIBNAME).a $(OFILES)
	$(RANLIB) $(LIBNAME).a

$(LIBNAME): $(LIBDEPEND) $(LIBNAME).static
	$(LD) $(SHLDFLAGS) $(OFILES) $(LIBS) -lc -o $(LIBNAME)$(SHLIBEXT)

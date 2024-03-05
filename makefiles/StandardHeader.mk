#
# Global makefile header
#
# Prior to using,
#  $SHELL must be /bin/ksh
#  $PATH must include /bin:/usr/bin
#

DEBUG=-g

####################################################################
# Next Section: Directories, scripts, modes...
####################################################################
INSTALL=$(LESDIR)/scripts/Install

DATMODE=444
INCMODE=444
LIBMODE=555
APPMODE=755

INCDIR=$(LESDIR)/include
LIBDIR=$(LESDIR)/lib
BINDIR=$(LESDIR)/bin

####################################################################
# Next Section: Platform specific definitions...
####################################################################

include $(LESDIR)/makefiles/Config.mk

INCLUDES=-I. \
	 -I$(LESDIR)/include \
	 -I$(DCSDIR)/include \
	 -I$(MCSDIR)/include \
	 -I$(MOCADIR)/include \
	 -I$(SALDIR)/include \
	 -I$(SLDIR)/include 

LDFLAGS=$(LDOPTS) $(EXTRALDFLAGS) \
	-L$(LESDIR)/lib \
	-L$(DCSDIR)/lib \
	-L$(MCSDIR)/lib \
	-L$(MOCADIR)/lib \
	-L$(SALDIR)/lib \
	-L$(SLDIR)/lib 

SHLDFLAGS=$(SHLDOPTS) $(EXTRALDFLAGS) \
	  -L$(LESDIR)/lib \
	  -L$(DCSDIR)/lib \
	  -L$(MCSDIR)/lib \
	  -L$(MOCADIR)/lib \
	  -L$(SALDIR)/lib \
	  -L$(SLDIR)/lib

CFLAGS=$(WARN) $(DEBUG) $(DEFINES) \
	$(DBINCLUDES) $(INCLUDES) $(OPTIONS) $(EXTRACFLAGS)

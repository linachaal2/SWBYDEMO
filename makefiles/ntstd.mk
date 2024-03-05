###########################################################################
#
# Standard LES makefile for the Windows x86 platform.
#
###########################################################################

!ifndef NODEBUG
DEBUG=d
DEBUGFLAG=-Zi -Fd$(TARGET).pdb
LINKDEBUG=-debug -PDB:$(TARGET).pdb
!else
DEBUGFLAG=-O2
!endif

!ifdef MAPFILE
MAPFLAG=-map
!endif

# If this is a release, add the version string
RELFLAGS=-DRELEASE_VERSION="\"$(RELVERSION)\""

WARNFLAG=-W3

.SUFFIXES : .cpp

CFLAGS=-nologo -MD -DWIN32 -DWIN32_LEAN_AND_MEAN \
       -I$(LESDIR)\include -I$(DCSDIR)\include -I$(MCSDIR)\include \
       -I$(SALDIR)\include -I$(MOCADIR)\include \
       $(WARNFLAG) $(DEBUGFLAG) $(RELFLAGS) $(EXTRACFLAGS)
LINKFLAGS=-incremental:no -release -manifest $(LINKDEBUG) $(EXTRALINKFLAGS) $(MAPFLAG)

!ifndef NOMOCALIBS
MOCALIBS=MOCA.lib
!endif

STDLIBS=ws2_32.lib kernel32.lib user32.lib gdi32.lib advapi32.lib

all: $(TARGET)$(TARGETTYPE)

clean:
!ifdef TEMPFILES
	-@del $(TEMPFILES)
!endif
        -@del $(TARGET).exe $(TARGET).dll $(TARGET).lib $(TARGET).exp
	-@del *.ilk *.obj *.pdb *.manifest
!ifdef EXTRADIR
        -@del $(EXTRADIR)\*.obj
!endif

install: all hinstall
!ifndef NOINSTALL
	perl $(LESDIR)\scripts\install.pl $(TARGET)$(TARGETTYPE) $(LESDIR)\bin
!ifndef NODEBUG
	perl $(LESDIR)\scripts\install.pl $(TARGET).pdb $(LESDIR)\bin
!endif
!endif
!if "$(TARGETTYPE)" != ".exe"
	-copy $(TARGET).lib $(LESDIR)\lib
!endif

hinstall: $(IFILES)
!ifdef IFILES
	!copy $** $(LESDIR)\include
!endif

$(TARGET).lib: $(OFILES)
	lib -nologo -out:$@ $(OFILES)

$(TARGET).exe: $(OFILES) $(LIBDEPEND)
	$(CC) $(CFLAGS) $(OFILES) -link \
	-libpath:$(LESDIR)\lib -libpath:$(DCSDIR)\lib -libpath:$(MCSDIR)\lib \
	-libpath:$(SALDIR)\lib -libpath:$(MOCADIR)\lib \
	$(STDLIBS) $(MOCALIBS) $(EXTRALIBS) $(LINKFLAGS) -out:$@ 
	mt -nologo -manifest $(TARGET).exe.manifest -outputresource:$(TARGET).exe;#1

$(TARGET).dll: $(OFILES) $(LIBDEPEND)
	$(CC) $(CFLAGS) -LD$(DEBUG) $(DEFFILE) $(OFILES) -link \
	-libpath:$(LESDIR)\lib -libpath:$(DCSDIR)\lib -libpath:$(MCSDIR)\lib \
	-libpath:$(SALDIR)\lib -libpath:$(MOCADIR)\lib \
	$(STDLIBS) $(MOCALIBS) $(EXTRALIBS) $(LINKFLAGS) \
	-dll -implib:$*.lib -out:$@
	mt -nologo -manifest $(TARGET).dll.manifest -outputresource:$(TARGET).dll;#2

.c.obj:
	$(CC) $(CFLAGS) -c $*.c -Fo$@

.cpp.obj:
	$(CC) $(CFLAGS) -c $*.cpp -Fo$@

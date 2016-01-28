STATICLIB = SComp_static.lib
SHAREDLIB = SComp.dll
SHAREDDEF = SComp.def
IMPLIB    = SComp.lib
INCLUDEINSTALL = SComp.h

#
# Set to 1 if shared object needs to be installed
#
SHARED_MODE=0

DEBUG = 1

#LOC = -DASMV
LOC = 

ifdef DEBUG
LOC += -DDEBUG -g -Wall \
  -Wno-missing-braces -Wextra -Wno-missing-field-initializers -Wformat=2 \
  -Wswitch-default -Wswitch-enum -Wcast-align -Wpointer-arith -Winline \
  -Wstrict-overflow=5 -Wundef -Wcast-qual -Wshadow -Wunreachable-code \
  -Wlogical-op -Wfloat-equal -Wstrict-aliasing=2 -Wredundant-decls 
#C: -Wold-style-definition -Wnested-externs -Wstrict-prototypes -Wbad-function-cast
endif

PREFIX =
CC = $(PREFIX)g++
CFLAGS = $(LOC) -m32 -std=c++11

AS = $(CC)
ASFLAGS = $(LOC) -Wall

LIBS= -lbz2 -lz 
LD = $(CC)
LDFLAGS = $(LOC) -mdll -static -Lbzip2 -Lzlib

AR = $(PREFIX)ar
ARFLAGS = rcs

RC = $(PREFIX)windres
RCFLAGS = --define GCC_WINDRES

STRIP = $(PREFIX)strip

CP = cp -fp
# If GNU install is available, replace $(CP) with install.
INSTALL = $(CP)
RM = rm -f

prefix ?= /usr/local
exec_prefix = $(prefix)

#export definitions requested
DEF = 
OBJS = huffman.o crc32.o explode.o implode.o SComp.o SErr.o SMem.o wave.o

all: $(STATICLIB) $(SHAREDLIB) $(IMPLIB)

.c.o:
	$(CC) $(CFLAGS) -c -o $@ $<

.cpp.o:
	$(CC) $(CFLAGS) -c -o $@ $<

$(STATICLIB): $(OBJS)
	$(AR) $(ARFLAGS) $@ $(OBJS)

$(IMPLIB): $(SHAREDLIB)

$(SHAREDDEF): $(SHAREDLIB)

$(SHAREDLIB): $(OBJS) $(DEF)
	$(CC) -mdll -Wl,--out-implib,$(IMPLIB) -Wl,--output-def,$(SHAREDDEF) $(LDFLAGS) \
	-o $@ $(DEF) $(OBJS) $(LIBS)
ifndef DEBUG
	$(STRIP) $@
endif

.PHONY: clean

clean:
	-$(RM) $(STATICLIB)
	-$(RM) $(SHAREDLIB)
	-$(RM) $(SHAREDDEF)
	-$(RM) $(IMPLIB)
	-$(RM) *.o
	-$(RM) *.exe


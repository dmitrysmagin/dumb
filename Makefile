# Main Makefile for DUMB.

# In theory, this Makefile can be used without modifications on DOS, Windows,
# Linux, BeOS and Mac OS X. Caveats are as follows:

# - For DOS and Windows users, COMSPEC (or ComSpec) must be set to point to
#   command.com or cmd.exe. If they point to a Unix-style shell, this
#   Makefile will die horribly.

# - Users of other platforms must NOT set COMSPEC or ComSpec. They must be
#   undefined.

# Commands are as follows:

#   make           - Build the library (does make config for you first time).
#   make install   - Install the library and examples into the system.
#   make uninstall - Remove the above.
#   make config    - Do or redo the configuration.
#   make clean     - Delete all object files; examples and libraries remain.
#   make veryclean - Delete examples and libraries too.
#   make distclean - Delete examples, libraries and configuration.
#                    (Note that this is unable to delete the dumbask
#                    executable if the configuration is absent.)

MAKEFILE = Makefile

.PHONY: all install uninstall clean veryclean distclean config config-if-necessary make-outdirs

PHONY_TARGETS := core allegro core-examples allegro-examples core-headers allegro-headers

.PHONY: $(PHONY_TARGETS)
.PHONY: $(PHONY_TARGETS:%=install-%)
.PHONY: $(PHONY_TARGETS:%=uninstall-%)


COMMA := ,

ifdef USE_ICC
CC := icc
else
ifdef USE_SGICC
CC := cc
else
CC := gcc
endif
endif
AR := ar


# Configuration.
# The configuration is done by an MS-DOS batch file if COMSPEC is set.
# Otherwise it is done by a Unix shell script. A file called 'config.txt',
# containing variables that control the build process, is created, and
# included by this Makefile.


ifeq "$(COMSPEC)" ""
ifdef ComSpec
COMSPEC := $(ComSpec)
endif
endif


-include make/config.txt


ifeq "$(OSTYPE)" "beos"

INCLUDE_INSTALL_PATH := /boot/develop/headers
LIB_INSTALL_PATH := /boot/develop/lib/x86
BIN_INSTALL_PATH := /boot/home/config/bin
# DEFAULT_PREFIX is not set, so config.sh will not prompt for PREFIX.
LINK_MATH :=

else

ifdef PREFIX
DEFAULT_PREFIX := $(PREFIX)
else
DEFAULT_PREFIX := /usr/local
endif
export DEFAULT_PREFIX
INCLUDE_INSTALL_PATH := $(PREFIX)/include
LIB_INSTALL_PATH := $(PREFIX)/lib
BIN_INSTALL_PATH := $(PREFIX)/bin

endif


all: config-if-necessary make-outdirs
	@$(MAKE) -f $(MAKEFILE) --no-print-directory $(ALL_TARGETS)
	$(call ECHO,DUMB has been built. Run $(APOST)make install$(APOST) to install it.)

install: config-if-necessary
	@$(MAKE) -f $(MAKEFILE) --no-print-directory $(ALL_TARGETS:%=install-%)
	$(call ECHO,DUMB has been installed.)
	$(call ECHO,See readme.txt for details on the example programs.)
	$(call ECHO,When you$(APOST)re ready to start using DUMB$(COMMA) see docs/howto.txt.)
	$(call ECHO,Enjoy!)

uninstall: config-if-necessary
	@$(MAKE) -f $(MAKEFILE) --no-print-directory $(ALL_TARGETS:%=uninstall-%)
	$(call ECHO,DUMB has been uninstalled.)


ifdef COMSPEC
# Assume DOS or Windows.
SHELL := $(COMSPEC)
CONFIG_COMMAND := make\config.bat
DUMBASK_EXE := make/dumbask.exe
else
# Assume a Unix-compatible system.
CONFIG_COMMAND := make/config.sh
DUMBASK_EXE := make/dumbask
endif

# This will always configure.
config: $(DUMBASK_EXE)
	$(CONFIG_COMMAND)

# This will only configure if the configuration file is absent. We don't use
# config.txt as the target name, because Make then runs the config initially,
# and again when it sees the 'config' target, so an initial 'make config'
# causes the configuration to be done twice.
ifeq "$(wildcard make/config.txt)" ""
config-if-necessary: config
else
config-if-necessary:
endif

$(DUMBASK_EXE): make/dumbask.c
	$(CC) $< -o $@


ifdef PLATFORM


# Build.


CORE_MODULES :=            \
    core/atexit.c          \
    core/duhlen.c          \
    core/duhtag.c          \
    core/dumbfile.c        \
    core/loadduh.c         \
    core/makeduh.c         \
    core/rawsig.c          \
    core/readduh.c         \
    core/register.c        \
    core/rendduh.c         \
    core/rendsig.c         \
    core/unload.c          \
    helpers/clickrem.c     \
    helpers/memfile.c      \
    helpers/resample.c     \
    helpers/sampbuf.c      \
    helpers/silence.c      \
    helpers/stdfile.c      \
    it/itload.c            \
    it/itread.c            \
    it/itload2.c           \
    it/itread2.c           \
    it/itrender.c          \
    it/itunload.c          \
    it/loads3m.c           \
    it/reads3m.c           \
    it/loadxm.c            \
    it/readxm.c            \
    it/loadmod.c           \
    it/readmod.c           \
    it/loads3m2.c          \
    it/reads3m2.c          \
    it/loadxm2.c           \
    it/readxm2.c           \
    it/loadmod2.c          \
    it/readmod2.c          \
    it/xmeffect.c          \
    it/itorder.c           \
    it/itmisc.c

ALLEGRO_MODULES :=         \
    allegro/alplay.c       \
    allegro/datduh.c       \
    allegro/datit.c        \
    allegro/datxm.c        \
    allegro/dats3m.c       \
    allegro/datmod.c       \
    allegro/datitq.c       \
    allegro/datxmq.c       \
    allegro/dats3mq.c      \
    allegro/datmodq.c      \
    allegro/datunld.c      \
    allegro/packfile.c

CORE_EXAMPLES := examples/dumbout.c examples/dumb2wav.c
ALLEGRO_EXAMPLES := examples/dumbplay.c

CORE_HEADERS := include/dumb.h
ALLEGRO_HEADERS := include/aldumb.h


LIBDIR := lib/$(PLATFORM)
OBJDIR_BASE := obj/$(PLATFORM)

make-outdirs:
	-$(call MKDIR,lib)
	-$(call MKDIR,lib/$(PLATFORM))
	-$(call MKDIR,obj)
	-$(call MKDIR,obj/$(PLATFORM))
	-$(call MKDIR,obj/$(PLATFORM)/debug)
	-$(call MKDIR,obj/$(PLATFORM)/release)


ifdef USE_ICC
WFLAGS := -Wall -DDUMB_DECLARE_DEPRECATED
WFLAGS_ALLEGRO :=
OFLAGS := -O2
DBGFLAGS := -DDEBUGMODE=1
else
ifdef USE_SGICC
WFLAGS := -fullwarn -DDUMB_DECLARE_DEPRECATED
WFLAGS_ALLEGRO :=
OFLAGS := -n32 -O2 -use_readonly_const
DBGFLAGS := -n32 -g3 -DDEBUGMODE=1
else
WFLAGS := -Wall -W -Wwrite-strings -Wstrict-prototypes -Wmissing-declarations -DDUMB_DECLARE_DEPRECATED
WFLAGS_ALLEGRO := -Wno-missing-declarations
OFLAGS := -O2 -ffast-math -fomit-frame-pointer
DBGFLAGS := -DDEBUGMODE=1 -g3
endif
endif

CFLAGS_RELEASE := -Iinclude $(WFLAGS) $(OFLAGS)
CFLAGS_DEBUG := -Iinclude $(WFLAGS) $(DBGFLAGS)

LDFLAGS := -s


CORE_EXAMPLES_OBJ := $(addprefix examples/, $(notdir $(patsubst %.c, %.o, $(CORE_EXAMPLES))))
ALLEGRO_EXAMPLES_OBJ := $(addprefix examples/, $(notdir $(patsubst %.c, %.o, $(ALLEGRO_EXAMPLES))))

CORE_EXAMPLES_EXE := $(addprefix examples/, $(notdir $(patsubst %.c, %$(EXE_SUFFIX), $(CORE_EXAMPLES))))
ALLEGRO_EXAMPLES_EXE := $(addprefix examples/, $(notdir $(patsubst %.c, %$(EXE_SUFFIX), $(ALLEGRO_EXAMPLES))))


CORE_LIB_FILE_RELEASE := $(LIBDIR)/libdumb.a
ALLEGRO_LIB_FILE_RELEASE := $(LIBDIR)/libaldmb.a

CORE_LIB_FILE_DEBUG := $(LIBDIR)/libdumbd.a
ALLEGRO_LIB_FILE_DEBUG := $(LIBDIR)/libaldmd.a


core: $(CORE_LIB_FILE_RELEASE) $(CORE_LIB_FILE_DEBUG)
allegro: $(ALLEGRO_LIB_FILE_RELEASE) $(ALLEGRO_LIB_FILE_DEBUG)

core-examples: $(CORE_EXAMPLES_EXE)
allegro-examples: $(ALLEGRO_EXAMPLES_EXE)

core-headers:

allegro-headers:

install-core: core
	$(call COPY,$(CORE_LIB_FILE_RELEASE),$(LIB_INSTALL_PATH))
	$(call COPY,$(CORE_LIB_FILE_DEBUG),$(LIB_INSTALL_PATH))

install-allegro: allegro
	$(call COPY,$(ALLEGRO_LIB_FILE_RELEASE),$(LIB_INSTALL_PATH))
	$(call COPY,$(ALLEGRO_LIB_FILE_DEBUG),$(LIB_INSTALL_PATH))

ifeq "$(COMSPEC)" ""
install-core-examples: core-examples
	$(call COPY,$(CORE_EXAMPLES_EXE),$(BIN_INSTALL_PATH))

install-allegro-examples: allegro-examples
	$(call COPY,$(ALLEGRO_EXAMPLES_EXE),$(BIN_INSTALL_PATH))
else
# Don't install the examples on a Windows system.
install-core-examples:
install-allegro-examples:
endif

install-core-headers:
	$(call COPY,$(CORE_HEADERS),$(INCLUDE_INSTALL_PATH))

install-allegro-headers:
	$(call COPY,$(ALLEGRO_HEADERS),$(INCLUDE_INSTALL_PATH))


uninstall-core:
	$(call DELETE,$(LIB_INSTALL_PATH)/$(notdir $(CORE_LIB_FILE_RELEASE)))
	$(call DELETE,$(LIB_INSTALL_PATH)/$(notdir $(CORE_LIB_FILE_DEBUG)))

uninstall-allegro:
	$(call DELETE,$(LIB_INSTALL_PATH)/$(notdir $(ALLEGRO_LIB_FILE_RELEASE)))
	$(call DELETE,$(LIB_INSTALL_PATH)/$(notdir $(ALLEGRO_LIB_FILE_DEBUG)))

ifeq "$(COMSPEC)" ""
uninstall-core-examples:
	$(call DELETE,$(patsubst %,$(BIN_INSTALL_PATH)/%,$(notdir $(CORE_EXAMPLES_EXE))))

uninstall-allegro-examples:
	$(call DELETE,$(patsubst %,$(BIN_INSTALL_PATH)/%,$(notdir $(ALLEGRO_EXAMPLES_EXE))))
else
# The examples wouldn't have been installed on a Windows system.
uninstall-core-examples:
uninstall-allegro-examples:
endif

uninstall-core-headers:
	$(call DELETE,$(patsubst %,$(INCLUDE_INSTALL_PATH)/%,$(notdir $(CORE_HEADERS))))

uninstall-allegro-headers:
	$(call DELETE,$(patsubst %,$(INCLUDE_INSTALL_PATH)/%,$(notdir $(ALLEGRO_HEADERS))))


OBJDIR := $(OBJDIR_BASE)/release
CFLAGS := $(CFLAGS_RELEASE)
CORE_LIB_FILE := $(LIBDIR)/libdumb.a
ALLEGRO_LIB_FILE := $(LIBDIR)/libaldmb.a
include make/Makefile.inc

OBJDIR := $(OBJDIR_BASE)/debug
CFLAGS := $(CFLAGS_DEBUG)
CORE_LIB_FILE := $(LIBDIR)/libdumbd.a
ALLEGRO_LIB_FILE := $(LIBDIR)/libaldmd.a
include make/Makefile.inc


$(CORE_EXAMPLES_EXE): examples/%$(EXE_SUFFIX): examples/%.o $(CORE_LIB_FILE_RELEASE)
	$(CC) $^ -o $@ $(LDFLAGS) $(LINK_MATH)

$(ALLEGRO_EXAMPLES_EXE): examples/%$(EXE_SUFFIX): examples/%.o $(ALLEGRO_LIB_FILE_RELEASE) $(CORE_LIB_FILE_RELEASE)
	$(CC) $^ -o $@ $(LDFLAGS) $(LINK_ALLEGRO)

$(CORE_EXAMPLES_OBJ): examples/%.o: examples/%.c include/dumb.h
	$(CC) $(CFLAGS_RELEASE) -c $< -o $@

$(ALLEGRO_EXAMPLES_OBJ): examples/%.o: examples/%.c include/dumb.h include/aldumb.h
	$(CC) $(CFLAGS_RELEASE) -Wno-missing-declarations -c $< -o $@


clean:
	$(call DELETE,$(OBJDIR_BASE)/release/*.o)
	$(call DELETE,$(OBJDIR_BASE)/debug/*.o)
	$(call DELETE,examples/*.o)

veryclean: clean
	$(call DELETE,$(CORE_LIB_FILE))
	$(call DELETE,$(ALLEGRO_LIB_FILE))
	$(call DELETE,$(CORE_EXAMPLES_EXE))
	$(call DELETE,$(ALLEGRO_EXAMPLES_EXE))

distclean: veryclean
	$(call DELETE,make/config.txt)
	$(call DELETE,$(DUMBASK_EXE))


else

make-outdirs:  # don't make output before configuration

endif # ifdef PLATFORM

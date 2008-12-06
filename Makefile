# custom vars
TGT		:= yaddns
VERSION		:= 0.1
INFO		:= http://gna.org/projects/yaddns

SERVICE		?= dyndns
LAYER		?= unix

EXTRA_LIBS	?= 

# global vars
CFLAGS		+= -DD_NAME="\"$(TGT)\"" -DD_VERSION="\"$(VERSION)\"" \
                   -DD_INFO="\"$(INFO)\"" \
		   $(FPIC) -std=gnu99 -D_GNU_SOURCE \
		   -Wall -Wextra -Werror -Wbad-function-cast -Wshadow \
		   -Wcast-qual -Wold-style-definition -Wmissing-noreturn \
		   -Wstrict-prototypes -Waggregate-return -Wformat=2 \
		   -Wswitch-default -Wundef -Wbad-function-cast -Wconversion \
		   -Wunused-parameter -Wunsafe-loop-optimizations -Wpointer-arith \
		   -I./include
LDFLAGS		+= -Wall
LDLIBS		+= $(EXTRA_LIBS)

ifeq ($(MODE), debug)
MAKEFLAGS	+= 'DEBUG=y'
CFLAGS		+= -g -DDEBUG
else
MAKEFLAGS	+=
CFLAGS		+= -Os -fomit-frame-pointer -DNDEBUG
endif

INSTALL		?= /usr/bin/install
ROOT		?= /usr/sbin

# files
core_sources	:= src/service.c src/layer.c $(wildcard src/*.c)
layer_source 	:= src/layers/$(LAYER).c
services_sources:= src/services/$(SERVICE).c
sources		:= $(core_sources) $(layer_source) $(services_sources)
objects		:= $(sources:.c=.o)

# rules
.PHONY: src/service.c src/layer.c

.PHONY: all
all: $(TGT)

$(TGT): $(objects)
	$(CC) $^ $(LDFLAGS) $(LDLIBS) -o $@

# Generate layer
src/layer.c:
	@echo > $@
	@echo '/* Autogenerated. Do NOT edit! */' >> $@
	@echo >> $@
	@echo >> $@
	@echo "#include \"defs.h\"" >> $@
	@echo >> $@
	@echo >> $@
	@echo "extern layer_t $(LAYER)_layer;" >> $@
	@echo >> $@
	@echo "layer_t *layer = &$(LAYER)_layer;" >> $@
	@echo >> $@

# Generate service
src/service.c:
	@echo > $@
	@echo '/* Autogenerated. Do NOT edit! */' >> $@
	@echo >> $@
	@echo >> $@
	@echo "#include \"defs.h\"" >> $@
	@echo >> $@
	@echo >> $@
	@echo "extern service_t $(SERVICE)_service;" >> $@
	@echo >> $@
	@echo "service_t *service = &$(SERVICE)_service;" >> $@
	@echo >> $@

.PHONY: install
install:
	$(INSTALL) -d $(ROOT)/usr/bin
	$(INSTALL) -m 770 $(TGT) $(ROOT)/usr/bin/

.PHONY: clean
clean:
	find -name "*.o" -delete
	@rm -f $(TGT)

.PHONY: mrproper
mrproper: clean

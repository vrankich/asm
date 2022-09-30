CROSS_COMPILE ?= aarch64-linux-gnu-

AS = $(CROSS_COMPILE)as
LD = $(CROSS_COMPILE)ld

ASFLAGS = -g
LDFLAGS = -g -static

ifeq ($(MAKECMDGOALS), reverse)
    ASFLAGS := $(ASFLAGS) --defsym reverse=1
endif


SRCS = gnome_sort.s
OBJS = $(SRCS:.s=.o)

EXE = sort

all: $(SRCS) $(EXE)

reverse: $(SRCS) $(EXE)

clean:
	rm -rf $(EXE) $(OBJS)

$(EXE): $(OBJS)
	$(LD) $(LDFLAGS) $(OBJS) -o $@

.s.o:
	$(AS) $(ASFLAGS) $< -o $@

include mkconfig/makefile_gcc.conf

#add .c files recursively
CSRCS  = $(shell find -type f -name *.c) 
_COBJS = $(CSRCS:.c=.o)
COBJS = $(notdir $(_COBJS))
CDIRS = $(dir $(sort $(_COBJS)))

#add .s files recursively
ASRCS  = $(shell find -type f -name *.s) 
_AOBJS = $(ASRCS:.s=.o)
AOBJS = $(notdir $(_AOBJS))
ADIRS = $(dir $(sort $(_AOBJS)))

#set vpath to search for objects
VPATH = ./obj
VPATH += ./bin
VPATH += $(dir $(CSRCS)) 
VPATH += $(dir $(ASRCS))


IFLAGS = $(addprefix -I, $(CDIRS))
IFLAGS += $(INCLUDES)

# create a list of all build objects
OBJS = $(COBJS)
OBJS += $(AOBJS)


# MAKE Targets
#-------------------------------------------------------

all: pre elf hex bin post
	@echo build of target $(TARGET) finished!


.PHONY: test
test: DFLAGS+= -DTESTING
test: clean all run
	@echo test

#compile the project to an .elf file
.PHONY: elf
elf: bin/$(TARGET).elf

#convert the .elf file to an intel hex format
.PHONY: hex
hex: bin/$(TARGET).hex 

#convert the .elf file to a binary format
.PHONY: bin
bin: bin/$(TARGET).bin

#create the build environment
.PHONY: pre
pre: env

.PHONY: run
run:
	@./bin/$(TARGET).elf

#show the filesize of the binary
.PHONY: post
post: $(TARGET).hex
	@echo Size of $<
	@echo ------------------------------------------------------
	$(OBJECTSIZE) $<
	@echo ------------------------------------------------------

# creating the build environment
.PHONY: env
env:
	@echo creating build environment for $(TARGET)
	@echo creating directories bin, obj
	mkdir -p bin obj 


bin/%.elf: $(addprefix obj/, $(OBJS))
	@echo building target $@
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(LDFLAGS) $(IFLAGS)  $^ -o $@


bin/%.hex:bin/%.elf
	@echo creating .hex from .elf target
	$(OBJECTCOPY) -Oihex $< $@


bin/%.bin:bin/%.elf
	@echo creating .bin from .elf target
	$(OBJECTCOPY) -Obinary $< $@


obj/%.o:%.c
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(OFLAGS) $(DFLAGS) $(IFLAGS) -c -o $@ $<


obj/%.o:%.s
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(AS) $(CFLAGS) $(IFLAGS) -c -o $@ $<


.PHONY: clean
clean:
	@echo cleaning build objects
	@echo ----------------------
	@echo removing $(OBJS) 
	@rm -f obj/*
	@echo 
	@echo cleaning targets
	@echo ----------------
	@echo removing target binaries
	@rm -f bin/*


.PHONY: distclean
distclean: clean
	@echo removing target folder
	@rm -rf obj bin

.SECONDARY: $(addprefix obj/, $(OBJS))

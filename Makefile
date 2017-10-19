include mkconfig/makefile_gcc.conf

#add .c files recursively
CSRCS  = $(shell find -type f -name *.c) 
_COBJS = $(CSRCS:.c=.o)
COBJS = $(notdir $(_COBJS))


#add .s files recursively
ASRCS  = $(shell find -type f -name *.s) 
_AOBJS = $(ASRCS:.s=.o)
AOBJS = $(notdir $(_AOBJS))

#set vpath to search for objects
VPATH = ./obj
VPATH+= ./bin
VPATH+= $(dir $(CSRCS)) 
VPATH+= $(dir $(ASRCS))


# create a list of all build objects
OBJS= $(COBJS)
OBJS+= $(AOBJS)


all: pre elf hex bin post
	@echo build finished!

test: OUTPUT = test
test: DFLAGS+= -DTESTING
test: pre elf hex bin post
	@echo build finished!


#compile the project to an .elf file
.PHONY: elf
elf: $(addprefix bin/, $(TARGET).elf )

#convert the .elf file to an intel hex format
.PHONY: hex
hex: $(addprefix bin/, $(TARGET).hex )

#convert the .elf file to a binary format
.PHONY: bin
bin: $(addprefix bin/, $(TARGET).bin )

#create the build environment
.PHONY: pre
pre: env


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
	@echo Hallo $(USER)
	@echo creating build environment
	@echo creating directories bin, obj
	mkdir -p bin obj 


bin/$(TARGET).elf: $(addprefix obj/, $(OBJS))
	@echo building target $@
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES)  $^ -o $@


bin/$(TARGET).hex: $(addprefix bin/, $(TARGET).elf)
	@echo creating .hex from .elf target
	$(OBJECTCOPY) -Oihex $< $@


bin/$(TARGET).bin: $(addprefix bin/, $(TARGET).elf)
	@echo creating .bin from .elf target
	$(OBJECTCOPY) -Obinary $< $@


obj/%.o:%.c
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(OFLAGS) $(DFLAGS) $(INCLUDES) -c -o $@ $<

obj/%.o:%.s
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(AS) $(CFLAGS) $(INCLUDES) -c -o $@ $<


.PHONY: clean
clean:
	@echo cleaning build objects
	@echo ----------------------
	@echo removing $(OBJS) 
	@rm -f obj/*
	
	@echo 
	@echo cleaning targets
	@echo ----------------
	@echo removing binaries for target: $(TARGET)
	@echo removing target
	@rm -f bin/*


.PHONY: distclean
distclean: clean
	@echo removing target folder
	@rm -rf obj bin


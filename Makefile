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
VPATH = $(dir $(CSRCS)) 
VPATH+= $(dir $(ASRCS))


# create a list of all build objects
OBJS= $(COBJS)
OBJS+= $(AOBJS)


all: pre elf hex bin post
	@echo build finished!

#compile the project to an .elf file
.PHONY: elf
elf: $(TARGET).elf

#convert the .elf file to an intel hex format
.PHONY: hex
hex: $(TARGET).hex

#convert the .elf file to a binary format
.PHONY: bin
bin: $(TARGET).bin

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
	@echo creating build environment
	@echo creating directory $(OUTPUT)
	mkdir -p $(OUTPUT)


$(TARGET).elf: $(OBJS) 
	@echo building target $@
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES)  $(addprefix $(OUTPUT)/, $^) -o $@


$(TARGET).hex: $(TARGET).elf
	@echo creating .hex from .elf target
	$(OBJECTCOPY) -Oihex $< $@


$(TARGET).bin: $(TARGET).elf
	@echo creating .bin from .elf target
	$(OBJECTCOPY) -Obinary $< $@


%.o:%.c
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(OFLAGS) $(DFLAGS) $(INCLUDES) -c -o $(OUTPUT)/$@ $<

%.o:%.s
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(AS) $(CFLAGS) $(INCLUDES) -c -o $(OUTPUT)/$@ $<


.PHONY: clean
clean:
	@echo cleaning build objects
	@echo ----------------------
	@echo removing $(OBJS) 
	@rm $(OUTPUT)/*.o
	@echo 
	@echo cleaning targets
	@echo ----------------
	@echo removing binaries for target: $(TARGET)
	@echo removing target
	@rm $(TARGET).*


.PHONY: distclean
distclean:
	@echo removing target folder
	@rm -rf $(OUTPUT)


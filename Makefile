include mkconfig/makefile_gcc.conf

#add project files recursively
SRCS  = $(shell find -type f -name *.c) 
_OBJS = $(SRCS:.c=.o)
OBJS = $(subst ./, $(OUTPUT)/, $(_OBJS))

#add project files recursively
ASRCS  = $(shell find -type f -name *.s) 
_AOBJS = $(ASRCS:.s=.o)
AOBJS = $(subst ./, $(OUTPUT)/, $(_AOBJS))


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
	$(foreach OBJDIR, $ $(dir $(OBJS) $(AOBJS)), @mkdir -pv $(OBJDIR))


$(TARGET).elf: $(OBJS) $(AOBJS)
	@echo building target $@
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) $^ -o $@


$(TARGET).hex: $(TARGET).elf
	@echo creating .hex from .elf target
	$(OBJECTCOPY) -Oihex $< $@


$(TARGET).bin: $(TARGET).elf
	@echo creating .bin from .elf target
	$(OBJECTCOPY) -Obinary $< $@


$(OBJS): $(OUTPUT)/%.o:%.c
	@echo generating $@ from $<
	@$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(OFLAGS) $(DFLAGS) $(INCLUDES) -c -o $@ $<

$(AOBJS): $(OUTPUT)/%.o:%.s
	@echo generating $@ from $<
	$(CC_PATH)$(CC_PREFIX)$(AS) $(CFLAGS) $(INCLUDES) -c -o $@ $<


.PHONY: clean
clean:
	@echo cleaning build objects
	@echo ----------------------
	@echo removing $(OBJS) $(AOBJS)
	@rm $(OBJS) $(AOBJS)
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



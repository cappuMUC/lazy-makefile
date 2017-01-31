# compiler settings
CC = gcc
COMPILER_PREFIX = 
COMPILER_PATH = 
CFLAGS = -Wall -O0
LDFLAGS =
INCLUDES = -Iinc/

#definition of the build target
TARGET:=test
OUTPUT = build/

#add project files recursively
SRCS  = $(shell find -type f -name *.c) 
_OBJS = $(SRCS:.c=.o)
#OBJS = $(addprefix $(OUTPUT), $(_OBJS))
OBJS = $(subst ./, ./$(OUTPUT), $(_OBJS))


all: pre dir $(TARGET)
	@echo build finished!

pre:
	@echo $(OBJS)

dir:
	@echo creating build environment
	$(foreach src, $(SRCS), $(shell mkdir -p $(addprefix $(OUTPUT), $(dir $(src)))))
	@echo test $(OBJS)
	@echo $(_OBJS)



$(TARGET):$(OBJS)
	@echo building target $@
	$(COMPILER_PATH)$(COMPILER_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) $(OBJS) -o $@

#%.o:%.c
$(OBJS):$(OUTPUT)%.o:%.c
	@echo creating $@ from $<
	$(COMPILER_PATH)$(COMPILER_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<


clean:
	@echo cleaning project
	@echo ----------------
	@echo removing objects
	@echo $(OBJS)
	@echo removing target
	@echo $(TARGET)
	@rm $(OBJS)
	@rm $(TARGET)


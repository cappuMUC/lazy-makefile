# compiler settings
CC = gcc
OBJECTCOPY =
OBJECTDUMP = 
OBJECTSIZE = 

# settings for cross compile
CC_PREFIX = 
CC_PATH = 

# settings for compilation and linking
CFLAGS = -Wall -O0
LDFLAGS =
INCLUDES = -Iinc/

#definition of the build target
TARGET:=test
OUTPUT = build/

#add project files recursively
SRCS  = $(shell find -type f -name *.c) 
_OBJS = $(SRCS:.c=.o)
OBJS = $(subst ./, ./$(OUTPUT), $(_OBJS))


all: pre $(TARGET) post
	@echo build finished!

pre: env

post:

# creating the build environment
env:
	@echo creating build environment
	$(foreach src, $(SRCS), $(shell mkdir -p $(addprefix $(OUTPUT), $(dir $(src)))))


$(TARGET):$(OBJS)
	@echo building target $@
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(LDFLAGS) $(INCLUDES) $(OBJS) -o $@


$(OBJS):$(OUTPUT)%.o:%.c
	@echo generating $@ from $<
	$(CC_PATH)$(CC_PREFIX)$(CC) $(CFLAGS) $(INCLUDES) -c -o $@ $<


clean:
	@echo cleaning project
	@echo ----------------
	@echo removing objects
	@echo $(OBJS)
	@echo removing target
	@echo $(TARGET)
	@rm $(OBJS)
	@rm $(TARGET)


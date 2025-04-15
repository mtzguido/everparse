all: CBORDetTest

SEPARSE_SRC_PATH = $(realpath ../../../../..)

#SEPARSE_LIB_PATH = $(realpath $(SEPARSE_SRC_PATH)/..)/lib/vercor
#SEPARSE_INCLUDE_PATH = $(realpath $(SEPARSE_SRC_PATH)/..)/include/vercor
SEPARSE_LIB_PATH = $(realpath ..)
SEPARSE_INCLUDE_PATH = $(realpath ..)

include $(SEPARSE_SRC_PATH)/karamel.Makefile

CFLAGS += -Werror -I $(SEPARSE_INCLUDE_PATH)

.PHONY: all

.PHONY: CBORDetTest

CBORDetTest: CBORDetTest.exe
	./CBORDetTest.exe

OBJ_FILES=CBORDetTest.o main.o

$(OBJ_FILES): %.o: %.c
	$(CC) $(CFLAGS) -c -o $@ $<

# CBORDetTest.c: gen/GenCBORDetTest.ml
# 	./gen/CBORDetTest.sh

#CBORDetTest.exe: CBORDetTest.o $(SEPARSE_LIB_PATH)/vercor.a
CBORDetTest.exe: $(OBJ_FILES) $(SEPARSE_LIB_PATH)/CBORDet.o
	$(CC) -o CBORDetTest.exe $^

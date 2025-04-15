all: verify

SEPARSE_SRC_PATH = $(realpath ../..)
INCLUDE_PATHS += $(realpath ..)

include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/karamel.Makefile
include $(SEPARSE_SRC_PATH)/separse.Makefile

ALREADY_CACHED := *,-LowParse.Pulse,
OUTPUT_DIRECTORY := _output

include $(SEPARSE_SRC_PATH)/common.Makefile

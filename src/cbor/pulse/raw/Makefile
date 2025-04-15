all: verify

SEPARSE_SRC_PATH = $(realpath ../../..)
INCLUDE_PATHS += $(realpath ..) $(realpath ../../spec) $(realpath ../../spec/raw)
ALREADY_CACHED := *,-CBOR.Pulse.Raw,-CBOR.Pulse.API,

include $(SEPARSE_SRC_PATH)/karamel.Makefile
include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

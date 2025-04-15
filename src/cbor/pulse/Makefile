all: verify

SEPARSE_SRC_PATH = $(realpath ../..)
INCLUDE_PATHS += $(realpath ../spec)
ALREADY_CACHED := *,-CBOR.Pulse,

include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

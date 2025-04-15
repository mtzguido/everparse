all: verify

SEPARSE_SRC_PATH = $(realpath ../../../..)
INCLUDE_PATHS += $(realpath ..) $(realpath ../..) $(realpath ../../../spec) $(realpath ../../../spec/raw) $(realpath ../../../spec/raw/everparse) $(SEPARSE_SRC_PATH)/lowparse $(SEPARSE_SRC_PATH)/lowparse/pulse

ALREADY_CACHED := *,-CBOR.Pulse.Raw.Format,-CBOR.Pulse.Raw.SEParse,

include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/everparse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

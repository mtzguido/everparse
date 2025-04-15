all: verify

SEPARSE_SRC_PATH = $(realpath ../../../..)
INCLUDE_PATHS += $(realpath ..) $(realpath ../..) $(SEPARSE_SRC_PATH)/lparse
ALREADY_CACHED := *,-CBOR.Spec.Raw.Format,-CBOR.Spec.Raw.SEParse,

include $(SEPARSE_SRC_PATH)/separse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

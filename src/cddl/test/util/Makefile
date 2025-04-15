all: verify

SEPARSE_SRC_PATH = $(realpath ../../..)
INCLUDE_PATHS += \
$(SEPARSE_SRC_PATH)/cddl/spec \
$(SEPARSE_SRC_PATH)/cbor/spec \
$(SEPARSE_SRC_PATH)/cbor/pulse \
$(KRML_HOME)/krmllib \
$(KRML_HOME)/krmllib/obj \
$(PULSE_HOME)/lib/pulse \
$(SEPARSE_SRC_PATH)/cddl/pulse

ALREADY_CACHED := *,-CDDL.Spec,

include $(SEPARSE_SRC_PATH)/common.Makefile

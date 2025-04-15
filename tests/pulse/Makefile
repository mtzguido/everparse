all: extract

SEPARSE_SRC_PATH = $(realpath ../../src)
INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/lowparse/pulse
ALREADY_CACHED := *,-ArithParse,

OUTPUT_DIRECTORY := _output
FSTAR_DEP_FILE := $(OUTPUT_DIRECTORY)/.depend
FSTAR_DEP_OPTIONS := --extract '*,-FStar.Tactics,-FStar.Reflection,-Pulse,-PulseCore,+Pulse.Class,+Pulse.Lib.Slice'

include $(SEPARSE_SRC_PATH)/karamel.Makefile
include $(SEPARSE_SRC_PATH)/separse.Makefile
include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

KRML_OPTS += -warn-error @4@6

KRML=$(KRML_HOME)/krml -fstar $(FSTAR_EXE) $(KRML_OPTS)

extract: $(ALL_KRML_FILES)
	$(KRML) -bundle 'ArithParse.Impl=*[rename=ArithParse]' -skip-linking $^ -tmpdir $(OUTPUT_DIRECTORY) -I $(SEPARSE_SRC_PATH)/cbor/pulse/det/c

.PHONY: extract

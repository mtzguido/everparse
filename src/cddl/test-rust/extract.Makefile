SEPARSE_SRC_PATH = $(realpath ../..)
SEPARSE_PATH = $(realpath $(SEPARSE_SRC_PATH)/..)
OUTPUT_DIRECTORY := _output
INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/cbor/spec $(SEPARSE_SRC_PATH)/cddl/spec $(SEPARSE_SRC_PATH)/cddl/tool $(SEPARSE_PATH)/lib/vercdl/lib $(SEPARSE_PATH)/lib/vercdl/plugin $(SEPARSE_SRC_PATH)/cbor/pulse $(SEPARSE_SRC_PATH)/cddl/pulse $(OUTPUT_DIRECTORY)
INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/cbor/spec $(SEPARSE_SRC_PATH)/cbor/spec/raw $(SEPARSE_SRC_PATH)/cbor/spec/raw/separse $(SEPARSE_SRC_PATH)/cbor/pulse/raw $(SEPARSE_SRC_PATH)/cbor/pulse/raw/separse $(SEPARSE_SRC_PATH)/lparse $(SEPARSE_SRC_PATH)/lparse/pulse

ALREADY_CACHED := *,-CDDLTest,
FSTAR_OPTIONS += --load_cmxs vercdl_lib --load_cmxs vercdl_plugin
FSTAR_OPTIONS += --warn_error -342
FSTAR_DEP_FILE := $(OUTPUT_DIRECTORY)/.depend
FSTAR_DEP_OPTIONS := --extract '*,-FStar.Tactics,-FStar.Reflection,-Pulse,-PulseCore,+Pulse.Class,+Pulse.Lib.Slice,-CDDL.Pulse.Bundle,-CDDL.Pulse.AST.Bundle,-CDDL.Tool'
FSTAR_FILES := $(OUTPUT_DIRECTORY)/CDDLTest.Test.fst

include $(SEPARSE_SRC_PATH)/karamel.Makefile
include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

#KRML_OPTS += -warn-error @4@6

KRML=$(KRML_HOME)/krml -fstar $(FSTAR_EXE) $(KRML_OPTS)

extract: $(ALL_KRML_FILES)
	$(KRML) -backend rust -fno-box -fkeep-tuples -fcontained-type cbor_raw_iterator -warn-error @1..27 -skip-linking -bundle 'CDDLTest.Test=[rename=CDDLExtractionTest]' -bundle 'CBOR.Pulse.API.Det.Rust=[rename=CBORDetVer]' -bundle 'CBOR.Spec.Constants+CBOR.Pulse.Raw.Type+CBOR.Pulse.API.Det.Type=\*[rename=CBORDetVerAux]' -tmpdir $(OUTPUT_DIRECTORY) -skip-compilation $^

#	$(KRML) -bundle CDDLTest.Test=*[rename=CDDLExtractionTest] -add-include '"CBORDetAbstract.h"' -no-prefix CBOR.Pulse.API.Det.Rust -no-prefix CBOR.Spec.Constants -skip-compilation $^ -tmpdir $(OUTPUT_DIRECTORY) -backend rust -fno-box -fkeep-tuples -fcontained-type cbor_raw_iterator

.PHONY: extract

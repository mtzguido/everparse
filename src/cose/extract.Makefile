SEPARSE_SRC_PATH = $(realpath ..)
SEPARSE_PATH = $(realpath $(SEPARSE_SRC_PATH)/..)
OUTPUT_DIRECTORY := _output
INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/cbor/spec $(SEPARSE_SRC_PATH)/cddl/spec $(SEPARSE_SRC_PATH)/cddl/tool $(SEPARSE_PATH)/lib/vercdl/lib $(SEPARSE_PATH)/lib/vercdl/plugin $(SEPARSE_SRC_PATH)/cbor/pulse $(SEPARSE_SRC_PATH)/cddl/pulse $(OUTPUT_DIRECTORY)

ALREADY_CACHED := *,-COSE,
FSTAR_OPTIONS += --load_cmxs vercdl_lib --load_cmxs vercdl_plugin
FSTAR_OPTIONS += --warn_error -342 # noextract
FSTAR_DEP_FILE := $(OUTPUT_DIRECTORY)/.depend
FSTAR_DEP_OPTIONS := --extract '*,-FStar.Tactics,-FStar.Reflection,-Pulse,-PulseCore,+Pulse.Class,+Pulse.Lib.Slice,-CDDL.Pulse.Bundle,-CDDL.Pulse.AST.Bundle,-CDDL.Tool'
FSTAR_FILES := $(OUTPUT_DIRECTORY)/COSE.Format.fst

include $(SEPARSE_SRC_PATH)/karamel.Makefile
include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

KRML_OPTS += -warn-error @4@6

KRML=$(KRML_HOME)/krml -fstar $(FSTAR_EXE) $(KRML_OPTS)

extract: $(ALL_KRML_FILES)
	$(KRML) -fnoshort-enums -bundle 'FStar.\*,LowStar.\*,C.\*,PulseCore.\*,Pulse.\*[rename=fstar]' -bundle 'CBOR.Spec.Constants+CBOR.Pulse.API.Det.Type+CBOR.Pulse.API.Det.C=CBOR.\*[rename=CBORDetAPI]'  -bundle COSE.Format=*[rename=COSE_Format] -add-include '"CBORDetAbstract.h"' -no-prefix CBOR.Pulse.API.Det.C -no-prefix CBOR.Pulse.API.Det.Type -no-prefix CBOR.Spec.Constants -skip-linking $^ -tmpdir $(OUTPUT_DIRECTORY) -I $(SEPARSE_SRC_PATH)/cbor/pulse/det/c -header noheader.txt

.PHONY: extract

snapshot: extract
	mkdir -p snapshot
	rm -f snapshot/*.c snapshot/*.h
	cp $(OUTPUT_DIRECTORY)/*.c snapshot/
	cp $(OUTPUT_DIRECTORY)/*.h snapshot/

.PHONY: snapshot

test: extract
	for f in $(OUTPUT_DIRECTORY)/*.c $(OUTPUT_DIRECTORY)/*.h ; do diff snapshot/$$(basename $$f) $$f ; done
	for f in snapshot/*.c snapshot/*.h ; do diff $$f $(OUTPUT_DIRECTORY)/$$(basename $$f) ; done

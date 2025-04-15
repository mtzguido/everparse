all: build

SEPARSE_SRC_PATH = $(realpath ../..)
INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/cbor/spec $(SEPARSE_SRC_PATH)/cddl/spec $(SEPARSE_SRC_PATH)/cddl/pulse $(SEPARSE_SRC_PATH)/cbor/pulse

ALREADY_CACHED := *,-CDDL.Tool,

include $(SEPARSE_SRC_PATH)/pulse.Makefile
include $(SEPARSE_SRC_PATH)/common.Makefile

ocaml.done: $(ALL_CHECKED_FILES)
	rm -f $@
	+$(MAKE) -f $(basename $@).Makefile
	touch $@

plugin.done: $(ALL_CHECKED_FILES)
	rm -f $@
	+$(MAKE) -f $(basename $@).Makefile
	touch $@

SEPARSE_CDDL=$(SEPARSE_SRC_PATH)/../bin/cddl.exe

build: $(SEPARSE_CDDL)

.PHONY: build

$(SEPARSE_CDDL): ocaml.done plugin.done $(wildcard ocaml/*/*.ml*)
	cd ocaml && $(FSTAR_EXE) --ocamlenv dune build
	cd ocaml && dune install --prefix=$(realpath $(SEPARSE_SRC_PATH)/..)

.PHONY: all

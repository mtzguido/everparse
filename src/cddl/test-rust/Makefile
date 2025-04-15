all: build-rust

SEPARSE_SRC_PATH = $(realpath ../..)

OUTPUT=_output/CDDLTest.Test.fst

$(OUTPUT): test.cddl
	$(SEPARSE_SRC_PATH)/../bin/cddl.exe $^ --odir $(dir $(OUTPUT)) --rust

extract-all: $(OUTPUT)
	+$(MAKE) -f extract.Makefile extract

build-rust: extract-all
	cargo build

.PHONY: build-rust extract-all all

# Uncomment if you want to edit the produced F* file
# include extract.Makefile

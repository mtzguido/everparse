all: cbor cddl cbor-interface

export FSTAR_EXE := $(realpath opt)/FStar/bin/fstar.exe
export KRML_HOME := $(realpath opt/karamel)
export PULSE_HOME := $(realpath opt/pulse/out)
export SEPARSE_OPT_PATH := $(realpath opt)

include $(SEPARSE_OPT_PATH)/env.Makefile

SEPARSE_SRC_PATH = $(realpath src)

ALREADY_CACHED := *,-LowParse,-CBOR,-CDDL,

SRC_DIRS += src/lowparse src/cbor/spec src/cbor/spec/raw src/cbor/spec/raw/separse src/cddl/spec

ifeq (,$(NO_PULSE))
  SRC_DIRS += src/lowparse/pulse src/cbor/pulse src/cbor/pulse/raw src/cbor/pulse/raw/separse src/cddl/pulse src/cddl/tool
endif

include $(SEPARSE_SRC_PATH)/karamel.Makefile
ifeq (,$(NO_PULSE))
  include $(SEPARSE_SRC_PATH)/pulse.Makefile
endif
include $(SEPARSE_SRC_PATH)/common.Makefile

lowparse: $(filter-out src/lowparse/pulse/%,$(filter src/lowparse/%,$(ALL_CHECKED_FILES)))

test: all cbor-test cddl-test lowparse-pulse-test

ifeq (,$(NO_PULSE))
lowparse-pulse: $(filter src/lowparse/pulse/%,$(ALL_CHECKED_FILES))
lowparse-pulse-test: lowparse-pulse
	$(MAKE) -C tests/pulse
else
lowparse-pulse:
lowparse-pulse-test:
endif

.PHONY: lowparse-pulse

cbor:
	+$(MAKE) -C src/cbor/pulse/det

cbor-interface: $(filter-out src/cbor/spec/raw/%,$(filter src/cbor/spec/%,$(ALL_CHECKED_FILES)))

ifeq (,$(NO_PULSE))
cbor-interface: $(filter-out src/cbor/pulse/raw/%,$(filter src/cbor/pulse/%,$(ALL_CHECKED_FILES)))
endif

.PHONY: cbor-interface

cbor-det-c-test: cbor
	+$(MAKE) -C src/cbor/pulse/det/c/test

ifeq (,$(NO_PULSE))
cbor-det-c-vertest: cbor cbor-interface
	+$(MAKE) -C src/cbor/pulse/det/vertest/c
else
cbor-det-c-vertest:
endif

.PHONY: cbor-det-c-vertest

ifeq (,$(NO_PULSE))
cbor-det-common-vertest: cbor cbor-interface
	+$(MAKE) -C src/cbor/pulse/det/vertest/common
else
cbor-det-common-vertest:
endif

.PHONY: cbor-det-common-vertest

# NOTE: I wish we could use `cargo -C ...` but see https://github.com/rust-lang/cargo/pull/11960
cbor-det-rust-test: cbor
	+cd src/cbor/pulse/det/rust && cargo test

cbor-verify: $(filter src/cbor/spec/%,$(ALL_CHECKED_FILES))

ifeq (,$(NO_PULSE))
cbor-verify: $(filter src/cbor/pulse/%,$(ALL_CHECKED_FILES))
endif

.PHONY: cbor-verify

# lowparse needed for extraction because of .fst files behind .fsti
ifeq (,$(NO_PULSE))
cbor-extract-pre: cbor-verify $(filter-out src/lowparse/LowParse.SLow.% src/lowparse/LowParse.Low.%,$(filter src/lowparse/%,$(ALL_CHECKED_FILES)))

.PHONY: cbor-extract-pre

cbor-test-snapshot: cbor-extract-pre
	+$(MAKE) -C src/cbor test-snapshot
else
cbor-test-snapshot: cbor-verify
endif

.PHONY: cbor-test-snapshot

# This rule is incompatible with `cbor` and `cbor-test-snapshot`
ifeq (,$(NO_PULSE))
cbor-snapshot: cbor-extract-pre
	+$(MAKE) -C src/cbor snapshot
else
cbor-snapshot:
endif

.PHONY: cbor-snapshot

cbor-test: cbor-det-c-test cbor-det-rust-test cbor-det-c-vertest cbor-det-common-vertest cbor-test-snapshot

cddl-spec: $(filter src/cddl/spec/%,$(ALL_CHECKED_FILES))

ifeq (,$(NO_PULSE))
cddl-pulse: cddl-spec $(filter src/cddl/pulse/%,$(ALL_CHECKED_FILES))

cddl-tool: cddl-pulse $(filter src/cddl/tool/%,$(ALL_CHECKED_FILES))
	+$(MAKE) -C src/cddl/tool
else
cddl-tool:
endif

cddl: cbor cbor-interface cddl-spec cddl-tool

.PHONY: cddl-spec cddl-tool

.PHONY: cbor cbor-det-c-test cbor-det-rust-test cbor-test cddl

ifeq (,$(NO_PULSE))
cddl-plugin-test: cddl
	+$(MAKE) -C src/cddl/test
else
cddl-plugin-test:
endif

.PHONY: cddl-plugin-test

ifeq (,$(NO_PULSE))
cddl-demo: cddl
	+$(MAKE) -C src/cddl/demo
else
cddl-demo:
endif

.PHONY: cddl-demo

ifeq (,$(NO_PULSE))
cddl-unit-tests: cddl
	+$(MAKE) -C src/cddl/unit-tests
else
cddl-unit-tests:
endif

.PHONY: cddl-unit-tests

ifeq (,$(NO_PULSE))
cose-extract-test: cddl
	+$(MAKE) -C src/cose test-extract

# This rule is incompatible with cose-extract-test
cose-snapshot: cddl
	+$(MAKE) -C src/cose snapshot
else
cose-extract-test:
cose-snapshot:
endif

.PHONY: cose-extract-test cose-snapshot

cose-test: cose-extract-test

.PHONY: cose-test

cose: cbor
	+$(MAKE) -C src/cose

.PHONY: cose

cddl-test: cddl cddl-plugin-test cddl-demo cose-extract-test cddl-unit-tests

.PHONY: cddl-test

ci: test lowparse-pulse cbor-test cddl-test

.PHONY: all gen verify test gen-test clean ci

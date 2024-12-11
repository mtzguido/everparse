all: package-subset asn1 cbor cbor-interface

package-subset: quackyducky lowparse 3d

.PHONY: package-subset

EVERPARSE_SRC_PATH = $(realpath src)

ALREADY_CACHED := *,-LowParse,-EverParse3d,-ASN1,-CBOR,

SRC_DIRS += src/lowparse src/ASN1 src/3d/prelude src/cbor/spec src/cbor/spec/raw src/cbor/spec/raw/everparse

ifeq (,$(NO_PULSE))
  SRC_DIRS += src/lowparse/pulse src/cbor/pulse src/cbor/pulse/raw src/cbor/pulse/raw/everparse
endif

include $(EVERPARSE_SRC_PATH)/karamel.Makefile
ifeq (,$(NO_PULSE))
  include $(EVERPARSE_SRC_PATH)/pulse.Makefile
endif
include $(EVERPARSE_SRC_PATH)/common.Makefile

lowparse: $(filter-out src/lowparse/pulse/%,$(filter src/lowparse/%,$(ALL_CHECKED_FILES)))

3d-prelude: $(filter src/3d/prelude/%,$(ALL_CHECKED_FILES))

.PHONY: 3d-prelude

3d-exe:
	+$(MAKE) -C src/3d 3d

.PHONY: 3d-exe

3d: 3d-prelude 3d-exe
	+$(MAKE) -C src/3d

# filter-out comes from NOT_INCLUDED in src/ASN1/Makefile
asn1: $(filter-out $(addprefix src/ASN1/,$(addsuffix .checked,ASN1.Tmp.fst ASN1.Test.Interpreter.fst ASN1.Low.% ASN1Test.fst ASN1.bak%)),$(filter src/ASN1/%,$(ALL_CHECKED_FILES)))

quackyducky:
	+$(MAKE) -C src/qd

gen-test: quackyducky
	-rm tests/unit/*.fst tests/unit/*.fsti || true
	bin/qd.exe -odir tests/unit tests/unittests.rfc
	bin/qd.exe -low -odir tests/unit tests/bitcoin.rfc

lowparse-unit-test: lowparse
	+$(MAKE) -C tests/lowparse

3d-unit-test: 3d
	+$(MAKE) -C src/3d test

3d-doc-test: 3d
	+$(MAKE) -C doc 3d

3d-test: 3d-unit-test 3d-doc-test

asn1-test: asn1
	+$(MAKE) -C src/ASN1 test

lowparse-bitfields-test: lowparse
	+$(MAKE) -C tests/bitfields

lowparse-test: lowparse-unit-test lowparse-bitfields-test

quackyducky-unit-test: gen-test lowparse
	+$(MAKE) -C tests/unit

quackyducky-sample-test: quackyducky lowparse
	+$(MAKE) -C tests/sample

quackyducky-sample-low-test: quackyducky lowparse
	+$(MAKE) -C tests/sample_low

quackyducky-sample0-test: quackyducky lowparse
	+$(MAKE) -C tests/sample0

quackyducky-test: quackyducky-unit-test quackyducky-sample-test quackyducky-sample0-test quackyducky-sample-low-test

test: all lowparse-test quackyducky-test 3d-test asn1-test

ifeq (,$(NO_PULSE))
lowparse-pulse: $(filter src/lowparse/pulse/%,$(ALL_CHECKED_FILES))
else
lowparse-pulse:
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

# NOTE: I wish we could use `cargo -C ...` but see https://github.com/rust-lang/cargo/pull/11960
cbor-det-rust-test: cbor
	+cd src/cbor/pulse/det/rust && cargo test

cbor-verify: $(filter src/cbor/spec/%,$(ALL_CHECKED_FILES))

ifeq (,$(NO_PULSE))
cbor-verify: $(filter src/cbor/pulse/%,$(ALL_CHECKED_FILES))
endif

.PHONY: cbor-verify

ifeq (,$(NO_PULSE))
cbor-test-snapshot: cbor-verify
	+$(MAKE) -C src/cbor test-snapshot
else
cbor-test-snapshot: cbor-verify
endif

.PHONY: cbor-test-snapshot

# This rule is incompatible with `cbor` and `cbor-test-snapshot`
ifeq (,$(NO_PULSE))
cbor-snapshot: cbor-verify
	+$(MAKE) -C src/cbor snapshot
else
cbor-snapshot:
endif

.PHONY: cbor-snapshot

cbor-test: cbor-det-c-test cbor-det-rust-test cbor-det-c-vertest cbor-test-snapshot

ifeq (,$(NO_PULSE))
cddl: cbor cbor-interface
	+$(MAKE) -C src/cddl
else
cddl:
endif

.PHONY: cbor cbor-det-c-test cbor-det-rust-test cbor-test cddl

ci: test lowparse-pulse cbor-test cddl

clean-3d:
	+$(MAKE) -C src/3d clean

clean-lowparse:
	+$(MAKE) -C src/lowparse clean

clean-quackyducky:
	+$(MAKE) -C src/qd clean

clean: clean-3d clean-lowparse clean-quackyducky
	rm -rf bin

.PHONY: all gen verify test gen-test clean quackyducky lowparse lowparse-test quackyducky-test lowparse-fstar-test quackyducky-sample-test quackyducky-sample0-test quackyducky-unit-test package 3d 3d-test lowparse-unit-test lowparse-bitfields-test release everparse 3d-unit-test 3d-doc-test ci clean-3d clean-lowparse clean-quackyducky asn1 asn1-test

release:
	+src/package/release.sh

# Windows binary package
package:
	+src/package/package.sh -zip

# Windows binary package
package-noversion:
	+src/package/package.sh -zip-noversion

everparse:
	+src/package/package.sh -make

# For F* testing purposes, cf. FStarLang/FStar@fc30456a163c749843c50ee5f86fa22de7f8ad7a

lowparse-fstar-test:
	+$(MAKE) -C src/lowparse fstar-test

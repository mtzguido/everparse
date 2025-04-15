# This file is only to verify LParse as a library, i.e. to place all
# LParse.*.checked files in this directory instead of a cache. This
# is to allow users to directly pick from these .checked files instead
# of rebuilding them. This Makefile assumes that everything else from
# the F* standard library and KRMLLib is already built (and fails otherwise)

all: verify

SEPARSE_SRC_PATH = $(realpath ..)

include $(SEPARSE_SRC_PATH)/karamel.Makefile

ALREADY_CACHED := *,-LParse,

include $(SEPARSE_SRC_PATH)/common.Makefile

clean:
	rm -rf *.checked *.source .depend

tot: $(filter LParse.Tot.%,$(ALL_CHECKED_FILES))

spec: $(filter LParse.Spec.%,$(ALL_CHECKED_FILES))

slow: $(filter LParse.SLow.%,$(ALL_CHECKED_FILES))

low: $(filter LParse.Low.%,$(ALL_CHECKED_FILES))

.PHONY: tot spec slow low

.PHONY: all verify clean %.fst-in %.fsti-in fstar-test

%.fst-in %.fsti-in:
	@echo $(FSTAR_OPTIONS) $(OTHERFLAGS)


# For F* testing purposes, cf. FStarLang/FStar@fc30456a163c749843c50ee5f86fa22de7f8ad7a

FSTAR_TEST_FILES= LParse.Bytes.fst LParse.Bytes32.fst		  \
	     LParse.Spec.Base.fst LParse.SLow.Base.fst	  \
	     LParse.Spec.Combinators.fst			  \
	     LParse.SLow.Combinators.fst LParse.Spec.Enum.fst \
	     LParse.SLow.Enum.fst

FSTAR_TEST_CHECKED_FILES=$(addsuffix .checked, $(FSTAR_TEST_FILES))

fstar-test: $(FSTAR_TEST_CHECKED_FILES)

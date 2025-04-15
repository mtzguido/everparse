ifeq (,$(SEPARSE_SRC_PATH))
  $(error "SEPARSE_SRC_PATH must be set to the absolute path of the src/ subdirectory of the SEParse repository")
endif

include $(SEPARSE_SRC_PATH)/karamel.Makefile

ALREADY_CACHED := LParse,$(ALREADY_CACHED)

INCLUDE_PATHS += $(SEPARSE_SRC_PATH)/lparse

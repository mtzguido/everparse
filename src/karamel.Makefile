ifeq (,$(EVERPARSE_SRC_PATH))
  $(error "EVERPARSE_SRC_PATH must be set to the absolute path of the src/ subdirectory of the EverParse repository")
endif

include $(EVERPARSE_SRC_PATH)/fstar.Makefile

ifeq (,$(KRML_HOME))
  # assuming Everest layout
  KRML_HOME := $(realpath $(EVERPARSE_SRC_PATH)/../../karamel)
  ifeq (,$(KRML_HOME))
    $(error "KRML_HOME must be defined and set to the root directory of the Karamel repository")
  endif
endif

ALREADY_CACHED := C,LowStar,$(ALREADY_CACHED)

INCLUDE_PATHS += $(KRML_HOME)/krmllib $(KRML_HOME)/krmllib/obj

CFLAGS += -I $(KRML_HOME)/include -I $(KRML_HOME)/krmllib/dist/generic

# Make sure krml uses the F* we set in FSTAR_EXE
KRML := $(KRML_HOME)/krml -fstar $(FSTAR_EXE)


export FSTAR_EXE  := $(SEPARSE_OPT_PATH)/FStar/bin/fstar.exe
export KRML_HOME  := $(SEPARSE_OPT_PATH)/karamel
export PULSE_HOME := $(SEPARSE_OPT_PATH)/pulse/out
export HACL_HOME := $(SEPARSE_OPT_PATH)/hacl-star
export PATH := $(SEPARSE_OPT_PATH)/z3:$(PATH)

env:
	@echo export FSTAR_EXE=$(FSTAR_EXE)
	@echo export KRML_HOME=$(KRML_HOME)
	@echo export PULSE_HOME=$(PULSE_HOME)
	@echo export HACL_HOME=$(HACL_HOME)
	@echo export PATH=$(SEPARSE_OPT_PATH)/FStar/bin:$(SEPARSE_OPT_PATH)/z3:\"'$$PATH'\"

.PHONY: env

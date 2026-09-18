# ============================================================
# APB CLASS-BASED VERIFICATION TESTBENCH
# ============================================================

TEST       ?= ALL
NUM_RANDOM ?= 100

TOP        = tb_top
SNAPSHOT   = $(TOP)_snap

FILELIST   = filelist.f

XVLOG      = xvlog
XELAB      = xelab
XSIM       = xsim


# ============================================================
# Default
# ============================================================

all: compile elaborate simulate


# ============================================================
# Compile
# ============================================================

compile:
	$(XVLOG) --sv -f $(FILELIST)


# ============================================================
# Elaborate
# ============================================================

elaborate:
	$(XELAB) $(TOP) -snapshot $(SNAPSHOT)


# ============================================================
# Simulate
# ============================================================

simulate:
	$(XSIM) $(SNAPSHOT) -runall \
		-testplusarg TEST=$(TEST) \
		-testplusarg NUM_RANDOM=$(NUM_RANDOM)


# ============================================================
# Individual tests
# ============================================================

reset:
	$(MAKE) TEST=RESET all

write:
	$(MAKE) TEST=WRITE all

read:
	$(MAKE) TEST=READ all

invalid:
	$(MAKE) TEST=INVALID all

discovery:
	$(MAKE) TEST=DISCOVERY all

random:
	$(MAKE) TEST=RANDOM all

all_tests:
	$(MAKE) TEST=ALL all


# ============================================================
# GUI
# ============================================================

gui:
	$(XSIM) $(SNAPSHOT) --gui


# ============================================================
# Clean
# ============================================================

clean:
	rm -rf xsim.dir
	rm -f *.jou
	rm -f *.log
	rm -f *.pb
	rm -f *.wdb
	rm -rf .Xil


# ============================================================
# Rebuild
# ============================================================

rebuild:
	$(MAKE) clean
	$(MAKE) all


# ============================================================
# Help
# ============================================================

help:
	@echo ""
	@echo "APB TESTBENCH"
	@echo ""
	@echo "make reset"
	@echo "make write"
	@echo "make read"
	@echo "make invalid"
	@echo "make discovery"
	@echo "make random"
	@echo "make all_tests"
	@echo ""
	@echo "Random count:"
	@echo "make random NUM_RANDOM=1000"
	@echo ""
	@echo "Generic:"
	@echo "make TEST=RANDOM NUM_RANDOM=1000"
	@echo ""


.PHONY: all compile elaborate simulate \
        reset write read invalid discovery random all_tests \
        gui clean rebuild help

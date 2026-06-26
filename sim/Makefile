# ===========================================================================
# Makefile -- DMA-350 Trigger VIP (Questa/ModelSim)
#
#   make compile
#   make simulate test=<test_name> uvm_verbosity=<LEVEL> [plusargs=+FLOW]
#   make all
#   make regression testlist_name=regression.list
#   make clean
#
# Run from this sim/ directory. UVM is taken from Questa's built-in library;
# if your install needs it explicitly, pass e.g.
#   make compile UVM_OPTS="+incdir+$$UVM_HOME/src $$UVM_HOME/src/uvm_pkg.sv"
# ===========================================================================

.IGNORE: compile simulate
.SILENT: usage compile_chk simulate_chk merge_cov_report

TOP            = dma_trig_tb_top
FILELIST       = dma_trig.f
COMPILE_LOG    = dma_trig_compile.log
UVM_OPTS      ?=

# -------- defaults (override on the command line) --------
ifndef test
override test = dma_trig_smoke_test
endif
ifndef uvm_verbosity
override uvm_verbosity = UVM_MEDIUM
endif
ifndef test_folder
override test_folder = $(test)
endif
ifndef seed
override seed = random
endif
ifndef plusargs
override plusargs =
endif
ifndef testlist_name
override testlist_name = regression.list
endif

# ===========================================================================
# Default target
# ===========================================================================
usage:
	echo "";
	echo "-----------------------------------------------------------------";
	echo "  DMA-350 Trigger VIP -- make usage";
	echo "-----------------------------------------------------------------";
	echo "  make compile";
	echo "  make simulate test=<test> uvm_verbosity=<LEVEL> [plusargs=+FLOW]";
	echo "  make all";
	echo "  make regression testlist_name=regression.list";
	echo "  make clean";
	echo "";
	echo "  Tests: dma_trig_smoke_test  dma_trig_distribute_test";
	echo "         dma_trig_flow_test (run with plusargs=+FLOW)";
	echo "         dma_trig_stall_test  dma_trig_errinj_test";
	echo "";
	echo "  Example:";
	echo "    make simulate test=dma_trig_flow_test plusargs=+FLOW uvm_verbosity=UVM_HIGH";
	echo "-----------------------------------------------------------------";
	echo "";

all:
	make compile; make simulate;

# ===========================================================================
# Compile  (+acc for assertions/debug, +cover/+fcover for coverage)
# ===========================================================================
compile:
	make clean_compile;
	vlib work;
	vlog -sv \
	+acc \
	+cover \
	+fcover \
	$(UVM_OPTS) \
	-l $(COMPILE_LOG) \
	-f $(FILELIST)
	make compile_chk

# ===========================================================================
# Simulate one test (per-test folder holds log / coverage / waveform)
# ===========================================================================
simulate:
	mkdir -p $(test_folder)
	vsim -c -64 \
	work.$(TOP) \
	-voptargs=+acc \
	-sva \
	-coverage \
	-sv_seed $(seed) \
	+UVM_TESTNAME=$(test) \
	+UVM_VERBOSITY=$(uvm_verbosity) \
	$(plusargs) \
	-l $(test_folder)/$(test).log \
	-do "coverage save -onexit -assert -directive -cvg -codeAll $(test_folder)/$(test).ucdb; run -all; exit" \
	-wlf $(test_folder)/waveform.wlf
	make simulate_chk

# ===========================================================================
# Regression: run every test in the testlist, then merge coverage.
# Testlist = one test name per line; lines starting with # are ignored.
# ===========================================================================
regression:
	for t in `grep -v '^#' $(testlist_name) | grep -v '^[[:space:]]*$$'`; do \
		echo "=== running $$t ==="; \
		$(MAKE) simulate test=$$t test_folder=$$t; \
	done
	make merge_cov_report

merge_cov_report:
	rm -rf merged_coverage.ucdb merged_cov_html_report
	vcover merge merged_coverage.ucdb -64 */*.ucdb
	vcover report -html merged_coverage.ucdb -htmldir ./merged_cov_html_report -details
	echo "";
	echo "  Merged coverage: firefox merged_cov_html_report/index.html &";
	echo "";

# ===========================================================================
# Reports
# ===========================================================================
compile_chk:
	echo "";
	echo "-------------------- Compilation Report -------------------------";
	grep -E "^\*\* (Error|Warning)" $(COMPILE_LOG) || echo "  (no errors/warnings)";
	echo "  Log: $(COMPILE_LOG)";
	echo "-----------------------------------------------------------------";
	echo "";

simulate_chk:
	echo "";
	echo "-------------------- Simulation Report --------------------------";
	echo "[Simulator Errors]"; grep -E "^# \*\* Error|Error:" $(test_folder)/$(test).log || echo "  none";
	echo "[UVM_FATAL]";        grep "UVM_FATAL" $(test_folder)/$(test).log || echo "  none";
	echo "[UVM_ERROR]";        grep "UVM_ERROR" $(test_folder)/$(test).log || echo "  none";
	echo "[UVM_WARNING]";      grep "UVM_WARNING" $(test_folder)/$(test).log || echo "  none";
	echo "";
	echo "  Test:     $(test)";
	echo "  Log:      $(test_folder)/$(test).log";
	echo "  Waveform: vsim -view $(test_folder)/waveform.wlf &";
	echo "-----------------------------------------------------------------";
	echo "";

# ===========================================================================
# Clean
# ===========================================================================
clean: clean_compile clean_simulate

clean_compile:
	rm -rf work/ $(COMPILE_LOG) transcript *.wlf
	rm -rf merged_coverage.ucdb merged_cov_html_report

clean_simulate:
	rm -rf dma_trig_*_test* *.ucdb

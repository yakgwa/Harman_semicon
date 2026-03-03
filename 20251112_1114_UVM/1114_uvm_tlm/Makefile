RTL_DIR = ./RTL_DIR/
TB_DIR = ./tb/
BUILD_DIR = ./build/
DUT = $(RTL_DIR)
TEST_BENCH = $(TB_DIR)tb_tlm_analysis.sv
COMP_OPT = -full64 -sverilog -timescale=1ns/100ps \
			-ntb_opts uvm-1.2 \
			-debug_access+all \
			-o $(BUILD_DIR)simv \
			-l $(BUILD_DIR)comp.log
TEST_NAME = test			
SIMV = $(BUILD_DIR)simv		
SIMV_OPT = +UVM_TESTNAME=$(TEST_NAME) \
			-l $(BUILD_DIR)simv.log

.PHONY : all vcs simv clean

all : vcs simv

vcs:
	vcs $(COMP_OPT) $(TEST_BENCH)
simv :
	$(SIMV) $(SIMV_OPT)
clean : 
	rm -rf build csrc *.key *.h
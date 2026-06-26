// ===========================================================================
// dma_trig.f  -- compile filelist for the DMA-350 Trigger VIP (Questa vlog -f)
// Run from the sim/ directory (paths are relative to sim/).
// UVM is taken from Questa's built-in library; if your install needs it
// explicitly, add via the Makefile UVM_OPTS variable.
// ===========================================================================

-timescale 1ns/1ps

// ---- include search paths (each agent folder + its seq/ via parent) ----
+incdir+../common
+incdir+../trig_in
+incdir+../trig_out
+incdir+../env
+incdir+../vseq
+incdir+../tb

// ---- interfaces (compiled standalone) ----
../rtl/dma_trig_in_if.sv
../rtl/dma_trig_out_if.sv

// ---- packages (compile order: common -> in/out -> env -> vseq) ----
../common/dma_trig_common_pkg.sv
../trig_in/dma_trig_in_pkg.sv
../trig_out/dma_trig_out_pkg.sv
../env/dma_trig_env_pkg.sv
../vseq/dma_trig_vseq_pkg.sv

// ---- testbench (behavioural DMA stub + top) ----
//../tb/dma_trig_dmac_stub.sv
../tb/dma_trig_tb_top.sv

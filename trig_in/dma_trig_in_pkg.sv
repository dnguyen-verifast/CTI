//============================================================================
// dma_trig_in_pkg.sv
// Trigger-IN (requester) agent package. Imports common. Compile after
// dma_trig_common_pkg; the interface dma_trig_in_if.sv is compiled separately.
//============================================================================
`ifndef DMA_TRIG_IN_PKG_SV
`define DMA_TRIG_IN_PKG_SV

package dma_trig_in_pkg;

  import uvm_pkg::*;
  `include "uvm_macros.svh"
  import dma_trig_common_pkg::*;

  `include "dma_trig_in_sequencer.sv"
  `include "dma_trig_in_driver.sv"
  `include "dma_trig_in_monitor.sv"
  `include "dma_trig_in_coverage.sv"
  `include "dma_trig_in_agent.sv"

  // ---- sequences (dependency order) ----
  `include "seq/dma_trig_in_base_seq.sv"
  `include "seq/dma_trig_in_single_seq.sv"
  `include "seq/dma_trig_in_block_burst_seq.sv"
  `include "seq/dma_trig_in_single_stream_seq.sv"
  `include "seq/dma_trig_in_rand_seq.sv"
  `include "seq/dma_trig_in_errinj_seq.sv"
  `include "seq/dma_trig_in_smoke_seq.sv"
  `include "seq/dma_trig_in_traffic_seq.sv"

endpackage : dma_trig_in_pkg

`endif // DMA_TRIG_IN_PKG_SV

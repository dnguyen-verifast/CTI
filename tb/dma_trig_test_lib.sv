//============================================================================
// dma_trig_test_lib.sv
// Example tests on the peripheral trigger VIP (trig-in requester + trig-out
// responder). Port counts come from the testbench top (config_db ints).
//============================================================================
`ifndef DMA_TRIG_TEST_LIB_SV
`define DMA_TRIG_TEST_LIB_SV

class dma_trig_base_test extends uvm_test;
  `uvm_component_utils(dma_trig_base_test)
  dma_trig_env env;
  dma_trig_cfg cfg;
  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  // Override to change ack-semantics mode / block size / coverage.
  virtual function void configure();
    cfg = dma_trig_cfg::type_id::create("cfg");
    cfg.mode = DMA_TRIG_MODE_CMD;   // command-mode acktype semantics
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    configure();
    uvm_config_db#(dma_trig_cfg)::set(this, "env", "cfg", cfg);
    env = dma_trig_env::type_id::create("env", this);
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);
    uvm_top.print_topology();
  endfunction
endclass

// Smoke: a few SINGLEs per trig-in port; trig-out ACK.
class dma_trig_smoke_test extends dma_trig_base_test;
  `uvm_component_utils(dma_trig_smoke_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    dma_trig_smoke_vseq vseq;
    phase.raise_objection(this);
    vseq = dma_trig_smoke_vseq::type_id::create("vseq");
    void'(vseq.randomize());
    vseq.start(env.vseqr);
    phase.drop_objection(this);
  endtask
endclass

// Full reqtype mix, command-mode semantics.
class dma_trig_distribute_test extends dma_trig_base_test;
  `uvm_component_utils(dma_trig_distribute_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    dma_trig_distribute_vseq vseq;
    phase.raise_objection(this);
    vseq = dma_trig_distribute_vseq::type_id::create("vseq");
    if (!vseq.randomize() with { rounds == 4; })
      `uvm_error(get_type_name(), "randomize failed")
    vseq.start(env.vseqr);
    phase.drop_objection(this);
  endtask
endclass

// Flow-control mode: scoreboard expects DENY only on SINGLE. Run with +FLOW so
// the DMA stub actually exercises DENY / LAST_OKAY.
class dma_trig_flow_test extends dma_trig_base_test;
  `uvm_component_utils(dma_trig_flow_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  virtual function void configure();
    cfg = dma_trig_cfg::type_id::create("cfg");
    cfg.mode = DMA_TRIG_MODE_FLOW;
  endfunction
  task run_phase(uvm_phase phase);
    dma_trig_distribute_vseq vseq;
    phase.raise_objection(this);
    vseq = dma_trig_distribute_vseq::type_id::create("vseq");
    if (!vseq.randomize() with { rounds == 6; })
      `uvm_error(get_type_name(), "randomize failed")
    vseq.start(env.vseqr);
    phase.drop_objection(this);
  endtask
endclass

// Channel-stall: trig-out acked after a very long delay.
class dma_trig_stall_test extends dma_trig_base_test;
  `uvm_component_utils(dma_trig_stall_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    dma_trig_stall_vseq vseq;
    phase.raise_objection(this);
    vseq = dma_trig_stall_vseq::type_id::create("vseq");
    void'(vseq.randomize());
    vseq.start(env.vseqr);
    phase.drop_objection(this);
  endtask
endclass

// Error-injection: req_type mutated while req held (expect assertion to fire).
class dma_trig_errinj_test extends dma_trig_base_test;
  `uvm_component_utils(dma_trig_errinj_test)
  function new(string name, uvm_component parent); super.new(name, parent); endfunction
  task run_phase(uvm_phase phase);
    dma_trig_errinj_vseq vseq;
    phase.raise_objection(this);
    vseq = dma_trig_errinj_vseq::type_id::create("vseq");
    void'(vseq.randomize());
    vseq.start(env.vseqr);
    phase.drop_objection(this);
  endtask
endclass

`endif // DMA_TRIG_TEST_LIB_SV

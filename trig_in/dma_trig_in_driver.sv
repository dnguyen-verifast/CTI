//============================================================================
// dma_trig_in_driver.sv
// Trigger-IN (REQUESTER) driver. The peripheral VIP drives the request side of
// the 4-phase handshake; the DMAC drives ack/ack_type back.
//
// Capabilities:
//   * valid 4-phase: req^ -> wait ack^ -> req v -> wait ack v
//   * req_type held stable the whole time req is HIGH
//   * any of the 4 reqtypes (SINGLE/BLOCK/LAST SINGLE/LAST BLOCK), set by seq
//   * timing variation: pre_delay (req early/late + inter-req gap)
//   * error injection: mutate req_type while req is held (illegal stimulus)
//   * supports zero-delay ack (handshake completes the cycle after req)
//============================================================================
`ifndef DMA_TRIG_IN_DRIVER_SV
`define DMA_TRIG_IN_DRIVER_SV

class dma_trig_in_driver extends uvm_driver #(dma_trig_item);

  `uvm_component_utils(dma_trig_in_driver)

  virtual dma_trig_in_if vif;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual dma_trig_in_if)::get(this, "", "vif", vif))
      `uvm_fatal(get_type_name(), "virtual dma_trig_in_if 'vif' not set")
  endfunction

  task run_phase(uvm_phase phase);
    drive_idle();
    forever begin
      @(posedge vif.clk);
      if (!vif.resetn) begin drive_idle(); continue; end
      seq_item_port.get_next_item(req);
      drive_req(req);
      seq_item_port.item_done();
    end
  endtask

  function void drive_idle();
    vif.req_cb.trig_in_req      <= 1'b0;
    vif.req_cb.trig_in_req_type <= '0;
  endfunction

  task drive_req(dma_trig_item it);
    // Idle gap / early-late control.
    repeat (it.pre_delay) @(vif.req_cb);

    it.t_req = $time;
    vif.req_cb.trig_in_req      <= 1'b1;
    vif.req_cb.trig_in_req_type <= it.reqtype;

    // Optional illegal injection: change req_type while req held (1-2 cycles in).
    if (it.err_reqtype_change) begin
      @(vif.req_cb);
      if (vif.req_cb.trig_in_ack !== 1'b1) begin
        vif.req_cb.trig_in_req_type <= it.err_reqtype_alt;
        `uvm_warning(get_type_name(),
          $sformatf("ERR-INJECT: req_type %s->%s while req held",
                    it.reqtype.name(), it.err_reqtype_alt.name()))
      end
    end

    // Wait for ack (zero-delay possible: ack may already be high next sample).
    do @(vif.req_cb); while (vif.req_cb.trig_in_ack !== 1'b1);
    it.t_ack            = $time;
    it.observed_acktype = dma_trig_acktype_e'(vif.req_cb.trig_in_ack_type);

    // Return-to-zero.
    vif.req_cb.trig_in_req      <= 1'b0;
    vif.req_cb.trig_in_req_type <= '0;
    do @(vif.req_cb); while (vif.req_cb.trig_in_ack !== 1'b0);

    `uvm_info(get_type_name(),
      $sformatf("req=%s -> ack=%s", it.reqtype.name(), it.observed_acktype.name()),
      UVM_HIGH)
  endtask

endclass : dma_trig_in_driver

`endif // DMA_TRIG_IN_DRIVER_SV

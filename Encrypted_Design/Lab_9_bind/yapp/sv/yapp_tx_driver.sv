`ifndef YAPP_TX_DRIVER_SV
`define YAPP_TX_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class yapp_tx_driver extends uvm_driver #(yapp_packet);
  `uvm_component_utils(yapp_tx_driver)

  // =====================================================
  // Added declarations
  // =====================================================
  // Virtual interface handle
  virtual yapp_if vif;

  // Count how many packets were sent
  int num_sent;

  function new(string name = "yapp_tx_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // =====================================================
  // build_phase : fetch interface from config_db
  // =====================================================
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!uvm_config_db#(virtual yapp_if)::get(this, "", "vif", vif)) begin
      `uvm_fatal("NOVIF", {"Virtual interface must be set for: ",
                           get_full_name(), ".vif"})
    end
  endfunction

  // =====================================================
  // run_phase : run reset handler and sequencer driver
  // =====================================================
  task run_phase(uvm_phase phase);
    fork
      get_and_drive();
      reset_signals();
    join
  endtask

  // =====================================================
  // get_and_drive : pull items from sequencer and drive
  // =====================================================
  task get_and_drive();
    // Wait until reset is deasserted
    @(negedge vif.reset);
    `uvm_info(get_type_name(), "Reset dropped", UVM_MEDIUM)

    forever begin
      // Get new packet from sequencer
      seq_item_port.get_next_item(req);

      // Drive it into DUT
      send_to_dut(req);

      // Inform sequencer that driving is complete
      seq_item_port.item_done();
    end
  endtask : get_and_drive

  // =====================================================
  // reset_signals : clear signals whenever reset asserted
  // =====================================================
  task reset_signals();
    forever begin
      @(posedge vif.reset);
      `uvm_info(get_type_name(), "Reset observed", UVM_MEDIUM)
      vif.in_data      <= 'hz;
      vif.in_data_vld  <= 1'b0;
      disable send_to_dut;  // stop any ongoing packet send
    end
  endtask : reset_signals

  // =====================================================
  // send_to_dut : actually drives the packet onto the bus
  // =====================================================
  task send_to_dut(yapp_packet packet);

    // Wait for packet delay
    repeat(packet.packet_delay)
      @(negedge vif.clock);

    // Wait until DUT is ready (not in suspend)
    @(negedge vif.clock iff (!vif.in_suspend));

    // Begin transaction recording
    void'(this.begin_tr(packet, "Input_YAPP_Packet"));

    // Assert valid, drive header {Length, Addr}
    vif.in_data_vld <= 1'b1;
    vif.in_data    <= { packet.length, packet.addr };

    // Drive payload
    for (int i=0; i<packet.payload.size(); i++) begin
      @(negedge vif.clock iff (!vif.in_suspend))
      vif.in_data <= packet.payload[i];
    end

    // Drive parity
    @(negedge vif.clock iff (!vif.in_suspend))
    vif.in_data_vld <= 1'b0;
    vif.in_data     <= packet.parity;

    // Release bus after one more cycle
    @(negedge vif.clock)
      vif.in_data <= 'hz;

    num_sent++;

    // End transaction recording
    this.end_tr(packet);
  endtask : send_to_dut

  // =====================================================
  // Report phase
  // =====================================================
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
              $sformatf("Report: YAPP TX driver sent %0d packets", num_sent),
              UVM_LOW)
  endfunction : report_phase

endclass

`endif // YAPP_TX_DRIVER_SV


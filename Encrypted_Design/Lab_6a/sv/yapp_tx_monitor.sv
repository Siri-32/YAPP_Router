`ifndef YAPP_TX_MONITOR_SV
`define YAPP_TX_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// Monitor class definition
class yapp_tx_monitor extends uvm_monitor;
  
  `uvm_component_utils(yapp_tx_monitor)

  // Virtual interface handle
  virtual yapp_if vif;

  // Collected Data handle
  yapp_packet packet_collected;

  // Count packets collected
  int num_pkt_col;

  // Constructor
  function new(string name = "yapp_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase: get the interface from config_db
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    if (!yapp_vif_config::get(this, "", "vif", vif))
      `uvm_fatal("NOVIF", {"vif not set for: ", get_full_name(), ".vif"})
  endfunction

  // start_of_simulation_phase
  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(),
              "start_of_simulation_phase called",
              UVM_HIGH)
  endfunction

  // Run phase: continuously collect packets
  task run_phase(uvm_phase phase);
    `uvm_info(get_type_name(), "Inside the run_phase", UVM_MEDIUM)

    // Create collected packet instance
    packet_collected = yapp_packet::type_id::create("packet_collected", this);

    // Wait for reset de-assertion
    @(negedge vif.reset)
    `uvm_info(get_type_name(), "Detected Reset Done", UVM_MEDIUM)

    forever
      collect_packet();
  endtask : run_phase

  // Collect Packets task
  task collect_packet();
      //Monitor looks at the bus on posedge (Driver uses negedge)
      @(posedge vif.in_data_vld);

      @(posedge vif.clock iff (!vif.in_suspend))

      // Begin transaction recording
      void'(this.begin_tr(packet_collected, "Monitor_YAPP_Packet"));

      `uvm_info(get_type_name(), "Collecting a packet", UVM_HIGH)

      // Collect Header {Length, Addr}
      { packet_collected.length, packet_collected.addr }  = vif.in_data;

      // Allocate the payload array
      packet_collected.payload = new[packet_collected.length]; 

      // Collect the Payload
      for (int i=0; i< packet_collected.length; i++) begin
         @(posedge vif.clock iff (!vif.in_suspend))
         packet_collected.payload[i] = vif.in_data;
      end

      // Collect Parity and Compute Parity Type
      @(posedge vif.clock iff !vif.in_suspend)
        packet_collected.parity = vif.in_data;
      packet_collected.parity_type =
        (packet_collected.parity == packet_collected.calc_parity()) ?
         GOOD_PARITY : BAD_PARITY;

      // End transaction recording
      this.end_tr(packet_collected);

      `uvm_info(get_type_name(),
        $sformatf("Packet Collected :\n%s", packet_collected.sprint()),
        UVM_LOW)

      num_pkt_col++;
  endtask : collect_packet

  // Report phase: show how many packets were collected
  function void report_phase(uvm_phase phase);
    `uvm_info(get_type_name(),
      $sformatf("Report: YAPP Monitor Collected %0d Packets", num_pkt_col),
      UVM_LOW)
  endfunction : report_phase

endclass : yapp_tx_monitor

`endif


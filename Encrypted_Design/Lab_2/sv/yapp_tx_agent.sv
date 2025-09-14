`ifndef YAPP_TX_AGENT_SV
`define YAPP_TX_AGENT_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// Include other component definitions
`include "yapp_tx_monitor.sv"
`include "yapp_tx_driver.sv"
`include "yapp_tx_sequencer.sv"

class yapp_tx_agent extends uvm_agent;

  // Register the agent with UVM factory
  `uvm_component_utils(yapp_tx_agent)

  // Sub-component handles
  yapp_tx_monitor    monitor;
  yapp_tx_driver     driver;
  yapp_tx_sequencer  sequencer;

  // Active/passive control flag
  uvm_active_passive_enum is_active = UVM_ACTIVE;

  // Constructor
  function new(string name = "yapp_tx_agent", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Monitor is always present
    monitor = yapp_tx_monitor::type_id::create("monitor", this);

    // Conditionally create driver & sequencer if agent is active
    if (is_active == UVM_ACTIVE) begin
      driver    = yapp_tx_driver::type_id::create("driver", this);
      sequencer = yapp_tx_sequencer::type_id::create("sequencer", this);
    end
  endfunction

  // Connect phase
  function void connect_phase(uvm_phase phase);
    super.connect_phase(phase);

    if (is_active == UVM_ACTIVE) begin
      driver.seq_item_port.connect(sequencer.seq_item_export);
    end
  endfunction

endclass

`endif // YAPP_TX_AGENT_SV


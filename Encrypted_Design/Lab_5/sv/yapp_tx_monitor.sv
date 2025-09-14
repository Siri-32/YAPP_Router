// yapp_tx_monitor.sv
`ifndef YAPP_TX_MONITOR_SV
`define YAPP_TX_MONITOR_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class yapp_tx_monitor extends uvm_monitor;
  
  `uvm_component_utils(yapp_tx_monitor)

  function new(string name = "yapp_tx_monitor", uvm_component parent = null);
    super.new(name, parent);
  endfunction
  
  function void start_of_simulation_phase(uvm_phase phase);
  super.start_of_simulation_phase(phase);
  `uvm_info(get_type_name(),
            "start_of_simulation_phase called",
            UVM_HIGH)
  endfunction


  task run_phase(uvm_phase phase);
    `uvm_info("YAPP_TX_MON", "Inside YAPP TX Monitor run_phase", UVM_LOW)
  endtask

endclass

`endif


`ifndef YAPP_TEST_LIB_SV
`define YAPP_TEST_LIB_SV

`include "uvm_macros.svh"
`include "../sv/yapp.svh"
import uvm_pkg::*;

class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  yapp_env env;

  // Constructor
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    // Set default sequence for the sequencer
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());
    super.build_phase(phase);

    // Construct environment
    env = yapp_env::type_id::create("env", this);
  endfunction

  // End of elaboration phase - print topology
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction

endclass


// ---------------- Test2 ----------------
// Runs a different sequence to send 10 packets instead of 5
class test2 extends base_test;
  `uvm_component_utils(test2)

  // Constructor
  function new(string name = "test2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase override
  function void build_phase(uvm_phase phase);
    // Set default sequence to send 10 packets
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_10_packets::type_id::get());
    super.build_phase(phase);
  endfunction

endclass

`endif


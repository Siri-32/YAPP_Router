`ifndef YAPP_TEST_LIB_SV
`define YAPP_TEST_LIB_SV

`include "uvm_macros.svh"
`include "../sv/yapp.svh"
import uvm_pkg::*;

// ---------------- Base Test ----------------
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
   /* uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());*/
    super.build_phase(phase);

    // Construct environment
    env = yapp_env::type_id::create("env", this);
  endfunction

  // End of elaboration phase - print topology
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
endclass

// ---------------- Test1 ----------------
class test1 extends base_test;
  `uvm_component_utils(test1)

  function new(string name = "test1", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());
    super.build_phase(phase);
  endfunction
endclass

// ---------------- Test2 ----------------
class test2 extends base_test;
  `uvm_component_utils(test2)

  function new(string name = "test2", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_10_packets::type_id::get());
    super.build_phase(phase);
  endfunction
endclass


// ---------------- Short Packet Test ----------------
class short_packet_test extends base_test;
  `uvm_component_utils(short_packet_test)

  function new(string name = "short_packet_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Override packet type for the whole environment
    set_type_override_by_type(yapp_packet::get_type(),
                              short_yapp_packet::get_type());

    // Keep same default sequence as base_test
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());

    super.build_phase(phase);
  endfunction
endclass

`endif


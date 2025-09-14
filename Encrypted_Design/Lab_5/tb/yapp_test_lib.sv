`ifndef YAPP_TEST_LIB_SV
`define YAPP_TEST_LIB_SV

`include "uvm_macros.svh"
`include "../sv/yapp.svh"
`include "yapp_seq_lib.sv" 
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

// ---------------- Short Incrementing Payload Test ----------------
class short_incr_payload extends base_test;
  `uvm_component_utils(short_incr_payload)

  function new(string name = "short_incr_payload", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // Override packet type to short_yapp_packet
    set_type_override_by_type(yapp_packet::get_type(),
                              short_yapp_packet::get_type());

    // Set default sequence to incrementing payload seq
    uvm_config_wrapper::set(this, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_incr_payload_seq::type_id::get());

    super.build_phase(phase);
  endfunction
endclass

// ---------------- Exhaustive Sequence Test ----------------
class exhaustive_seq_test extends base_test;
  `uvm_component_utils(exhaustive_seq_test)

  yapp_seq_lib seq_lib;

  function new(string name = "exhaustive_seq_test", uvm_component parent = null);
    super.new(name, parent);
    // Create sequence library instance
    seq_lib = yapp_seq_lib::type_id::create("seq_lib");
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Configure sequence library
    seq_lib.selection_mode   = UVM_SEQ_LIB_RANDC;
    seq_lib.min_random_count = 9; // number of sequences in yapp_seq_lib
    seq_lib.max_random_count = 9;

    // Set default sequence to library instance
    uvm_config_db#(uvm_sequence_base)::set(this,
                                           "env.agent.sequencer.run_phase",
                                           "default_sequence",
                                           seq_lib);

    // Override packet type with short packet
    set_type_override_by_type(yapp_packet::get_type(),
                              short_yapp_packet::get_type());
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase); // still prints topology
    seq_lib.print(); // print sequence library for debug
  endfunction
endclass

`endif


`ifndef ROUTER_TEST_LIB_SV
`define ROUTER_TEST_LIB_SV

`include "uvm_macros.svh"
//`include "../sv/yapp.svh"
//`include "yapp_seq_lib.sv" 
//`include "router_tb.sv"
import uvm_pkg::*;
`include "router_tb.sv"
//`include "../../yapp/sv/yapp_env.sv"
`include "../../channel/sv/channel_env.sv"
`include "../../hbus/sv/hbus_env.sv"
`include "../../hbus/sv/hbus_master_seqs.sv"
`include "../../yapp/sv/yapp_packet.sv"
`include "yapp_seq_lib.sv"
`include "../../channel/sv/channel_rx_seqs.sv"

// ---------------- Base Test ----------------
class base_test extends uvm_test;
  `uvm_component_utils(base_test)

  router_tb tb;

  // Constructor
  function new(string name = "base_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    /* uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_5_packets::type_id::get());*/
    super.build_phase(phase);

    // Construct environment
    tb = router_tb::type_id::create("tb", this);
  endfunction

  // End of elaboration phase - print topology
  function void end_of_elaboration_phase(uvm_phase phase);
    uvm_top.print_topology();
  endfunction
  // Run phase - set drain time so simulation waits before ending
  task run_phase(uvm_phase phase);
    phase.raise_objection(this, "Starting base_test run_phase");

    // Let the simulation run for some time so default sequences can execute
    // (Or you can wait for some event, e.g., end-of-packets)
    #100000ns;

    phase.drop_objection(this, "Ending base_test run_phase");
  endtask
endclass

// ---------------- Simple Test ----------------
class simple_test extends base_test;
  `uvm_component_utils(simple_test)

  function new(string name = "simple_test", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);

    // Override YAPP packet type
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // YAPP UVC default sequence
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_012_seq::type_id::get());

    // Channel UVCs default sequence (rx only)
    uvm_config_wrapper::set(this, "tb.ch_env0.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.ch_env1.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());
    uvm_config_wrapper::set(this, "tb.ch_env2.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());

    // No default sequence for HBUS UVC (tb.hbus)


  endfunction
endclass

//------------------------------------------------------------------------------
// test_uvc_integration
// Purpose: Demonstrates integration of HBUS + YAPP UVCs
//   - HBUS UVC programs router (MAXPKTSIZE=20, enable=1)
//   - YAPP UVC runs the all-channel sequence (1..22 payloads, 20% bad parity)
//------------------------------------------------------------------------------
class test_uvc_integration extends base_test;
  `uvm_component_utils(test_uvc_integration)

  function new(string name = "test_uvc_integration", uvm_component parent);
    super.new(name, parent);
  endfunction : new

  virtual function void build_phase(uvm_phase phase);
    super.build_phase(phase);


    // Channel UVC default sequences (for responses)
    uvm_config_wrapper::set(this, "tb.ch_env0.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "tb.ch_env1.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());

    uvm_config_wrapper::set(this, "tb.ch_env2.rx_agent.sequencer.run_phase", "default_sequence",
                            channel_rx_resp_seq::type_id::get());

    // HBUS first (program router)
    uvm_config_wrapper::set(this, "tb.hbus.masters[0].sequencer.run_phase", "default_sequence",
                            hbus_pkg::hbus_small_packet_seq::type_id::get());

    // THEN YAPP stimulus
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
                            yapp_all_ch_incr_payload_seq::type_id::get());

  endfunction : build_phase

endclass : test_uvc_integration


// ---------------- Test1 ----------------
class test1 extends base_test;
  `uvm_component_utils(test1)

  function new(string name = "test1", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
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
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
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
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // Keep same default sequence as base_test
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
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
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());

    // Set default sequence to incrementing payload seq
    uvm_config_wrapper::set(this, "tb.env.agent.sequencer.run_phase", "default_sequence",
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
    seq_lib.min_random_count = 9;  // number of sequences in yapp_seq_lib
    seq_lib.max_random_count = 9;

    // Set default sequence to library instance
    uvm_config_db#(uvm_sequence_base)::set(this, "tb.env.agent.sequencer.run_phase",
                                           "default_sequence", seq_lib);

    // Override packet type with short packet
    set_type_override_by_type(yapp_packet::get_type(), short_yapp_packet::get_type());
  endfunction

  function void end_of_elaboration_phase(uvm_phase phase);
    super.end_of_elaboration_phase(phase);  // still prints topology
    seq_lib.print();  // print sequence library for debug
  endfunction
endclass

`endif


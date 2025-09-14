// yapp_tx_seqs.sv
// Minimal sequences to generate YAPP packets

`ifndef YAPP_TX_SEQS_SV
`define YAPP_TX_SEQS_SV

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

//------------------------------------------------------
// Base sequence with objection handling
//------------------------------------------------------
class yapp_base_seq extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_base_seq)

  function new(string name = "yapp_base_seq");
    super.new(name);
  endfunction

  // Raise/drops objection automatically
  virtual task pre_body();
    if (starting_phase != null) begin
      starting_phase.raise_objection(this, 
        $sformatf("%s: Starting sequence", get_name()));
    end
  endtask

  virtual task post_body();
    if (starting_phase != null) begin
      starting_phase.drop_objection(this, 
        $sformatf("%s: Completed sequence", get_name()));
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: 5 packets
//------------------------------------------------------
class yapp_5_packets extends yapp_base_seq;

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int pkt_num = 1;
    
    `uvm_info(get_type_name(), "Starting sequence yapp_5_packets", UVM_LOW)

    repeat (5) begin
      pkt = yapp_packet::type_id::create($sformatf("pkt_%0d", pkt_num));
      start_item(pkt);
      assert(pkt.randomize()) else 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(pkt);
      pkt_num++;
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: 10 packets
//------------------------------------------------------
class yapp_10_packets extends yapp_base_seq;

  `uvm_object_utils(yapp_10_packets)

  function new(string name = "yapp_10_packets");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int pkt_num = 1;
    
    `uvm_info(get_type_name(), "Starting sequence yapp_10_packets", UVM_LOW)

    repeat (10) begin
      pkt = yapp_packet::type_id::create($sformatf("pkt_%0d", pkt_num));
      start_item(pkt);
      assert(pkt.randomize()) else 
        `uvm_error("SEQ", "Randomization failed")
      finish_item(pkt);
      pkt_num++;
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_012_seq
// Three packets with incrementing addresses 0,1,2
//------------------------------------------------------
class yapp_012_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_012_seq)

  function new(string name = "yapp_012_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int addr_val;

    `uvm_info(get_type_name(), "Starting sequence yapp_012_seq", UVM_LOW)

    for (addr_val = 0; addr_val < 3; addr_val++) begin
      pkt = yapp_packet::type_id::create($sformatf("pkt_addr_%0d", addr_val));
      start_item(pkt);
      assert(pkt.randomize() with { addr == addr_val; })
        else `uvm_error("SEQ", "Randomization failed")
      finish_item(pkt);
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_1_seq
// Single packet to address 1
//------------------------------------------------------
class yapp_1_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_1_seq)

  function new(string name = "yapp_1_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;

    `uvm_info(get_type_name(), "Starting sequence yapp_1_seq", UVM_LOW)

    pkt = yapp_packet::type_id::create("pkt_addr_1");
    start_item(pkt);
    assert(pkt.randomize() with { addr == 1; })
      else `uvm_error("SEQ", "Randomization failed")
    finish_item(pkt);
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_111_seq
// Three packets to address 1 using nested sequence yapp_1_seq
//------------------------------------------------------
class yapp_111_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_111_seq)

  function new(string name = "yapp_111_seq");
    super.new(name);
  endfunction

  virtual task body();
    `uvm_info(get_type_name(), "Starting sequence yapp_111_seq", UVM_LOW)

    repeat (3) begin
      yapp_1_seq seq1;
      seq1 = yapp_1_seq::type_id::create("nested_yapp_1_seq");
      seq1.start(m_sequencer);
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_repeat_addr_seq
// Two packets to the same random address (not 3)
//------------------------------------------------------
class yapp_repeat_addr_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_repeat_addr_seq)

  function new(string name = "yapp_repeat_addr_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    int addr_val;

    `uvm_info(get_type_name(), "Starting sequence yapp_repeat_addr_seq", UVM_LOW)

    // Choose random addr != 3
    assert(std::randomize(addr_val) with { addr_val inside {0,1,2}; });

    repeat (2) begin
      pkt = yapp_packet::type_id::create($sformatf("pkt_addr_%0d", addr_val));
      start_item(pkt);
      assert(pkt.randomize() with { addr == addr_val; })
        else `uvm_error("SEQ", "Randomization failed")
      finish_item(pkt);
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_incr_payload_seq
// One packet with payload incrementing 0..length-1
//------------------------------------------------------
class yapp_incr_payload_seq extends yapp_base_seq;

  `uvm_object_utils(yapp_incr_payload_seq)

  function new(string name = "yapp_incr_payload_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;

    `uvm_info(get_type_name(), "Starting sequence yapp_incr_payload_seq", UVM_LOW)

    `uvm_create(pkt)
    assert(pkt.randomize())
      else `uvm_error("SEQ", "Randomization failed")

    // Override payload with incrementing values
    foreach (pkt.payload[i]) begin
      pkt.payload[i] = i;
    end

    // Update parity (assuming update_parity method exists in yapp_packet)
    pkt.calc_parity();

    `uvm_send(pkt)
  endtask

endclass

//------------------------------------------------------
// Sequence: yapp_rnd_seq (Optional)
// Random number (1–10) of packets
//------------------------------------------------------
class yapp_rnd_seq extends yapp_base_seq;
  rand int count;

  constraint c_count { count inside {[1:10]}; }

  `uvm_object_utils(yapp_rnd_seq)

  function new(string name = "yapp_rnd_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    if(count==0) begin
    	assert(this.randomize());
    end

    `uvm_info(get_type_name(), $sformatf("Starting sequence yapp_rnd_seq with count=%0d", count), UVM_LOW)

    repeat (count) begin
      pkt = yapp_packet::type_id::create("rnd_pkt");
      start_item(pkt);
      assert(pkt.randomize()) else `uvm_error("SEQ", "Randomization failed")
      finish_item(pkt);
    end
  endtask

endclass

//------------------------------------------------------
// Sequence: six_yapp_seq (Optional)
// Nested yapp_rnd_seq with count constrained to six
//------------------------------------------------------
class six_yapp_seq extends yapp_base_seq;

  `uvm_object_utils(six_yapp_seq)

  function new(string name = "six_yapp_seq");
    super.new(name);
  endfunction

  virtual task body();
    yapp_rnd_seq seq_rnd;

    `uvm_info(get_type_name(), "Starting sequence six_yapp_seq", UVM_LOW)

    seq_rnd = yapp_rnd_seq::type_id::create("seq_rnd");
    assert(seq_rnd.randomize() with { count == 6; });
    seq_rnd.start(m_sequencer);
  endtask

endclass


`endif


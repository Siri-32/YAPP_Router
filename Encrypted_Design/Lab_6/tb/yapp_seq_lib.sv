//=====================================================================
// yapp_seq_lib.sv
// Sequence library for YAPP
//=====================================================================

`ifndef YAPP_SEQ_LIB_SV
`define YAPP_SEQ_LIB_SV

// UVM import
`include "uvm_macros.svh"
import uvm_pkg::*;

// Make sure all YAPP sequences and packet types are visible
//`include "../sv/yapp.svh"        // contains yapp_packet and base classes
`include "../sv/yapp_tx_seqs.sv"       // contains yapp_5_packets, yapp_10_packets, etc.

// --------------------------------------------------------------------
// Sequence Library Class
// --------------------------------------------------------------------
class yapp_seq_lib extends uvm_sequence_library #(yapp_packet);

  `uvm_object_utils(yapp_seq_lib)

  // Constructor
  function new(string name = "yapp_seq_lib");
    super.new(name);
    // Add sequences to library
    add_sequence(yapp_5_packets::get_type());
    add_sequence(yapp_10_packets::get_type());
    add_sequence(yapp_012_seq::get_type());
    add_sequence(yapp_1_seq::get_type());
    add_sequence(yapp_111_seq::get_type());
    add_sequence(yapp_repeat_addr_seq::get_type());
    add_sequence(yapp_incr_payload_seq::get_type());
    add_sequence(yapp_rnd_seq::get_type());
    add_sequence(six_yapp_seq::get_type());
  endfunction

endclass

`endif // YAPP_SEQ_LIB_SV


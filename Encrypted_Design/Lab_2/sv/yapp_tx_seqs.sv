// yapp_tx_seqs.sv
// Minimal sequence to generate 5 YAPP packets

`ifndef YAPP_TX_SEQS_SV
`define YAPP_TX_SEQS_SV

// Import UVM
import uvm_pkg::*;
`include "uvm_macros.svh"

// Make sure yapp_packet.sv is included before this file in your yapp.svh
class yapp_5_packets extends uvm_sequence #(yapp_packet);

  `uvm_object_utils(yapp_5_packets)

  function new(string name = "yapp_5_packets");
    super.new(name);
  endfunction

  virtual task body();
    yapp_packet pkt;
    
    int pkt_num = 1;

  repeat (5) begin
    pkt = yapp_packet::type_id::create($sformatf("pkt_%0d", pkt_num));
    start_item(pkt);
    assert(pkt.randomize());
    finish_item(pkt);
    pkt_num++;

    /*repeat (5) begin
      pkt = yapp_packet::type_id::create("pkt");
      assert(pkt.randomize()) else `uvm_error("SEQ", "Randomization failed")
      `uvm_info("SEQ", $sformatf("Generated packet:\n%s", pkt.sprint()), UVM_LOW)
      start_item(pkt);
      finish_item(pkt);*/
    end
  endtask

endclass

`endif


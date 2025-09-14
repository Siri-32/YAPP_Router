// yapp_tx_sequencer.sv
`ifndef YAPP_TX_SEQUENCER_SV
`define YAPP_TX_SEQUENCER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

class yapp_tx_sequencer extends uvm_sequencer #(yapp_packet);
  
  `uvm_component_utils(yapp_tx_sequencer)

  function new(string name = "yapp_tx_sequencer", uvm_component parent = null);
    super.new(name, parent);
  endfunction

endclass

`endif


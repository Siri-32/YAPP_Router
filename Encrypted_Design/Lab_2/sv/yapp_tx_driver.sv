`ifndef YAPP_TX_DRIVER_SV
`define YAPP_TX_DRIVER_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
`include "yapp_packet.sv"

class yapp_tx_driver extends uvm_driver #(yapp_packet);
  `uvm_component_utils(yapp_tx_driver)

  function new(string name = "yapp_tx_driver", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    forever begin
      seq_item_port.get_next_item(req);
      send_to_dut(req);
      seq_item_port.item_done();
    end
  endtask

  task send_to_dut(yapp_packet pkt);
    `uvm_info("YAPP_TX_DRIVER", $sformatf("Packet is \n%s", pkt.sprint()), UVM_LOW)
  endtask
endclass

`endif // YAPP_TX_DRIVER_SV


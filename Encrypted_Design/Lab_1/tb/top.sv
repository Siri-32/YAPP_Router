import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../sv/yapp_packet.sv"
 
module top;
 
  yapp_packet yp;
 
  initial begin
    yp = new("yp");
    for (int i = 0; i < 5; i++) begin
      `uvm_info("YP_NO", $sformatf("YAPP Packet number %0d", i + 1), UVM_LOW)
      yp.randomize();
      yp.print();
      yp.print(uvm_default_tree_printer);
    end
  end
 
endmodule

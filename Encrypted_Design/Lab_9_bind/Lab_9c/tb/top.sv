import uvm_pkg::*;
`include "uvm_macros.svh"
`include "yapp_test_lib.sv"

module top;

  // Clock and Reset signals
  logic clock;
  logic reset;

  // Instantiate the YAPP interface
  yapp_if yapp_vif (clock, reset);

  // Clock generator
  initial begin
    clock = 0;
    forever #5 clock = ~clock;   // 100MHz clock
  end

  // Reset generator
  initial begin
    reset = 1;
    #20 reset = 0;               // Deassert reset after 20 time units
  end

  // Connect virtual interface into UVM config_db
  initial begin
    uvm_config_db#(virtual yapp_if)::set(null, "*", "vif", yapp_vif);
  end

  // Start the UVM test
  initial begin
    run_test();
  end

endmodule


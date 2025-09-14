/*import uvm_pkg::*;
`include "uvm_macros.svh"
`include "../sv/yapp.svh"  // path from tb to sv directory

module top;

  // Declare environment handle
  yapp_env env;

  // Construct the environment
  initial begin
    env = new("env", null); // name + parent (top has no parent)
  end

  // Call the built-in run_test() task
  initial begin
    run_test();
  end
endmodule
*/


import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "../sv/yapp.svh"  // Includes all your UVC components + sequences
`include "yapp_test_lib.sv"
module top;

  // Declare the environment handle
  /*yapp_env env;

  initial begin
    // Build the environment
    env = new("env", null);
  end

    // Set the default sequence for the sequencer
    // Change the path if your printed hierarchy showed something else
  initial begin
    uvm_config_wrapper::set(null, "env.agent.sequencer.run_phase",
                            "default_sequence",
                            yapp_5_packets::type_id::get());
    // Start the UVM test
    run_test();
  end*/
  
  initial begin
  	run_test();
  end

endmodule


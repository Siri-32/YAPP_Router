// yapp_env.sv
import uvm_pkg::*;
`include "uvm_macros.svh"
//`include "yapp_tx_agent.sv"

/*class yapp_env extends uvm_env;
  `uvm_component_utils(yapp_env)

  // Handle for agent
  yapp_tx_agent agent;

  // Constructor
  function new(string name = "yapp_env", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // Build phase
  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction

  // Run phase
  task run_phase(uvm_phase phase);
    super.run_phase(phase);
    `uvm_info("ENV", "Printing Environment Details:", UVM_LOW)
    this.print();
  endtask
endclass
*/


class yapp_env extends uvm_env;
  `uvm_component_utils(yapp_env)

  yapp_tx_agent agent;

  function new(string name, uvm_component parent);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    super.build_phase(phase);
    agent = yapp_tx_agent::type_id::create("agent", this);
  endfunction

  function void start_of_simulation_phase(uvm_phase phase);
    super.start_of_simulation_phase(phase);
    `uvm_info(get_type_name(), "start_of_simulation_phase called", UVM_HIGH)
  endfunction
endclass



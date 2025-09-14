`ifndef ROUTER_TB_SV
`define ROUTER_TB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "../sv/yapp_env.sv"

class router_tb extends uvm_component;
  `uvm_component_utils(router_tb)

  yapp_env env;

  function new(string name = "router_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  function void build_phase(uvm_phase phase);
    // enable transaction recording before parent build
    set_config_int("*", "recording_detail", 1);

    super.build_phase(phase);

    env = yapp_env::type_id::create("env", this);
  endfunction

endclass

`endif  // ROUTER_TB_SV


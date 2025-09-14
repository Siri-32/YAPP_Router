
`ifndef ROUTER_TB_SV
`define ROUTER_TB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;

// ------------------------------------------------------
// UVC Includes
// (these bring in env typedefs for channel and hbus)
// ------------------------------------------------------
//`include "../../channel/sv/channel.svh"  // channel_env typedef
//`include "../../hbus/sv/hbus.svh"  // hbus_env typedef
//`include "../../yapp/sv/yapp.svh"  // yapp_env typedef

// ------------------------------------------------------
// Testbench top-level component
// ------------------------------------------------------
class router_tb extends uvm_component;
  `uvm_component_utils(router_tb)

  // -------------------------
  // UVC handles
  // -------------------------
  yapp_env    env;    // YAPP environment
  channel_env ch_env0;    // Channel 0 env
  channel_env ch_env1;    // Channel 1 env
  channel_env ch_env2;    // Channel 2 env
  hbus_env    hbus;  // HBUS environment

  // -------------------------
  // Constructor
  // -------------------------
  function new(string name = "router_tb", uvm_component parent = null);
    super.new(name, parent);
  endfunction

  // -------------------------
  // Build phase
  // -------------------------
  function void build_phase(uvm_phase phase);
    // Enable transaction recording
    set_config_int("*", "recording_detail", 1);

    super.build_phase(phase);

    // Create all envs using factory
    env = yapp_env::type_id::create("env", this);
    ch_env0 = channel_env::type_id::create("ch_env0", this);
    ch_env1 = channel_env::type_id::create("ch_env1", this);
    ch_env2 = channel_env::type_id::create("ch_env2", this);
    hbus = hbus_env::type_id::create("hbus", this);

    // Configure channel envs → RX only (disable TX)
    set_config_int("ch_env*", "has_tx", 0);
    set_config_int("ch_env*", "has_rx", 1);

    // Configure HBUS env → 1 master, 0 slaves
    set_config_int("hbus", "num_masters", 1);
    set_config_int("hbus", "num_slaves", 0);
  endfunction

endclass

`endif  // ROUTER_TB_SV



`ifndef ROUTER_TB_SV
`define ROUTER_TB_SV

`include "uvm_macros.svh"
import uvm_pkg::*;
//`include "router_virtual_sequencer.sv"

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

  router_virtual_sequencer vseqr;
  router_module_env r;

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

    vseqr = router_virtual_sequencer::type_id::create("vseqr", this);
    r = router_module_env::type_id::create("r", this);
  endfunction

  function void connect_phase(uvm_phase phase);
    //super.connect_phase(phase);

    // Connect virtual sequencer handles to UVC sequencers
    vseqr.hbus_sequencer = hbus.masters[0].sequencer;  // HBUS master sequencer
    vseqr.yapp_sequencer = env.agent.sequencer;  // YAPP sequencer
    // Connect the TLM ports from the YAPP and Channel UVCs to the scoreboard
    if (env == null) `uvm_fatal("CONNECT", "env is null")
    if (env.agent == null) `uvm_fatal("CONNECT", "env.agent is null")
    if (env.agent.monitor == null) `uvm_fatal("CONNECT", "env.agent.monitor is null")
    if (env.agent.monitor.item_collected_port == null)
      `uvm_fatal("CONNECT", "monitor.item_collected_port is null")

    if (r == null) `uvm_fatal("CONNECT", "scoreboard r is null")
    if (r.router_yapp == null) `uvm_fatal("CONNECT", "r.router_yapp (analysis export/imp) is null")

    env.agent.monitor.item_collected_port.connect(r.router_yapp);
    ch_env0.rx_agent.monitor.item_collected_port.connect(r.router_chan0);
    ch_env1.rx_agent.monitor.item_collected_port.connect(r.router_chan1);
    ch_env2.rx_agent.monitor.item_collected_port.connect(r.router_chan2);
    hbus.masters[0].monitor.item_collected_port.connect(r.router_hbus);

  endfunction : connect_phase


endclass

`endif  // ROUTER_TB_SV


// yapp.svh
// Common typedefs and includes for YAPP UVC

// Typedef for configuration database with virtual yapp_if
//`include "yapp_if.sv"
typedef uvm_config_db#(virtual yapp_if) yapp_vif_config;

// Include all YAPP UVC component definitions
`include "yapp_packet.sv"
`include "yapp_tx_monitor.sv"
`include "yapp_tx_sequencer.sv"
`include "yapp_tx_seqs.sv"     // Supplied sequence file
`include "yapp_tx_driver.sv"
`include "yapp_tx_agent.sv"
`include "yapp_env.sv"


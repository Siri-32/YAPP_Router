//======================================================
// top_dut.sv
// Testbench top module WITH the DUT (yapp_router)
//======================================================

`timescale 1ns / 1ps

// UVM import
import uvm_pkg::*;
`include "uvm_macros.svh"

// ------------------------------------------------------
// Includes for YAPP UVC, sequence library, router_tb, and test library
// ------------------------------------------------------
`include "../../yapp/sv/yapp.svh"  // YAPP UVC components + typedef
`include "../../channel/sv/channel.svh"
`include "../../hbus/sv/hbus_pkg.svp"
import hbus_pkg::*;
`include "yapp_seq_lib.sv"
`include "router_tb.sv"  // Testbench wrapper (contains yapp_env)
`include "router_test_lib.sv"  // Test library with base_test, etc.
// ------------------------------------------------------
// Top-level testbench module WITH DUT
// ------------------------------------------------------
module top_dut;

  // -------------------------
  // Clock & Reset
  // -------------------------
  logic clock;
  logic reset;

  // DUT error signal
  logic error;

  // -------------------------
  // Instantiate Interfaces
  // -------------------------
  // YAPP Input/Output
  yapp_if in0 (
      .clock(clock),
      .reset(reset)
  );

  // HBUS interface (host programming bus)
  hbus_if hif (
      .clock(clock),
      .reset(reset)
  );

  // Three channel interfaces (for router outputs)
  channel_if ch0 (
      .clock(clock),
      .reset(reset)
  );

  channel_if ch1 (
      .clock(clock),
      .reset(reset)
  );

  channel_if ch2 (
      .clock(clock),
      .reset(reset)
  );

  // -------------------------
  // Clock generation
  // -------------------------
  initial begin
    clock = 0;
    forever #5 clock = ~clock;  // 100 MHz clock (10ns period)
  end

  // -------------------------
  // Reset generation
  // -------------------------
  initial begin
    reset = 1;
    #20 reset = 0;  // release reset after 20ns
  end

  // -------------------------
  // DUT Instantiation
  // -------------------------
  yapp_router dut (
      .clock(clock),
      .reset(reset),
      .error(error),

      // YAPP input interface
      .in_data    (in0.in_data),
      .in_data_vld(in0.in_data_vld),
      .in_suspend (in0.in_suspend),

      // Output channel 0
      .data_0    (ch0.data),
      .data_vld_0(ch0.data_vld),
      .suspend_0 (ch0.suspend),

      // Output channel 1
      .data_1    (ch1.data),
      .data_vld_1(ch1.data_vld),
      .suspend_1 (ch1.suspend),

      // Output channel 2
      .data_2    (ch2.data),
      .data_vld_2(ch2.data_vld),
      .suspend_2 (ch2.suspend),

      // HBUS interface
      .haddr (hif.haddr),
      .hdata (hif.hdata_w),
      .hen   (hif.hen),
      .hwr_rd(hif.hwr_rd)
  );

  // -------------------------
  // Config DB setup
  // -------------------------
  initial begin
    // Set virtual interfaces into config DB
    yapp_vif_config::set(null, "*.tb.env.agent.*", "vif", in0);
    hbus_vif_config::set(null, "*.tb.hbus.*", "vif", hif);
    channel_vif_config::set(null, "*.ch_env0*", "vif", ch0);
    channel_vif_config::set(null, "*.ch_env1*", "vif", ch1);
    channel_vif_config::set(null, "*.ch_env2*", "vif", ch2);

    // Start UVM test
    run_test();
    $finish;
  end

endmodule

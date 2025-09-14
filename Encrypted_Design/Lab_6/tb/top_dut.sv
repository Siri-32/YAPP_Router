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
`include "../sv/yapp.svh"  // YAPP UVC components + typedef
`include "yapp_seq_lib.sv"
`include "router_tb.sv"  // Testbench wrapper (contains yapp_env)
`include "router_test_lib.sv"  // Test library with base_test, etc.

// ------------------------------------------------------
// Top-level testbench module WITH DUT
// ------------------------------------------------------
module top_dut;

  // -------------------------
  // Signal declarations
  // -------------------------
  logic       clock;
  logic       reset;

  // DUT output/error
  logic       error;

  // Host interface signals (tie off for now)
  logic [7:0] haddr;
  tri   [7:0] hdata;  // inout
  logic       hen;
  logic       hwr_rd;

  // -------------------------
  // Instantiate the YAPP interface
  // -------------------------
  yapp_if in0 (
      clock,
      reset
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

      // Input channel connections from yapp_if
      .in_data    (in0.in_data),
      .in_data_vld(in0.in_data_vld),
      .in_suspend (in0.in_suspend),

      // Output channels connected back to interface
      .data_0    (in0.data_0),
      .data_vld_0(in0.data_vld_0),
      .suspend_0 (1'b0),            // Always allow packets

      .data_1    (in0.data_1),
      .data_vld_1(in0.data_vld_1),
      .suspend_1 (1'b0),            // Always allow packets

      .data_2    (in0.data_2),
      .data_vld_2(in0.data_vld_2),
      .suspend_2 (1'b0),            // Always allow packets

      // Host interface — tie off for now
      .haddr (haddr),
      .hdata (hdata),
      .hen   (hen),
      .hwr_rd(hwr_rd)
  );

  // -------------------------
  // Config DB setup
  // Write virtual interface into the config DB
  // -------------------------
  initial begin
    // Default host interface values
    haddr  = '0;
    hen    = 0;
    hwr_rd = 0;

    yapp_vif_config::set(null, "*", "vif", in0);
    run_test();  // start UVM test
    $finish;
  end

endmodule


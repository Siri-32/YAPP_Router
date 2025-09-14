//======================================================
// top_no_dut.sv
// Initial simulation without the DUT
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
//`include "../sv/yapp_tx_seqs.sv"     // YAPP sequence library
`include "router_tb.sv"  // Testbench wrapper (contains yapp_env)
`include "router_test_lib.sv"  // Test library with base_test, etc.

// ------------------------------------------------------
// Top-level testbench module without DUT
// ------------------------------------------------------
module top_no_dut;

  // -------------------------
  // Signal declarations
  // -------------------------
  logic clock;
  logic reset;
  //logic in_suspend;

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
  // Suspend signal generation
  // -------------------------
  initial begin
    in0.in_suspend = 0;  // default not suspended
  end

  // -------------------------
  // Config DB setup
  // Write virtual interface into the config DB
  // -------------------------
  initial begin
    yapp_vif_config::set(null, "*", "vif", in0);
    run_test();  // start UVM test
    $finish;
  end

endmodule


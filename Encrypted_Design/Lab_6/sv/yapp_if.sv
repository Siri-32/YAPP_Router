/*-----------------------------------------------------------------
File name     : yapp_if.sv
Description   : YAPP interface to DUT
Notes         : Modified for lab6 as per DUT port naming
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/

interface yapp_if (input clock, input reset );

  // DUT Signals
  logic       [7:0]  in_data;       // payload data to DUT
  logic              in_data_vld;   // data valid indicator
  logic              in_suspend;    // backpressure/suspend signal

  // Control flags (used by TB for checks/coverage)
  bit                has_checks = 1;
  bit                has_coverage = 1;

endinterface : yapp_if


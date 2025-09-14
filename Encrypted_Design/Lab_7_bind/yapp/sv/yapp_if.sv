/*-----------------------------------------------------------------
File name     : yapp_if.sv
Description   : YAPP interface to DUT
Notes         : Modified for lab6 as per DUT port naming
-------------------------------------------------------------------
Copyright Cadence Design Systems (c)2009 
-----------------------------------------------------------------*/


/*-----------------------------------------------------------------
File name     : yapp_if.sv
Description   : YAPP interface to DUT (with outputs)
-----------------------------------------------------------------*/
interface yapp_if (
    input clock,
    input reset
);

  // DUT input signals
  logic [7:0] in_data;  // payload data to DUT
  logic       in_data_vld;  // data valid indicator
  logic       in_suspend;  // backpressure/suspend signal

  // DUT output channel 0
  logic [7:0] data_0;
  logic       data_vld_0;

  // DUT output channel 1
  logic [7:0] data_1;
  logic       data_vld_1;

  // DUT output channel 2
  logic [7:0] data_2;
  logic       data_vld_2;

  // Control flags (used by TB for checks/coverage)
  bit         has_checks = 1;
  bit         has_coverage = 1;

endinterface : yapp_if


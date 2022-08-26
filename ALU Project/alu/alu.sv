`default_nettype none
`timescale 1ns/1ns

module alu
  #(parameter int data_width = 12,
    parameter int instruction_width = 12)
   (// A rising edge should trigger clocked logic
    input wire clk,

    // Active high reset
    input wire                         rst,

    // Instructions for the ALU to perform, a new instruction will be
    // given each clock cycle.
    input wire [instruction_width-1:0] instruction,

    // Data output from the ALU, its value is considered undefined if
    // out_valid is deasserted.
    output logic [data_width-1:0]      out_data,
    output logic                       out_valid,

    // Stop execution if asserted
    output logic                       halt);

    // The ALU should have four 12 bits general purpose register.
    localparam int num_registers = 4;

    // Your code here...
endmodule

// DO NOT REMOVE THE FOLLOWING LINES OR PUT ANY CODE/COMMENTS AFTER THIS LINE
// hw_intern_test-20211014.zip
// f8bca07d96076ae1722bbdd9fb32c5aef1860677

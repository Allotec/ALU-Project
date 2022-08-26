`default_nettype none
`timescale 1ns/1ns

module instruction_fetch
  #(parameter int instruction_width = 12,
    parameter int program_mem_depth = 1024)
   (input logic clk,
    input logic                          rst,
    output logic [instruction_width-1:0] instruction);

    logic [$clog2(program_mem_depth)-1:0] pc;

    always @(posedge clk) begin
        if (rst) pc <= '0;
        else pc <= pc + 1'b1;
    end

    logic [instruction_width-1:0] pm [0:program_mem_depth-1];

`ifdef PROGRAM_TEST
    initial $readmemh("test.hex", pm);
`else
    initial $readmemh("secret.hex", pm);
`endif

    assign instruction = pm[pc];

endmodule

module alu_tb ();
    logic          clk;
    logic          rst;

    localparam int instruction_width = 12;
    localparam int data_width = 12;

    logic [data_width-1:0] out_data;
    logic                  out_valid;
    logic                  halt;

    logic [instruction_width-1:0] instruction;

    localparam int cc = 10;

    always #(cc/2) clk = ~clk;

    initial begin
        rst = '0;
        clk = '1;
        #3;
        #cc;
        rst = '1;
        #(cc*2);
        rst = '0;
    end

    instruction_fetch
      #(.instruction_width(instruction_width))
    fetch
        (.clk,
         .rst,
         .instruction(instruction));

    alu
      #(.data_width(data_width),
        .instruction_width(instruction_width))
    dut
       (.clk,
        .rst,
        .instruction,
        .out_data,
        .out_valid,
        .halt);

    always @(posedge clk) begin
        if(out_valid) begin
            $write("ALU: 0x%03h", out_data);
            if (out_data > 'h20 && out_data < 'h7E) begin
                $write(" [%c]", out_data[7:0]);
            end
            $write("\n");
            if (halt) begin
                $display("ALU: END");
                $finish;
            end
        end
    end

    initial begin
`ifdef PROGRAM_TEST
        $dumpfile("test.fst");
`else
        $dumpfile("secret.fst");
`endif
        $dumpvars;
    end
endmodule

`default_nettype none
`timescale 1ns/1ns

/*
Icarus Verilog Version 10.3 (stable)

Questions 
1. There are no NOP (don’t change any register values) or CLEAR (set a register to 0) instructions specified, how can
we perform these operations with the instructions we have available to us?

With the ISA given the NOP instruction can be performed by adding or subtraction zero from a register. The Clear instruction
can be performed by XORing a register with itself.

2. How did you test your design?

My design is a structural design with multiple modules so I tested them individually first with simple testbenches to make 
sure they had the functionality I wanted before putting them all together into one file.

*/

module alu
  #(parameter data_width = 12,
  parameter instruction_width = 12)
  (// A rising edge should trigger clocked logic
  input wire clk,

  // Active high reset
  input wire rst,

  // Instructions for the ALU to perform, a new instruction will be
  // given each clock cycle.
  input wire [instruction_width - 1:0] instruction,

  // Data output from the ALU, its value is considered undefined if
  // out_valid is deasserted.
  output logic [data_width - 1:0] out_data,
  output logic out_valid,

  // Stop execution if asserted
  output logic halt
  );

  //Local wires for internal connections
  wire [3:0] opCode;
  wire [5:0] immediate;
  wire [1:0] RxAddress, RyAddress, RdAddress, RdAddr; 
  wire [instruction_width - 1: 0] RxVal, RyVal, RdVal, Rx, Ry, outData, RdData;
  wire outValid, haltWire, regWrite;

  //Module Instantiation 
  InstructionDecoder u0 (instruction, opCode, immediate, RxAddress, RyAddress, RdAddress);
  RegisterFile u1 (RxAddress, RyAddress, RdAddress, rst, clk, RdAddr, RdData, regWrite, RxVal, RyVal, RdVal);
  ArithmeticInputDecoder u2 (opCode, immediate, RxVal, RyVal, RdVal, Rx, Ry);
  ArithmeticLogicUnit u3 (Rx, Ry, opCode, outData, outValid, haltWire);
  writeBackRegister u4 (outData, outValid, haltWire, RdAddress, clk, RdAddr, RdData, regWrite);
  

  //Output for the top level block
  always @(outValid, haltWire) begin
      out_valid <= outValid;
      out_data <= outData;
      halt <= haltWire;
  end

endmodule


//Module to Decode Instruction into its Components (Combinational)
module InstructionDecoder
  #(parameter instruction_width = 12)(
  input wire [instruction_width - 1:0] instruction,

  output wire [3:0] opCode,
  output wire [5:0] immediate,
  output wire [1:0] RxAddress,
  output wire [1:0] RyAddress,
  output wire [1:0] RdAddress
  );

  assign opCode = instruction[instruction_width - 1:8];
  assign immediate = instruction[5:0];
  assign RxAddress = instruction[5:4];
  assign RyAddress = instruction[3:2];
  assign RdAddress = instruction[7:6];

endmodule


//Module to Hold the Registers with Bypass (Combinational Read and Sequential Write)
module RegisterFile
  #(parameter data_width = 12,
  parameter instruction_width = 12)
  (
  input wire [1:0] RxAddress,
  input wire [1:0] RyAddress,
  input wire [1:0] RdAddress,
  input wire reset,
  input wire clk,
  input wire [1:0] addressIn,
  input wire [data_width - 1:0] dataIn,
  input wire regWrite,

  output reg [data_width - 1:0] RxVal,
  output reg [data_width - 1:0] RyVal,
  output reg [data_width - 1:0] RdVal
);
  
  localparam num_registers = 4;
  reg [data_width - 1:0] registers [num_registers - 1:0];
  integer i;

  always @(RxAddress, RyAddress, RdAddress, reset, dataIn, addressIn) begin
    //Writing to output port RxVal with bypass
    if (RxAddress == addressIn && regWrite == 1'd1) begin
      RxVal <= dataIn;
    end
    else begin 
      RxVal <= registers[RxAddress];
    end

    //Writing to output port RyVal with bypass
    if (RyAddress == addressIn && regWrite == 1'd1) begin
      RyVal <= dataIn;
    end
    else begin 
      RyVal <= registers[RyAddress];
    end

    //Writing to output port RdVal with bypass
    if (RdAddress == addressIn && regWrite == 1'd1) begin
      RdVal <= dataIn;
    end
    else begin 
      RdVal <= registers[RdAddress];
    end
  end

  //On the positive clock edge update one of the registers
  always @(posedge clk) begin
    if (reset == 1'd1) begin
      for (i = 0; i < num_registers; i++) begin
        registers[i] <= 0; 
      end
    end
    else if (regWrite == 1'd1) begin
      registers[addressIn] <= dataIn;
    end
  end

endmodule 


//Module to Put the Correct Values into the ArithmeticLogicUnit (Combinational)
module ArithmeticInputDecoder 
  #(parameter data_width = 12)(
  input wire [3:0] opCode,
  input wire [5:0] immediate,
  input wire [data_width - 1:0] RxVal,
  input wire [data_width - 1:0] RyVal,
  input wire [data_width - 1:0] RdVal,

  output reg [data_width - 1:0] Rx,
  output reg [data_width - 1:0] Ry
  );

  always @* begin
    //Special case for Load Low and Load High
    if (opCode == 4'd10 || opCode == 4'd11) begin
      Rx[data_width - 1:6] <= 6'd0;
      Rx[5:0] <= immediate;
      
      Ry <= RdVal;
    end 
    //Case for all other Instructions
    else begin
      Rx <= RxVal;
      Ry <= RyVal;
    end
  end

endmodule


//Module to Perform the Operations (Combinational except for the carry which is a register)
module ArithmeticLogicUnit 
  #(parameter data_width = 12)
  (
  input wire [data_width - 1:0] Rx,
  input wire [data_width - 1:0] Ry,
  input wire [3:0] opCode,
  
  output reg [data_width - 1:0] outData,
  output reg outValid,
  output reg halt
  );

  reg c = 0;
  //Used to check for carry
  reg [data_width - 1:0] sum;
  integer i = 0;

  always @(Rx, Ry, opCode) begin
      //Assumes not halting and not valid data unless OUT or HALT
      halt <= 1'd0;
      outValid <= 1'd0;

      //OR
      if(opCode == 4'd0) begin
        outData <= Rx | Ry;
      end
      //XOR
      else if(opCode == 4'd1) begin
        outData <= Rx ^ Ry;
      end
      //AND
      else if(opCode == 4'd2) begin
        outData <= Rx & Ry;
      end
      //NOT
      else if(opCode == 4'd3) begin
        outData <= ~Rx;
      end
      //Left Shift Logical
      else if(opCode == 4'd4) begin
        outData <= Rx << 1;
      end
      //Right Shift Logical
      else if(opCode == 4'd5) begin
        outData <= Rx >> 1;
      end
      //Right Shift Arithmetic 
      else if(opCode == 4'd6) begin
        outData <= $signed(Rx) >>> 1;

      end
      //Add and Update Carry
      else if(opCode == 4'd7) begin
        sum <= Rx + Ry;
        i <= Rx + Ry;
        outData <= Rx + Ry;
        
        //Carry update
        //Checks if a 12 bit casted sum is the same as a non casted sum
        if(i != sum) begin
          c <= 1'd1;
        end
        else begin 
          c <= 1'd0;
        end
      end
      //Add with and Update Carry
      else if(opCode == 4'd8) begin
        sum <= Rx + Ry + c;
        i <= Rx + Ry + c;
        outData <= Rx + Ry + c;

        //Carry Update
        //Checks if a 12 bit casted sum is the same as a non casted sum
        if(i != sum) begin
          c <= 1'd1;
        end
        else begin 
          c <= 1'd0;
        end

      end
      //SUB
      else if(opCode == 4'd9) begin
        outData <= Rx - Ry;
      end
      //Load Lower
      else if(opCode == 4'd10) begin //Immediate goes in the bottom 6 bits of the Rx port
        outData[data_width - 1:6] <= Ry[data_width - 1:6];
        outData[5:0] <= Rx[5:0];
      end
      //Load High
      else if(opCode == 4'd11) begin //Immediate goes in the bottom 6 bits of the Rx port
        outData[data_width - 1:6] <= Rx[5:0];
        outData[5:0] <= Ry[data_width - 1:6];
      end
      //Out
      else if(opCode == 4'd12) begin 
        outData <= Rx;
        outValid <= 1'd1;
      end
      //Halt
      else if(opCode == 4'd13) begin 
        outData <= Rx;
        outValid <= 1'd1;
        halt <= 1'd1;
      end
    end
  
endmodule


//Module to save the contents of a pipeline stage and pass it on the next clock cycle (Sequential)
module writeBackRegister 
  #(parameter data_width = 12)
  (
  input wire [data_width - 1:0] outData,
  input wire outValid,
  input wire halt,
  input wire [1:0] RdAddress,
  input wire clk,

  output reg [1:0] RdAddr,
  output reg [data_width - 1:0] RdData,
  output reg regWrite
);

  always @(posedge clk) begin
    RdAddr <= RdAddress;
    RdData <= outData;
    regWrite <= ~outValid;
  end
  
endmodule

// DO NOT REMOVE THE FOLLOWING LINES OR PUT ANY CODE/COMMENTS AFTER THIS LINE
// hw_intern_test-20211014.zip
// f8bca07d96076ae1722bbdd9fb32c5aef1860677

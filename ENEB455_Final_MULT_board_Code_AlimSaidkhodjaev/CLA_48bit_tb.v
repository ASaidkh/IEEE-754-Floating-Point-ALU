`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 01:31:35 PM
// Design Name: 
// Module Name: CLA_48bit_tb
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////


`timescale 1ns / 1ps

module CLA_48bit_tb;

  // Inputs
  reg [47:0] A, B;
  reg Cin;

  // Outputs from the DUT
  wire [47:0] Sum;
  wire Cout;

  // Internal
  reg [47:0] ExpectedSum;
  reg ExpectedCarry;
  integer i;
  integer error_count = 0;
  integer test_count = 0;

  // Instantiate the DUT
  CLA_48bit uut (
    .A(A),
    .B(B),
    .C0(Cin),
    .Sum(Sum),
    .Cout(Cout)
  );

  initial begin
    $display("Starting 48-bit Tree CLA random testbench...");

    for (i = 0; i < 1000000; i = i + 1) begin
      // Generate random inputs
      A = $random;
      B = $random;
      Cin = $random % 2;

      // Calculate expected result using built-in Verilog arithmetic
      {ExpectedCarry,ExpectedSum} = A + B + Cin;

      #1; // Wait for combinational logic to settle

      // Check result
      if ({Cout, Sum} != {ExpectedCarry,ExpectedSum}) begin
        $display("? Mismatch at test %0d", i);
        $display("   A      = 0x%h", A);
        $display("   B      = 0x%h", B);
        $display("   Cin    = %b", Cin);
        $display("   Sum    = 0x%h (Expected: 0x%h)", Sum, ExpectedSum);
        $display("   Cout   = %b (Expected: %b)", Cout, ExpectedCarry);
        error_count = error_count + 1;
      end

      test_count = test_count + 1;
    end

    $display("? Testing complete: %0d tests run", test_count);
    $display("48-bit CPA Adder Tests:\n %0d Errors\n %0d/%0d Cases Passed ",
            error_count, (test_count - error_count), test_count);
    
    $finish;
  end

endmodule
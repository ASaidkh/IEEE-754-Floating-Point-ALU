`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 01:26:10 PM
// Design Name: 
// Module Name: Booth_Wallace_24bit_tb
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

module tb_Booth_Wallace_24bit;

    // Inputs
    reg [23:0] A;
    reg [23:0] B;

    // Output
    wire [47:0] P;

    // Instantiate the Unit Under Test (UUT)
    Booth_Wallace_24bit uut (
        .A(A),
        .B(B),
        .P(P)
    );

    integer i;
    integer error_count = 0;
    integer test_count = 0;
    reg [47:0] expected;

    initial begin
        $display("Starting randomized testbench for Booth_Wallace_24bit...");
        error_count = 0;
        test_count = 0;

        for (i = 0; i < 1000000; i = i + 1) begin
            // Generate random 24-bit inputs
            A = $random;
            B = $random;
            test_count = test_count +1;
            // Mask to 24 bits in case $random gives >24-bit values
            A = A & 24'hFFFFFF;
            B = B & 24'hFFFFFF;
             // Expected result
            expected <= A * B;
                        // Compare result
            if (P != expected) begin
                error_count = error_count + 1;
                $display("ERROR #%0d: A = 0x%h, B = 0x%h | Expected = 0x%h, Got = 0x%h", error_count, A, B, expected, P);
            end
            // Wait for output to settle
            #1;

        end

        $display("\n=============================");
        $display("24-bit Booth-Wallace Multiplier Test Complete.");
        $display("Total Tests Run  : %0d", i);
        $display("Total Errors     : %0d", error_count);
        $display("Pass Rate        : %0.2f%%", 100.0 * (i - error_count) / i);
        $display("=============================\n");
        
        $finish;
    end

endmodule


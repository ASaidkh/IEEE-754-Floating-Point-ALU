`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2025 05:09:46 PM
// Design Name: 
// Module Name: TwosComplement24bit_tb
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


`timescale 1ns/1ps

module TwosComplement24bit_tb;

    reg  [23:0] in;        // Input to DUT
    wire [23:0] out;       // Output from DUT
    reg  [23:0] expected;  // Expected output
    integer i;             // Loop counter
    integer error_count;   // Error counter

    // Instantiate the DUT
    TwosComplement24bit dut (
        .in(in),
        .out(out)
    );

    initial begin
        error_count = 0;

        // Test 10,000 random cases
        for (i = 0; i < 10000; i = i + 1) begin
            #1;
            in = $random;               // Generate random 32-bit, use low 24 bits
            in = in[23:0];
            expected = (~in) + 24'd1;    // Compute expected result
            #1
            if (out !== expected) begin
                $display("ERROR at time %0dns: in = %h, out = %h, expected = %h", $time, in, out, expected);
                error_count = error_count + 1;
            end
            
        end

        // Final result
        if (error_count == 0)
            $display("Test PASSED: No errors found.");
        else
            $display("Test FAILED: %0d errors found.", error_count);

        $finish;
    end

endmodule


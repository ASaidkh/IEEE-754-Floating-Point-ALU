`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2025 08:49:47 AM
// Design Name: 
// Module Name: ExponentAdder
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
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2025
// Design Name: 3-input 8-bit Adder
// Module Name: CLA_8_bit_3in
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: 
//      Adds three 8-bit inputs: A + B + C
// 
// Dependencies: 
//      Requires Tree_CLA_8bit module
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
// 
//////////////////////////////////////////////////////////////////////////////////

module ExponentAdder (
    input  wire [8:0] A,      // 9-bit input A
    input  wire [8:0] B,      // 9-bit input B
    input  wire [8:0] C,      // 9-bit input C
    input  wire       C0,     // Carry-in
    output wire [8:0] Sum,    // 9-bit sum
    output wire       Cout    // Carry-out
);

    wire [8:0] partial_sum1, partial_sum2;
    wire carry_out1, carry_out2;
    
    // First CLA adder: Add A and B
    CLA_9bit cla1 (
        .A(A),
        .B(B),
        .C0(C0),
        .Sum(partial_sum1),
        .Cout(carry_out1)
    );
    
    // Second CLA adder: Add the partial_sum1 and C
    CLA_9bit cla2 (
        .A(partial_sum1),
        .B(C),
        .C0(carry_out1),
        .Sum(Sum),
        .Cout(carry_out2)
    );
    
    // Final carry-out
    assign Cout = carry_out2;

endmodule


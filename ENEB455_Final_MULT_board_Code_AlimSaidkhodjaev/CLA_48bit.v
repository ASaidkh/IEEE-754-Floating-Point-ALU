`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 01:29:57 PM
// Design Name: 
// Module Name: CLA_48bit
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


module CLA_48bit (
    input  wire [47:0] A,
    input  wire [47:0] B,
    input  wire        C0,
    output wire [47:0] Sum,
    output wire        Cout
);

    wire [47:0] G, P, C;

    // Generate and Propagate signals
    assign G = A & B;
    assign P = A ^ B;

    // Initial carry-in
    assign C[0] = C0;

    genvar i;
    generate
        for (i = 1; i < 48; i = i + 1) begin : carry_chain
            assign C[i] = G[i-1] | (P[i-1] & C[i-1]);
        end
    endgenerate

    // Final carry-out
    assign Cout = G[47] | (P[47] & C[47]);

    // Sum computation
    assign Sum = P ^ C;

endmodule

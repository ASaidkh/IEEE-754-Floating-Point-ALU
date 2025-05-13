`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 05/09/2025 12:38:55 PM
// Design Name: 
// Module Name: CLA_23bit
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


module CLA_23bit (
    input  wire [22:0] A,
    input  wire [22:0] B,
    input  wire        C0,
    output wire [22:0] Sum,
    output wire        Cout
);

    wire [22:0] G, P, C;

    // Generate and Propagate signals
    assign G = A & B;
    assign P = A ^ B;

    // Initial carry-in
    assign C[0] = C0;

    genvar i;
    generate
        for (i = 1; i < 23; i = i + 1) begin : carry_chain
            assign C[i] = G[i-1] | (P[i-1] & C[i-1]);
        end
    endgenerate

    // Final carry-out
    assign Cout = G[22] | (P[22] & C[22]);

    // Sum computation
    assign Sum = P ^ C;

endmodule

`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2025 11:22:06 AM
// Design Name: 
// Module Name: Tree_CLA_8bit
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


module Tree_CLA_8bit(
    input wire [7:0] A,
    input wire [7:0] B,
    input wire C0,
    output wire [7:0] Sum,
    output wire Cout
    );
 
wire [7:0] P, G, Cin; // Top-level P, G, and Carry
wire [3:0] G2hl, P2hl, C2; // Second level 
wire [1:0] G3hl, P3hl, C3; // Third level

// Generate top
genvar i;    
generate 
    for (i = 0; i < 8; i = i+1) begin: top
        assign G[i] = A[i] & B[i];
        assign P[i] = A[i] ^ B[i];
        if (i < 7) begin
            assign Sum[i] = A[i]^B[i]^Cin[i];
        end 
        else begin
              FA topFA (
                .a(A[i]),
                .b(B[i]),
                .cin(Cin[i]),
                .sum(Sum[i]),
                .cout(Cout)
            );
        end
    end
endgenerate

// Second level GP_C blocks
generate 
    for (i = 1; i < 8; i = i+2) begin: second
             GP_C_Block gp2 (
                  .Gh(G[i]), .Ph(P[i]), .Ch(Cin[i]),
                  .Gl(G[i-1]), .Pl(P[i-1]), .Cl(Cin[i-1]),        
                  .Ghl(G2hl[i/2]), .Phl(P2hl[i/2]), .Cin(C2[i/2])
                  
                );
        end
endgenerate

// Third level GP_C blocks
generate 
    for (i = 3; i < 8; i = i+4) begin: third
             GP_C_Block gp3 (
                  .Gh(G2hl[i/2]), .Ph(P2hl[i/2]), .Ch(C2[i/2]),
                  .Gl(G2hl[(i-2)/2]), .Pl(P2hl[(i-2)/2]), .Cl(C2[(i-2)/2]),
                  .Ghl(G3hl[i/4]), .Phl(P3hl[i/4]),  .Cin(C3[i/4])
                  
                );
        end
endgenerate

// Final GP_C block
GP_C_Block gp3 (
                  .Gh(G3hl[1]), .Ph(P3hl[1]), .Ch(C3[1]),
                  .Gl(G3hl[0]), .Pl(P3hl[0]), .Cl(C3[0]),
                  .Cin(C0)
              
                ); 
        

endmodule
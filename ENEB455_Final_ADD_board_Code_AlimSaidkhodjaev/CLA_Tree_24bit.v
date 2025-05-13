`timescale 1ns / 1ps

module Tree_CLA_24bit(
    input wire [23:0] A,
    input wire [23:0] B,
    input wire C0,
    output wire [23:0] Sum,
    output wire Cout
);

    // Declare wires for Propagate, Generate, and Carry
    wire [31:0] P, G, Cin, intSum;  // Top-level P, G, and Carry
    wire [15:0] G2hl, P2hl, C2;  // Second level (G2hl, P2hl, C2 are 16-bits)
    wire [7:0] G3hl, P3hl, C3;  // Third level (G3hl, P3hl, C3 are 8-bits)
    wire [3:0] G4hl, P4hl, C4;  // Fourth level (G4hl, P4hl, C4 are 4-bits)
    wire [1:0] G5hl, P5hl, C5;  // Fifth level (G5hl, P5hl, C5 are 2-bits)
  
    // Top-level generation for G and P
    genvar i;
    generate 
        for (i = 0; i < 32; i = i+1) begin: top
            
            if (i < 24) begin
                assign intSum[i] = A[i]^B[i]^Cin[i];
                assign G[i] = A[i] & B[i];
                assign P[i] = A[i] ^ B[i];
            end 
            else  begin
                 assign intSum[i] = 0^0^Cin[i];
                 assign G[i] = 0 & 0;
                 assign P[i] = 0 ^ 0;
            end

        end
    endgenerate

    // Second level GP-C blocks (16-bit level)
    generate 
        for (i = 1; i < 32; i = i+2) begin: second
            GP_C_Block gp2 (
                .Gh(G[i]), .Ph(P[i]), .Ch(Cin[i]),
                .Gl(G[i-1]), .Pl(P[i-1]), .Cl(Cin[i-1]),
                .Ghl(G2hl[i/2]), .Phl(P2hl[i/2]), .Cin(C2[i/2])
            );
        end
    endgenerate

    // Third level GP-C blocks (8-bit level)
    generate 
        for (i = 3; i < 32; i = i+4) begin: third
            GP_C_Block gp3 (
                .Gh(G2hl[i/2]), .Ph(P2hl[i/2]), .Ch(C2[i/2]),
                .Gl(G2hl[(i-2)/2]), .Pl(P2hl[(i-2)/2]), .Cl(C2[(i-2)/2]),
                .Ghl(G3hl[i/4]), .Phl(P3hl[i/4]),  .Cin(C3[i/4])
            );
        end
    endgenerate

    // Fourth level GP-C blocks (4-bit level)
    generate 
        for (i = 7; i < 32; i = i+8) begin: fourth
            GP_C_Block gp4 (
                .Gh(G3hl[i/4]), .Ph(P3hl[i/4]), .Ch(C3[i/4]),
                .Gl(G3hl[(i-4)/4]), .Pl(P3hl[(i-4)/4]), .Cl(C3[(i-4)/4]),
                .Ghl(G4hl[i/8]), .Phl(P4hl[i/8]), .Cin(C4[i/8])
            );
        end
    endgenerate

    // Fifth level GP-C blocks (2-bit level)
    generate 
        for (i = 15; i < 32; i = i+16) begin: fifth
            GP_C_Block gp5 (
                .Gh(G4hl[i/8]), .Ph(P4hl[i/8]), .Ch(C4[i/8]),
                .Gl(G4hl[(i-8)/8]), .Pl(P4hl[(i-8)/8]), .Cl(C4[(i-8)/8]),
                .Ghl(G5hl[i/16]), .Phl(P5hl[i/16]), .Cin(C5[i/16])
            );
        end
    endgenerate

    assign Sum = intSum[23:0];
    assign Cout = intSum[24];
    
    // Final GP-C block for the carry-out
    GP_C_Block gp_final (
        .Gh(G5hl[1]), .Ph(P5hl[1]), .Ch(C5[1]),
        .Gl(G5hl[0]), .Pl(P5hl[0]), .Cl(C5[0]),
        .Cin(C0),  .Ghl(), .Phl()
    );

endmodule

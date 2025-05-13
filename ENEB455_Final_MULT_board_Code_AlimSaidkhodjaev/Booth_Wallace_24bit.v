`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 09:44:53 AM
// Design Name: 
// Module Name: Booth_Wallace_24bit
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


module Booth_Wallace_24bit(
    input wire [23:0] A,
    input wire [23:0] B,
    output wire [47:0] P
    );
    
// Partial Products from Radix-4 Encoder
wire [47:0] PP0, PP1, PP2, PP3, PP4, PP5, PP6, PP7, PP8, PP9, PP10, PP11, PP12;

// Intermediate Carries and Sums
wire [47:0] S00, S01, S02, S03, S10, S11, S20, S21, S30, S40, S50;
wire [47:0] C00, C01, C02, C03, C10, C11, C20, C21, C30, C40, C50;
 
Radix4_Booth_24bit booth_encoder (
    .A(A),
    .B(B),
    .PP0(PP0),
    .PP1(PP1),
    .PP2(PP2),
    .PP3(PP3),
    .PP4(PP4),
    .PP5(PP5),
    .PP6(PP6),
    .PP7(PP7),
    .PP8(PP8),
    .PP9(PP9),
    .PP10(PP10),
    .PP11(PP11),
    .PP12(PP12)
);

// First level CSAs
CSA #(48) CSA00 (
    .A(PP0),
    .B(PP1<<2),
    .Cin(PP2<<4),
    .S(S00),
    .Cout(C00)
);
CSA #(48) CSA01 (
    .A(PP3<<6),
    .B(PP4<<8),
    .Cin(PP5<<10),
    .S(S01),
    .Cout(C01)
);
CSA #(48) CSA02 (
    .A(PP6<<12),
    .B(PP7<<14),
    .Cin(PP8<<16),
    .S(S02),
    .Cout(C02)
);
CSA #(48) CSA03 (
    .A(PP9<<18),
    .B(PP10<<20),
    .Cin(PP11<<22),
    .S(S03),
    .Cout(C03)
);
// Seocnd Level CSAs
CSA #(48) CSA10 (
    .A(S00),
    .B(C00<<1),
    .Cin(S01),
    .S(S10),
    .Cout(C10)
);
CSA #(48) CSA11 (
    .A(C01 << 1),
    .B(S02),
    .Cin(C02 << 1),
    .S(S11),
    .Cout(C11)
);
// Third Level CSAs
CSA #(48) CSA20 (
    .A(S10),
    .B(C10 << 1),
    .Cin(S11),
    .S(S20),
    .Cout(C20)
);
CSA #(48) CSA21 (
    .A(C11 << 1),
    .B(S03),
    .Cin(C03 << 1),
    .S(S21),
    .Cout(C21)
);
// Fourth Level CSA
CSA #(48) CSA30 (
    .A(S20),
    .B(C20 << 1),
    .Cin(S21),
    .S(S30),
    .Cout(C30)
);
// Fourth CSA
CSA #(48) CSA40 (
    .A(S30),
    .B(C30 << 1),
    .Cin(C21 << 1),
    .S(S40),
    .Cout(C40)
);

// Final CSA
CSA #(48) CSA50 (
    .A(S40),
    .B(C40 << 1),
    .Cin(PP12 << 24),
    .S(S50),
    .Cout(C50)
);

CLA_48bit CPA(
    .A(S50),
    .B(C50 << 1),
    .C0(1'b0),
    .Sum(P),
    .Cout()
);



endmodule

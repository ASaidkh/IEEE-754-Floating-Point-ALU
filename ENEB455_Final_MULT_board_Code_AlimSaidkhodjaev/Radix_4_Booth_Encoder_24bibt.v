`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/13/2025 09:44:06 AM
// Design Name: 
// Module Name: Radix_4_Booth_Encoder_24bibt
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


module Radix4_Booth_24bit (
    input  wire [23:0] A, // Multiplier (mantissa)
    input  wire [23:0] B, // Multiplicand (mantissa)
    output wire signed [47:0] PP0,
    output wire signed [47:0] PP1,
    output wire signed [47:0] PP2,
    output wire signed [47:0] PP3,
    output wire signed [47:0] PP4,
    output wire signed [47:0] PP5,
    output wire signed [47:0] PP6,
    output wire signed [47:0] PP7,
    output wire signed [47:0] PP8,
    output wire signed [47:0] PP9,
    output wire signed [47:0] PP10,
    output wire signed [47:0] PP11,
    output wire signed [47:0] PP12
);

    reg [3:0] i;
    reg signed [47:0] booth_pp;
    reg signed [47:0] int_PP[12:0];
    
    wire [25:0] padded_A;
    assign padded_A = {2'b0, A};

    always @(*) begin
        for (i = 0; i <= 12; i = i + 1) begin
            // Select 3 bits for Booth encoding
            case ({padded_A[2*i+1], padded_A[2*i], (i == 0) ? 1'b0 : padded_A[2*i-1]})
                3'b000, 3'b111: booth_pp = 48'd0;
                3'b001, 3'b010: booth_pp = {{24{1'b0}}, B}; // +M
                3'b011:         booth_pp = {{23{1'b0}}, B, 1'b0}; // +2M
                3'b100:         booth_pp = -{{23{1'b0}}, B, 1'b0}; // -2M
                3'b101, 3'b110: booth_pp = -{{24{1'b0}}, B}; // -M
                default:        booth_pp = 48'd0;
            endcase
            int_PP[i] = booth_pp;
        end
    end

    // Assign to output wires
    assign PP0  = int_PP[0];
    assign PP1  = int_PP[1];
    assign PP2  = int_PP[2];
    assign PP3  = int_PP[3];
    assign PP4  = int_PP[4];
    assign PP5  = int_PP[5];
    assign PP6  = int_PP[6];
    assign PP7  = int_PP[7];
    assign PP8  = int_PP[8];
    assign PP9  = int_PP[9];
    assign PP10 = int_PP[10];
    assign PP11 = int_PP[11];
    assign PP12 = int_PP[12];

endmodule

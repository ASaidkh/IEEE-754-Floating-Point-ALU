`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/21/2025 02:25:56 PM
// Design Name: 
// Module Name: MULT_BOARD_TOP
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


module MULT_BOARD_TOP(
    input wire scl,
    inout wire sda,
    input wire reset,
    input wire clk_100MHz, 
    output wire CS,
    output wire SDIN,
    output wire SCLK,
    output wire DC,
    output wire RES,
    output wire VBAT,
    output wire VDD
    );

    wire rxDone;
    wire [65:0] slave_dout;
    
    reg [31:0] A,B;
    reg [31:0] result;
    
    wire [9:0] e;
    wire [8:0] eInc;
    wire [22:0] MantInc;
    wire [47:0] P;
    
    wire [127:0] Page0, Page1, Page2, Page3;
    
    reg [1:0] state;
    reg [7:0] opcode;
    reg MULTdone;
    
    localparam IDLE = 0;
    localparam MULTIPLY = 1;
    


always @(posedge clk_100MHz or posedge reset) begin
    if (reset) begin
        state <= IDLE;
        result <= 0;
        A <= 0;
        B <= 0;
        opcode <= 8'h78;
        MULTdone <= 0;
    end
    else begin
        if (rxDone && state == IDLE) begin
            case (slave_dout[65:64])
                2'b11:  result <= slave_dout[31:0]; //result of ADD/SUB received if opcode = 11
                2'b10: begin // Begin multiplication if opcode = 10
                     state <= MULTIPLY;
                     A <= slave_dout[31:0];
                     B <= slave_dout[63:32];
                     opcode <= 8'h78;
                end
                2'b01: begin // If ADD/SUB op code, set operands for display
                     A <= slave_dout[31:0];
                     B <= slave_dout[63:32];
                     opcode <= 8'h2D;
                end
                default: begin
                     A <= slave_dout[31:0];
                     B <= slave_dout[63:32];
                    opcode <= 8'h2B;
                end
            endcase
        end
        else begin 
            if (state == MULTIPLY) begin
                
                if (!MULTdone)  begin
                    state <= MULTIPLY;
                    MULTdone <= 1'b1;
                end
                else begin
                    MULTdone <= 0;
                    state <= IDLE;
             
                    // Special cases handling 
                    if ((A[31:0] == 0) || (B[31:0] == 0)) begin
                        // If either operand is zero, result is zero with proper sign
                        result[31:0] <= 31'd0;
                    end
                    // Handle overflow
                    else if ( e[9]) begin
                        // Set to infinity with proper sign
                        result[31] <= A[31] ^ B[31];
                        result[30:23] <= 8'd255;
                        result[22:0] <= 23'b0;
                    end
                    
                // Normal case processing
                else begin
                    // Calculate sign bit
                    result[31] <= A[31] ^ B[31];
                    // Handle normalization and rounding for significand
                    if (P[47] == 1'b1) begin
                        // Case where leading bit is 1, shift right and increment exponent
                        result[30:23] <= eInc; // Add 1 to exponent for right shift
                        
                        // Round to +infinity:
                        // If positive result and any fractional bits, round up
                        if ((A[31] ^ B[31]) == 0 && (|P[23:0])) begin
                            result[22:0] <= MantInc[22:0];
                            // Check for carry out from rounding
                            if (P[46:24] == 23'h7FFFFF)
                                result[30:23] <= eInc; // Add 2 (shift + carry)
                        end else begin
                            // For negative results or no fractional bits, truncate
                            result[22:0] <= P[46:24];
                        end
                    end
                    else begin
                        // Case where leading bit is 0, no shift needed
                        result[30:23] <= e;
                        // If positive result and any fractional bits, round up
                        if ((A[31] ^ B[31]) == 0 && (|P[22:0])) begin
                            result[22:0] <= MantInc[22:0];
                            // Check for carry out from rounding
                            if (P[45:23] == 23'h7FFFFF)
                                result[30:23] <= eInc; // Add 1 for carry
                        end else begin
                            // For negative results or no fractional bits, truncate
                            result[22:0] <= P[45:23];
                        end
                    end
                end

                end
            end
        end 
    end
end

    wire [22:0] MantissaToRound = (P[47]) ? P[46:24] : P[45:23];
     CLA_23bit MantIncer (
        .A( MantissaToRound ),
        .B(23'd1),
        .C0(1'b0),
        .Sum(MantInc[22:0]),
        .Cout()
    );
    
    
   ExponentAdder eADD (
        .A({1'b0,A[30:23]}),
        .B({1'b0,B[30:23]}),
        .C(9'b010000001), // -127 bias
        .C0(1'b0),
        .Sum( e[8:0] ),
        .Cout(e[9])
   );
   
      ExponentAdder increment (
        .A(e[8:0]),
        .B( (P[47] == 1'b1 || P[45:23] == 23'h7FFFFF) ? 9'd1 : 9'd2 ),
        .C(9'd0),
        .C0(1'b0),
        .Sum( eInc[8:0] ),
        .Cout()
         );
    
   Booth_Wallace_24bit MULT(
        .A({1'b1, A[22:0]}),
        .B({1'b1, B[22:0]}),
        .P(P)
    );

    
    i2c_slave_controller slave (
        .sda(sda), 
        .scl(scl),
        .rst(reset),
        .data_out(slave_dout), //Data read from master
        .data_in(66'd0),
        .ack(),
        .rxDone(rxDone)
    );

        
 // 1000000 division for 100 Hz refresh rate
    ClockEnable #(1000000) refreshOLED (
        .clk(clk_100MHz),
        .clr(reset),
        .clk_en(OLEDrefresh)
    );

    PmodOLEDCtrl OLEDCTRL(
        .CLK(clk_100MHz),
        .RST(reset),
        .EN(OLEDrefresh),
        .Page0(Page0),
        .Page1(Page1),
        .Page2(Page2),
        .Page3(Page3),
        .CS(CS),
        .SDIN(SDIN),
        .SCLK(SCLK),
        .DC(DC),
        .RES(RES),
        .VBAT(VBAT),
        .VDD(VDD)
    );

        // Function to convert 4-bit hex value to ASCII
        function [7:0] hex_to_ascii;
            input [3:0] nibble;
            begin
                hex_to_ascii = (nibble < 4'd10) ? (nibble + 8'h30) : (nibble + 8'h37);
            end
        endfunction

        // " A"
        assign Page0 = { 
            8'h20, // space
            hex_to_ascii(A[31:28]), hex_to_ascii(A[27:24]),
            hex_to_ascii(A[23:20]), hex_to_ascii(A[19:16]),
            hex_to_ascii(A[15:12]), hex_to_ascii(A[11:8]),
            hex_to_ascii(A[7:4]),   hex_to_ascii(A[3:0]),
            {7{8'h20}} // Fill the rest to 16 bytes
        };
    
        // "+/-/x B"
        assign Page1 = { 
            opcode, 
            hex_to_ascii(B[31:28]), hex_to_ascii(B[27:24]),
            hex_to_ascii(B[23:20]), hex_to_ascii(B[19:16]),
            hex_to_ascii(B[15:12]), hex_to_ascii(B[11:8]),
            hex_to_ascii(B[7:4]),   hex_to_ascii(B[3:0]),
            {7{8'h20}} // Fill the rest
        };
    
        // "=Result"
        assign Page2 = { 
            8'h3D, // '='
            hex_to_ascii(result[31:28]), hex_to_ascii(result[27:24]),
            hex_to_ascii(result[23:20]), hex_to_ascii(result[19:16]),
            hex_to_ascii(result[15:12]), hex_to_ascii(result[11:8]),
            hex_to_ascii(result[7:4]),   hex_to_ascii(result[3:0]),
            {7{8'h20}}  // Fill the rest
        };
     
    assign Page3 = {
        {16{8'h20}}
    };
    
    
endmodule

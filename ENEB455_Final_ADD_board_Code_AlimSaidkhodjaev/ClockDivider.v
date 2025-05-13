`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 12/09/2023 06:01:35 PM
// Design Name: 
// Module Name: ClockDivider
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


module ClockDivider #(parameter DIVISOR = 50)
    (
    input wire clr,
    input wire clk,
    output reg clk_out
    );
    
    reg [26:0] count = 0;
    always @(posedge clk or posedge clr) begin
        if (clr == 1)
            clk_out <= 0;
        else if (count == DIVISOR - 1) begin
            count <= 0;
            clk_out <= ~clk_out;
        end
        else begin
            count <= count + 1;
        end
        
    end
            
        
endmodule

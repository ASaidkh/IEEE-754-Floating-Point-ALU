`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2025 06:06:37 PM
// Design Name: 
// Module Name: FIFO
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
module FIFO #(parameter n = 2, parameter m = 2)(
    input wire Wclk, Rclk, rst,
    input wire WR, RD,
    input wire [m-1:0] Din,
    output reg [m-1:0] Dout,
    output reg FF, EF,
    output reg [$clog2(n)-1:0] WRptr, RDptr 
);
    reg [m-1:0] memory [0:n-1];    
    reg [$clog2(n):0] wr_count, rd_count;  // Extra bit for wraparound detection
    
    // Synchronizer registers
    reg [$clog2(n):0] wr_count_sync1, wr_count_sync2;
    reg [$clog2(n):0] rd_count_sync1, rd_count_sync2;
   
    integer i;
    initial begin
        for (i=0; i<n; i=i+1) 
            memory[i] = 0;
        wr_count = 0;
        rd_count = 0;
        WRptr = 0;
        RDptr = 0;
        FF = 0;
        EF = 1;  // FIFO starts empty
    end
    
    
     always @(posedge Wclk) begin  // NO asynchronous reset here
            if (WR && !FF) begin
                memory[WRptr] <= Din;
            end
        end
        
        
    // Write operation with counter
    always @(posedge Wclk or posedge rst) begin
        if (rst) begin
            WRptr <= 0;
            wr_count <= 0;
        end
        else if (WR && !FF) begin
            if (WRptr == n-1) begin
                WRptr <= 0;
            end
            else begin
                WRptr <= WRptr + 1;
            end
            wr_count <= wr_count + 1;
        end
    end
    
    // Read operation with counter
    always @(posedge Rclk or posedge rst) begin
        if (rst) begin 
            RDptr <= 0;
            rd_count <= 0;
            Dout <= 0;
        end
        else if (RD && !EF) begin     
            Dout <= memory[RDptr];
            if (RDptr == n-1) begin
                RDptr <= 0;
            end
            else begin
                RDptr <= RDptr + 1;
            end
            rd_count <= rd_count + 1;
        end
    end
    
    // Synchronize write counter to read clock domain
    always @(posedge Rclk or posedge rst) begin
        if (rst) begin
            wr_count_sync1 <= 0;
            wr_count_sync2 <= 0;
        end
        else begin
            wr_count_sync1 <= wr_count;
            wr_count_sync2 <= wr_count_sync1;
        end
    end
    
    // Synchronize read counter to write clock domain
    always @(posedge Wclk or posedge rst) begin
        if (rst) begin
            rd_count_sync1 <= 0;
            rd_count_sync2 <= 0;
        end
        else begin
            rd_count_sync1 <= rd_count;
            rd_count_sync2 <= rd_count_sync1;
        end
    end
    
    // Empty flag logic - in read clock domain
    always @(posedge Rclk or posedge rst) begin
        if (rst) begin
            EF <= 1'b1;  // Empty on reset
        end
        else begin
            // Empty when read count equals write count (synchronized)
            EF <= (rd_count == wr_count_sync2);
        end
    end
    
    // Full flag logic - in write clock domain
    always @(posedge Wclk or posedge rst) begin
        if (rst) begin
            FF <= 1'b0;  // Not full on reset
        end
        else begin
            // Full when wr_count - rd_count (synchronized) = FIFO depth
            // With mod 2*n to handle wraparound
            FF <= ((wr_count - rd_count_sync2) >= n);
        end
    end
    
endmodule
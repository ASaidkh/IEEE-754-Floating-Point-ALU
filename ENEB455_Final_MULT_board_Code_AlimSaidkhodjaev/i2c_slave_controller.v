`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/25/2025 06:52:40 PM
// Design Name: 
// Module Name: i2c_slave_controller
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

module i2c_slave_controller(
    inout sda,  // Serial Data Line
    input wire scl,  // Serial Clock Line
    input wire rst,  // Reset signal
    output wire [65:0] data_out,  // Data received from master
    input wire [65:0] data_in,   // Data to send to master
    output reg ack,
    output reg rxDone
);

    // State machine states
    localparam IDLE       = 0;
    localparam READ_RW    = 1;
    localparam SEND_ACK   = 2;
    localparam READ_DATA  = 3;
    localparam WRITE_DATA = 4;
    localparam SEND_ACK_2   = 5;
    
    reg [2:0] state;
    reg [65:0] shift_reg = 0;
    reg [6:0] bit_count = 0;
    reg rw; // Read/Write bit

    // Start condition detection
    reg start;
    
    
    // Detect Start Condition
    always @(negedge sda) begin
        if (scl && state == IDLE) begin
            start <= 1;
        end
        else if (state == READ_RW) begin
            start <= 0;
        end
    end


  
    // Next State Logic
    always @(negedge scl or posedge rst) begin
        if (rst) begin
            state <= IDLE;
            rxDone <= 1'b0;
        end
        else begin
            case (state)
                IDLE: begin
                    if (start) begin
                        state <= READ_RW;
                        rxDone <= 1'b0;
                    end
                    else
                        state <= IDLE;
                end
                
                READ_RW: begin
                        state <= SEND_ACK;
                end
    
                SEND_ACK: begin
                        if (rw) 
                            state <= WRITE_DATA;
                        else 
                            state <= READ_DATA; 
                end
    
                READ_DATA: begin
                    if (bit_count == 66) begin
                       state <= IDLE;
                       rxDone <= 1'b1;
                    end
                    else 
                        state <= READ_DATA;
                end
    
                WRITE_DATA: begin
                    if (bit_count == 66) 
                        state <= IDLE;
                    else 
                        state <= WRITE_DATA;
                end
                
                SEND_ACK_2: begin
                    state <= IDLE;
                end
    
                default: state <= IDLE;
            endcase
         end
    end

    // Bit reception
    always @(posedge scl or posedge rst) begin
        if (rst) shift_reg <= 0;
        
        else if ( state == READ_DATA) begin
            shift_reg <= {shift_reg[64:0], sda};
            bit_count <= bit_count + 1;
        end
        else if ( state == WRITE_DATA) begin
            bit_count <= bit_count + 1;
        end
        else if (state == SEND_ACK) begin
            bit_count <= 0;
        end
    end

    // Read/Write bit extraction
    always @(posedge scl) begin
        if (rst) begin
            rw <= 0;
        end 
        else if (state == READ_RW) begin
            rw <= sda;  
        end
    end

    // Acknowledgment
    always @(posedge scl or posedge rst) begin
        if (rst) begin
            ack <= 0;
        end
        else if (state == SEND_ACK || state == SEND_ACK_2) begin
            ack <= 1;
        end else begin
            ack <= 0;
        end
    end

  
    assign data_out = shift_reg;

     // Assign output to SDA during WRITE_DATA
    assign sda = (state == WRITE_DATA ) ? data_in[65 - bit_count] : (state == SEND_ACK || state == SEND_ACK_2) ? 0 : 1'bz;

endmodule


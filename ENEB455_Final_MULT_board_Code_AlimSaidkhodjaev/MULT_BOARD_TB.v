`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/23/2025 04:15:42 PM
// Design Name: 
// Module Name: MULT_BOARD_TB
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


`timescale 1ns / 1ps

module float_mult_tb;

    // Inputs
    reg clk;
    reg rst;
    reg [65:0] master_data_in;
    reg enable;
    reg rw;

    // Outputs
    wire [65:0] slave_data_out;
    wire ready;

    // Bidirs
    wire i2c_sda;
    wire i2c_scl;
    
    // Test case parameters
    parameter NUM_TESTS = 5;
    reg [31:0] test_A [0:NUM_TESTS-1];
    reg [31:0] test_B [0:NUM_TESTS-1];
    reg [31:0] expected_result [0:NUM_TESTS-1];
    
    // Instantiate the Master Controller
    i2c_master_controller master (
        .clk(clk),
        .rst(rst),
        .data_in(master_data_in),
        .enable(enable),
        .rw(rw),
        .ready(ready),
        .i2c_sda(i2c_sda),
        .i2c_scl(i2c_scl)
    );
    
    // Instantiate the Multiplication Board (DUT)
    MULT_BOARD_TOP dut (
        .clk_100MHz(clk),
        .reset(rst),
        .scl(i2c_scl),
        .sda(i2c_sda),
        .CS(),
        .SDIN(),
        .SCLK(),
        .DC(),
        .RES(),
        .VBAT(),
        .VDD()
    );
    
    // Create 100MHz clock
    initial begin
        clk = 0;
        forever #5 clk = ~clk; // 100MHz clock
    end
    
    // Initialize test cases
    initial begin
        // Test case 1: Normal positive * positive
        test_A[0] = 32'h40A00000; // 5.0
        test_B[0] = 32'h40000000; // 2.0
        expected_result[0] = 32'h41200000; // 10.0
        
        // Test case 2: Normal positive * negative
        test_A[1] = 32'h40A00000; // 5.0
        test_B[1] = 32'hC0000000; // -2.0
        expected_result[1] = 32'hC1200000; // -10.0
        
        // Test case 3: Rounding case (positive)
        test_A[2] = 32'h3F8CCCCD; // 1.1
        test_B[2] = 32'h3F8CCCCD; // 1.1
        expected_result[2] = 32'h3FFD70A4; // 1.21 (rounded up for +inf mode)
        
        // Test case 4: Rounding case (negative)
        test_A[3] = 32'h3F8CCCCD; // 1.1
        test_B[3] = 32'hBF8CCCCD; // -1.1
        expected_result[3] = 32'hBFFD70A3; // -1.21 (no rounding up for negative with +inf mode)
        
        // Test case 5: Zero test
        test_A[4] = 32'h00000000; // 0.0
        test_B[4] = 32'h40A00000; // 5.0
        expected_result[4] = 32'h00000000; // 0.0
    end

    // Main test sequence
    integer i;
    
    initial begin
        // Initialize inputs
        rst = 1;
        enable = 0;
        rw = 0;
        master_data_in = 0;
        
        // Apply reset
        #20;
        rst = 0;
        #20;
        
        // Run all test cases
        for (i = 0; i < NUM_TESTS; i = i + 1) begin
            // Display test case info
            $display("Starting Test Case %0d", i+1);
            $display("A = %h, B = %h ", 
                     test_A[i],
                     test_B[i]);
            $display("Expected Result = %h ", 
                     expected_result[i]);
            
            // Create the data packet: [2-bit opcode][32-bit B][32-bit A]
            master_data_in = {2'b10, test_B[i], test_A[i]};
            
            // Start I2C transmission (send data to slave)
            #10;
            enable = 1;
            #10;
            enable = 0;
            
            // Wait for slave to process multiplication
            #1000;
            
            // At this point, the result should be computed in DUT's internal register
            // We'd need to read it back through I2C in a real system, but for simulation
            // purposes, we can observe it directly
            // Visualize the result in the waveform viewer
            
            $display("Test Case %0d Completed", i+1);
            $display("---------------------------------------");
            
            // Add some delay between tests
            #100;
        end
        
        $display("All tests completed");
        #100;
        $finish;
    end
    
    // Monitor for debug purposes
    initial begin
        $monitor("Time=%0t, Test=%0d, A=%h, B=%h, Expected=%h", 
                 $time, i, test_A[i-1], test_B[i-1], expected_result[i-1]);
    end

endmodule
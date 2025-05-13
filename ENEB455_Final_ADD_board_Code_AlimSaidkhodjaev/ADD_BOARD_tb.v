`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2025 06:09:06 PM
// Design Name: 
// Module Name: ADD_BOARD_tb
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

module fp_adder_tb();
    // Clock parameters
    parameter CLK_PERIOD = 2; // 100MHz clock
    
    // Testbench signals
    reg clk_100MHz;
    reg reset;
    reg rx;
    wire tx;
    wire scl;
    wire sda;
    reg [7:0] rec_data_signal;
    reg rx_done_tick_signal;
    
    // I2C slave signals
    wire [65:0] slave_data_out;
    reg [65:0] slave_data_in;
    wire slave_ack;
    
    // Test case parameters
    parameter NUM_TEST_CASES = 4;
    
    // Test data storage
    reg [31:0] test_A [0:NUM_TEST_CASES-1];
    reg [31:0] test_B [0:NUM_TEST_CASES-1];
    reg [1:0] test_opcode [0:NUM_TEST_CASES-1];
    reg [31:0] expected_results [0:NUM_TEST_CASES-1];
    reg [31:0] expected_result;
    reg [31:0] A, B;
    
    // Instantiate the DUT (Design Under Test)
    ADD_BOARD_TOP dut (
        .clk_100MHz(clk_100MHz),
        .reset(reset),
        .rx(rx),
        .tx(tx),
        .scl(scl),
        .sda(sda)
    );
    
    // Force direct access to the internal UART signals of the DUT
    assign dut.rec_data = rec_data_signal;
    assign dut.rx_done_tick = rx_done_tick_signal;
    
    
    // Instantiate the I2C slave controller
    i2c_slave_controller slave (
        .sda(sda),
        .scl(scl),
        .rst(reset),
        .data_out(slave_data_out),
        .data_in(slave_data_in),
        .ack(slave_ack)
    );
    
    // Clock generation
    always begin
        #(CLK_PERIOD/2) clk_100MHz = ~clk_100MHz;
    end
    
    // Initialize test data
    initial begin
        // Test Case 1: Simple addition: 1.0 + 2.0 = 3.0
        test_A[0] = 32'h3F800000; // 1.0
        test_B[0] = 32'h40000000; // 2.0
        test_opcode[0] = 2'b00;    // ADD opcode
        expected_results[0] = 32'h40400000; // 3.0
        
        // Test Case 2: Addition with different exponents: 1.0 + 0.0625 = 1.0625
        test_A[1] = 32'h3F800000; // 1.0
        test_B[1] = 32'h3D800000; // 0.0625
        test_opcode[1] = 2'b00;    // ADD opcode
        expected_results[1] = 32'h3F880000; // 1.0625
        
        // Test Case 3: Subtraction: 5.0 - 3.0 = 2.0
        test_A[2] = 32'h40A00000; // 5.0
        test_B[2] = 32'h40400000; // 3.0
        test_opcode[2] = 2'b01;    // SUB opcode
        expected_results[2] = 32'h40000000; // 2.0
        
        // Test Case 4: Addition with negative numbers: -2.5 + 1.5 = -1.0
        test_A[3] = 32'hC0200000; // -2.5
        test_B[3] = 32'h3FC00000; // 1.5
        test_opcode[3] = 2'b00;    // ADD opcode
        expected_results[3] = 32'hBF800000; // -1.0
    end
    
    // Test procedure
    integer i, byte_idx;
    reg [71:0] test_data;
    
    initial begin
        // Initialize signals
        clk_100MHz = 0;
        reset = 1;
        rx = 1;
        rx_done_tick_signal = 0;
        slave_data_in = 0;
        
        // Apply reset
        #20;
        reset = 0;
        #20;
        
        // Run test cases
        for (i = 0; i < NUM_TEST_CASES; i = i + 1) begin
            // Create the test data packet: {6'b0, opcode, operand B, operand A}
            test_data = {6'b0, test_opcode[i], test_B[i], test_A[i]};
            A = test_A[i];
            B = test_B[i];
            expected_result = expected_results[i];
            
            $display("Test Case %0d:", i);
            $display("  Operand A: %h", test_A[i]);
            $display("  Operand B: %h", test_B[i]);
            $display("  Opcode: %b", test_opcode[i]);
            $display("  Expected Result: %h", expected_results[i]);
            
            // Send the data byte by byte (9 bytes total)
            for (byte_idx = 8; byte_idx >= 0; byte_idx = byte_idx - 1) begin
                // Extract the current byte from test_data
                rec_data_signal = test_data[byte_idx*8 +: 8];
                
                // Toggle rx_done_tick to simulate UART receiving a byte
                #20;
                rx_done_tick_signal = 1;
                #10;
                rx_done_tick_signal = 0;
                #30; // Wait between bytes
            end
            
            // Wait for processing to complete and I2C communication to finish
            wait(slave_ack);
            #100;
            
            // Display the result received by the slave
            $display("  Result from I2C slave: %h", slave_data_out[31:0]);
            if (slave_data_out[31:0] == expected_results[i])
                $display("  TEST PASSED");
            else
                $display("  TEST FAILED: Expected %h, Got %h", expected_results[i], slave_data_out[31:0]);
            
            // Wait between test cases
            #200;
        end
        
        // End simulation
        $display("All tests completed");
        #100;
        $finish;
    end
    
    // Monitor I2C communication
    always @(posedge slave_ack) begin
        $display("I2C Transaction Complete");
        $display("  Data received by slave: %h", slave_data_out);
    end
    
endmodule

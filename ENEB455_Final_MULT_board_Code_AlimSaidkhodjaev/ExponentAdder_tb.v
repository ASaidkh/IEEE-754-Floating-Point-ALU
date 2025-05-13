`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 04/27/2025 08:58:54 AM
// Design Name: 
// Module Name: ExponentAdder_tb
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

module tb_ExponentAdder;

    // Inputs
    reg [8:0] A;
    reg [8:0] B;
    reg [8:0] C;
    reg C0;

    // Outputs
    wire [8:0] Sum;
    wire Cout;

    // Expected sum and carry-out
    reg [8:0] expected_sum;
    reg expected_cout;

    // Error counter
    integer error_count;
    integer test_count;

    // Instantiate the Unit Under Test (UUT)
    ExponentAdder uut (
        .A(A), 
        .B(B), 
        .C(C), 
        .C0(C0), 
        .Sum(Sum), 
        .Cout(Cout)
    );

    // Task to calculate the expected result
    task calculate_expected;
        input [8:0] A, B, C;
        input C0;
        begin
            {expected_cout, expected_sum} = A + B + C + C0; // Simple binary addition with carry
        end
    endtask

    integer i, j;
    
    // Stimulus process
    initial begin
        // Initialize Inputs
        C = 10000001; // Constant C
        C0 = 0;       // Initial Carry-in
        error_count = 0; // Initialize error count
        test_count = 0;

        // Display the header for the output
        $display("Time\tA\tB\tC\tC0\tSum\tCout\tExpected_Sum\tExpected_Cout\tError_Count");
        $monitor("%0t\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d\t%0d", $time, A, B, C, C0, Sum, Cout, expected_sum, expected_cout, error_count);

        // Loop through all combinations of A and B (0 to 255)

        for (i = 0; i <= 255; i = i + 1) begin
            for (j = 0; j <= 255; j = j + 1) begin
                A = i;  // Set A to the current value of i
                B = j;  // Set B to the current value of j
                
                // Calculate the expected result
                calculate_expected(A, B, C, C0);
                test_count = test_count + 1;
                // Wait for the result to propagate
                #1;  // Time delay of 1ns

                // Compare the actual and expected results
                if (Sum !== expected_sum || Cout !== expected_cout) begin
                    error_count = error_count + 1;  // Increment error count
                    $display("Error at time %0t: A = %0d, B = %0d, C = %0d, C0 = %0d, Sum = %0d, Cout = %0d, Expected Sum = %0d, Expected Cout = %0d", 
                             $time, A, B, C, C0, Sum, Cout, expected_sum, expected_cout);
                end
            end
        end
         $display("Exponent Adder Tests:\n %0d Errors\n %0d/%0d Cases Passed ",
            error_count, (test_count - error_count), test_count);
        // End simulation
        #1 $finish;
    end

    // Add waveform generation for simulation (optional)
    initial begin
        $dumpfile("testbench.vcd");
        $dumpvars(0, tb_ExponentAdder);
    end

endmodule


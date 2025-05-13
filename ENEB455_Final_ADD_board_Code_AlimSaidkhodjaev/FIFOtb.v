`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/06/2025 06:09:39 PM
// Design Name: 
// Module Name: FIFOtb
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


module fifo_tb;

    // Testbench Parameters
    parameter n = 10; // FIFO depth
    parameter m = 8;  // Data width
    integer i;

    // Testbench Signals
    reg Wclk, Rclk, rst, WR, RD, WclkSlow, RclkSlow;
    reg [m-1:0] Din;
    wire [m-1:0] Dout;
    wire FF, EF;
    wire [$clog2(n)-1:0] WRptr, RDptr;

    // Instantiate the FIFO module
    FIFO #(n, m) fifo_inst (
        .Wclk(Wclk),
        .Rclk(Rclk),
        .rst(rst),
        .WR(WR),
        .RD(RD),
        .Din(Din),
        .Dout(Dout),
        .FF(FF),
        .EF(EF),
        .WRptr(WRptr),
        .RDptr(RDptr)
    );

    // Write Clock Generation
    initial begin
        Wclk = 0;
        WclkSlow = 0;
        forever begin
           if (WclkSlow)  begin
              #5;
             end
            #5 Wclk = ~Wclk;
        end
    end
    
     // Read Clock Generation
    initial begin
        Rclk = 0;
        RclkSlow = 0;
        forever begin
          if (RclkSlow)  begin
          #5;
          end
          #5 Rclk = ~Rclk;
        end
    end
    
    
 
    
    

    // Testbench Stimulus
    initial begin
        // Initial Setup
        rst = 1;
        WR = 0;
        RD = 0;
        Din = 8'b1;
        #15; // Allow for reset to take effect
        rst = 0;

        // Write: Continuously writing until FIFO is full
        $display("Starting Write Test");
        WR = 1;
        #10; //Alow first datas to be written
        for (Din = 2; Din <= 11; Din = Din + 1) begin
            #10;
            if (FF) begin
                $display("FIFO Full at Write %d, FF = %b", Din, FF);
               
            end
        end

        // Verify FIFO Full flag
        #10;
        if (!FF) $display("Write Test Failed: FF should be set!");
        else $display("Write Test Passed");

        // Keep WR signal on for a few more clock cycles to ensure no further data is written
        #30; 

        // **Reading After FIFO is Full**
        // Read from FIFO after it is full until it is empty
        $display("Starting Read Test after FIFO is full");
        RD = 1; WR = 0;
        for (i = 0; i < n; i = i + 1) begin
            #10; // Allow time for reading
            if (EF) begin
                $display("FIFO Empty at Read %d, EF = %b", Dout, EF);
               
            end
        end

        // Verify FIFO Empty flag
        #10;
        if (!EF) $display("Read Test Failed: EF should be set!");
        else $display("Read Test Passed");

        // Keep RD signal on for a few more clock cycles to ensure read pointer does not update
        #30; 

        // Reset the FIFO
        $display("Resetting FIFO");
        rst = 1;
        #20;
        rst = 0;

        // Reading & Writing Simultaneously
        $display("Starting Read/Write Simultaneous Test");

        // Test with same clocks for read and write
        $display("Test 3a: Same clock for read and write");
        WR = 1; RD = 1;
        for (Din = 3; Din <= 40; Din = Din + 1) begin
            #10;
            
        end
        
        // Test with faster write clock
        $display("Test 3b: Faster read ");
        WR = 1; RD = 1; WclkSlow = 1;
        for (Din = 5; Din <= 40; Din = Din + 1) begin
            #20;
            
        end
        
        
        // Test with faster write clock
        $display("Test 3c: Faster write ");
        WR = 1; RD = 1; WclkSlow = 0;  RclkSlow = 1;
        for (Din = 0; Din <= 80; Din = Din + 1) begin
            #10;
            
        end

       
        // Finish Simulation
        $display("Testbench Complete");
        $finish;
    end

endmodule

`timescale 1ns / 1ps

module i2c_controller_tb;

	// Inputs
	reg clk;
	reg rst;
	reg [6:0] addr;
	reg [65:0] master_data_in;
	reg [65:0] slave_data_in;
	reg enable;
	reg rw;

	// Outputs
	wire [65:0] master_data_out;
	wire [65:0] slave_data_out;
	wire ready, rxDone;

	// Bidirs
	wire i2c_sda;
	wire i2c_scl;

	// Instantiate the Unit Under Test (UUT)
	i2c_master_controller master (
		.clk(clk), 
		.rst(rst), 
//		.addr(addr), 
		.data_in(master_data_in), //Data to send on write
		.enable(enable), 
		.rw(rw), 
		.data_out(master_data_out), //Data read from slave
		.ready(ready), 
		.i2c_sda(i2c_sda), 
		.i2c_scl(i2c_scl)
	);
	
		
	i2c_slave_controller slave (
    .sda(i2c_sda), 
    .scl(i2c_scl),
    .rst(rst),
    .data_out(slave_data_out), //Data to send on write
	.data_in(slave_data_in), //Data read from master
	.rxDone(rxDone)
    );
	
	initial begin
		clk = 0;
		forever begin
			clk = #1 ~clk;
		end		
	end

	initial begin
		// Initialize Inputs
		clk = 0;
		rst = 1;
        slave_data_in<= 0;
        enable = 0;
        master_data_in = 0;
        rw = 0;
		// Wait 10 ns for global reset to finish
		#10;
        
		// TEST 1: Write data_in to slave
		rst = 0;		
//		addr = 7'b0101010;
		master_data_in = 66'h0a9874341;
		rw = 0;	
		$display("[BEFORE] R/W = %b | Master_data_in (tx): %b | Slave_data_in (rx): %b", rw, master_data_in, slave_data_in);
		enable = 1;
		#4;
		enable = 0;
				
		#300;	
		$display("[AFTER]  R/W = %b | Master_data_in (tx): %b | Slave_data_in (rx): %b", rw, master_data_in, slave_data_in);

        // TEST 2: Read data_out from slave
//		addr = 7'b0101010;
		slave_data_in <= 66'h1bc874341;
		rw = 1;	
		$display("[BEFORE] R/W = %b | Slave_data_out (tx): %b | Master_data_out (rx): %b", rw, slave_data_out, master_data_out);
		enable = 1;
		#4;
		enable = 0;
				
		#300;
		$display("[AFTER]  R/W = %b | Slave_data_out (tx): %b | Master_data_out (rx): %b", rw, slave_data_out, master_data_out);
		$finish;
		
	end      
endmodule
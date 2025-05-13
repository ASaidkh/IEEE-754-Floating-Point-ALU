`timescale 1ns / 1ps


module i2c_master_controller
(
	input wire clk,
	input wire rst,
//	input wire [6:0] addr, //Not needed since we have 2 boards
	input wire [65:0] data_in,
	input wire enable,
	input wire rw, //0: Write to slave, 1: Read from slave

	output reg [65:0] data_out,
	output wire ready,

	inout i2c_sda,
	output wire i2c_scl,
	output wire done
	);

	localparam IDLE = 0;
	localparam START = 1;
	// Note that we simplify this state to only send the read/write bit
	// insted of the address + rw bit
	localparam ADDRESS = 2; 
	localparam READ_ACK = 3;
	localparam WRITE_DATA = 4;
	localparam WRITE_ACK = 5;
	localparam READ_DATA = 6;
	localparam READ_ACK2 = 7;
	localparam STOP = 8;
	
	//2 = Disabled, using the same clock as clk
	localparam DIVIDE_BY = 100; 

	reg [3:0] state;
	reg [7:0] saved_addr;
	reg [65:0] saved_data;
	reg [6:0] counter;
	reg [7:0] counter2 = 0;
	reg write_enable;
	reg sda_out;
	reg i2c_scl_enable = 0;
	reg i2c_clk;
	reg donebuf;
	
    
	assign done = (state == READ_ACK2);

	assign ready = ((rst == 0) && (state == IDLE)) ? 1 : 0;
	assign i2c_scl = (i2c_scl_enable == 0 ) ? 1 : i2c_clk;
	assign i2c_sda = (write_enable == 1) ? sda_out : 'bz;
	
	
	always @(posedge clk or posedge rst) begin
	   if (rst) begin
	       i2c_clk <= 0;
	       counter2<= 0;
	   end
	   else if (counter2 == (DIVIDE_BY/2) - 1) begin
			i2c_clk <= ~i2c_clk;
			counter2 <= 0;
		end
		else counter2 <= counter2 + 1;
	end 
	
	
	
	always @(negedge i2c_clk, posedge rst) begin
		if(rst == 1) begin
			i2c_scl_enable <= 0;
		end else begin
			if ((state == IDLE) || (state == START) || (state == STOP)) begin
				i2c_scl_enable <= 0;
			end else begin
				i2c_scl_enable <= 1;
			end
		end
	
	end


	always @(posedge i2c_clk, posedge rst) begin
		if(rst == 1) begin
			state <= IDLE;
			data_out <= 0;
			saved_addr <= 0;
			counter <= 0;
			saved_data <= 0;
		end		
		else begin
			case(state)
			
				IDLE: begin
					if (enable) begin
						state <= START;
						// saved_addr <= {addr, rw};
						// Since we have a single slave, 
						// we only send the read/write bit
						saved_addr <= rw; 
						saved_data <= data_in;
					end
					else state <= IDLE;
				end

				START: begin
					// counter <= 7;
					counter <= 0; //Single rw bit 
					state <= ADDRESS;
				end

				ADDRESS: begin
					if (counter == 0) begin 
						state <= READ_ACK;
					end else counter <= counter - 1;
				end

				READ_ACK: begin
					if (i2c_sda == 0) begin
						counter <= 65;
						if(saved_addr[0] == 0) state <= WRITE_DATA;
						else state <= READ_DATA;
					end else state <= STOP;
				end

				WRITE_DATA: begin
					if(counter == 0) begin
						state <= READ_ACK2;
					end else counter <= counter - 1;
				end
				
				READ_ACK2: begin
					if ((i2c_sda == 0) && (enable == 1)) state <= IDLE;
					else state <= STOP;
				end

				READ_DATA: begin
					data_out[counter] <= i2c_sda;
					if (counter == 0) state <= WRITE_ACK;
					else counter <= counter - 1;
				end
				
				WRITE_ACK: begin
					state <= STOP;
				end

				STOP: begin
					state <= IDLE;
				end
				default: begin
				    state <= IDLE; data_out <= 0; saved_data <= 0; counter <= 0; saved_addr <= 0;
				end
			endcase
		end
	end
	
	always @(negedge i2c_clk, posedge rst) begin
		if(rst == 1) begin
			write_enable <= 1;
			sda_out <= 1;
		end else begin
			case(state)
				START: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				ADDRESS: begin
					sda_out <= saved_addr[counter];
				end
				
				READ_ACK: begin
					write_enable <= 0; 
				end
				
				WRITE_DATA: begin 
					write_enable <= 1;
					sda_out <= saved_data[counter];
				end
				
				WRITE_ACK: begin
					write_enable <= 1;
					sda_out <= 0;
				end
				
				READ_DATA: begin
					write_enable <= 0;				
				end
				
                READ_ACK2: begin
					write_enable <= 0; 
				end
				
				STOP: begin
					write_enable <= 1;
					sda_out <= 1;
				end
				default: begin
				    write_enable <= 1; sda_out <= 1;
				end
			endcase
		end
	end

endmodule
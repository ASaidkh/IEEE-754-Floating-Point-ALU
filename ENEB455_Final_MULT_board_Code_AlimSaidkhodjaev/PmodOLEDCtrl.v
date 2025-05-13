`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: Digilent Inc.
// Engineers: Ryan Kim
//				  Josh Sackos
// 
// Create Date:    14:00:51 06/12/2012
// Module Name:    PmodOLEDCtrl 
// Project Name: 	 PmodOLED Demo
// Target Devices: Nexys3
// Tool versions:  ISE 14.1
// Description: 	 Top level controller that controls the PmodOLED blocks
//
// Revision: 1.1
// Revision 0.01 - File Created
//////////////////////////////////////////////////////////////////////////////////
module PmodOLEDCtrl(
		CLK,
		RST,
		EN,
        Page0,
        Page1,
        Page2,
        Page3,
		CS,
		SDIN,
		SCLK,
		DC,
		RES,
		VBAT,
		VDD
    );

	// ===========================================================================
	// 										Port Declarations
	// ===========================================================================
	input CLK;
	input RST;
	input EN;
    input[127:0] Page0;
    input[127:0] Page1;
    input[127:0] Page2;
    input[127:0] Page3;
	output CS;
	output SDIN;
	output SCLK;
	output DC;
	output RES;
	output VBAT;
	output VDD;
	

	// ===========================================================================
	// 							  Parameters, Regsiters, and Wires
	// ===========================================================================
	wire CS, SDIN, SCLK, DC, FIN;
	wire VDD, VBAT, RES;
	reg[127:0] Page0_reg, Page1_reg, Page2_reg, Page3_reg;

	reg [110:0] current_state = "Idle";

	wire init_en;
	wire init_done;
	wire init_cs;
	wire init_sdo;
	wire init_sclk;
	wire init_dc;
	
	wire display_en;
	wire display_cs;
	wire display_sdo;
	wire display_sclk;
	wire display_dc;
	wire display_done;
	// ===========================================================================
	// 										Implementation
	// ===========================================================================
	OledInit Init(
			.CLK(CLK),
			.RST(RST),
			.EN(init_en),
			.CS(init_cs),
			.SDO(init_sdo),
			.SCLK(init_sclk),
			.DC(init_dc),
			.RES(RES),
			.VBAT(VBAT),
			.VDD(VDD),
			.FIN(init_done)
	);
	
	OledEX Display(
			.CLK(CLK),
			.RST(RST),
			.EN(display_en),
			.Page0(Page0_reg),
			.Page1(Page1_reg),
			.Page2(Page2_reg),
			.Page3(Page3_reg),
			.CS(display_cs),
			.SDO(display_sdo),
			.SCLK(display_sclk),
			.DC(display_dc),
			.FIN(display_done)
	);


	//MUXes to indicate which outputs are routed out depending on which block is enabled
	assign CS = (current_state == "OledInitialize") ? init_cs : display_cs;
	assign SDIN = (current_state == "OledInitialize") ? init_sdo : display_sdo;
	assign SCLK = (current_state == "OledInitialize") ? init_sclk : display_sclk;
	assign DC = (current_state == "OledInitialize") ? init_dc : display_dc;
	
	//MUXes that enable blocks when in the proper states
	assign init_en = (current_state == "OledInitialize") ? 1'b1 : 1'b0;
	assign display_en = (current_state == "OledDisplay") ? 1'b1 : 1'b0;
	
   //Display finish flag only high when in done state
    assign FIN = (current_state == "Done") ? 1'b1 : 1'b0;

	
	//  State Machine
	always @(posedge CLK) begin
			if(RST == 1'b1) begin
					current_state <= "Idle";
			end
			else begin
					case(current_state)
						"Idle" : begin
							current_state <= "OledInitialize";
						end
  					   // Go through the initialization sequence
						"OledInitialize" : begin
								if(init_done == 1'b1) begin
										current_state <= "OledReady";
								end
						end
						"OledReady" : begin
						        if(EN == 1'b1) begin
                                        Page0_reg <= Page0;
                                        Page1_reg <= Page1;
                                        Page2_reg <= Page2;
                                        Page3_reg <= Page3;
						                current_state <= "OledDisplay";
						        end
						end
						// Do Display and go into Done state when finished
						"OledDisplay" : begin
								if(display_done == 1'b1) begin
										current_state <= "Done";
								end
						end			
						
						// If EN is de-asserted, go back to Ready state
						"Done" : begin
                                if(EN == 1'b0) begin
                                    current_state <= "OledReady";
                                end
                        end
						
						default : current_state <= "Idle";
					endcase
			end
	end

endmodule

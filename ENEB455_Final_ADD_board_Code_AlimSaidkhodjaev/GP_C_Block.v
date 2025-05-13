`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 02/12/2025 11:31:04 AM
// Design Name: 
// Module Name: GP_C_Block
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


module GP_C_Block (
    // GP/H inputs
    input  wire Gh,   // High-group generate
    input  wire Ph,   // High-group propagate
    input  wire Gl,   // Low-group generate
    input  wire Pl,   // Low-group propagate
    // Carry input
    input  wire Cin,  // Carry input

    // GP/H outputs
    output wire Ghl,  // Combined generate output (high and low groups)
    output wire Phl,  // Combined propagate output (high and low groups)
    // Carry outputs
    output wire Ch,   // Computed carry output from low group and Cin
    output wire Cl    // Pass-through carry (Cin)
);

    // Combine the high and low group signals for generate:
    // Ghl = Gh OR (Ph AND Gl)
    assign Ghl = Gh | (Ph & Gl);
    
    // Combine the high and low group signals for propagate:
    // Phl = Ph OR Pl
    assign Phl = Ph & Pl;
    
    // Compute the carry outputs:
    // Ch = Gl OR (Pl AND Cin)
    assign Ch = Gl | (Pl & Cin);
    
    // Cl is simply the carry input
    assign Cl = Cin;

endmodule
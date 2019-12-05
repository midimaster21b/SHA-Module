`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date: 12/04/2019 08:31:28 PM
// Design Name:
// Module Name: sha_algo
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A verilog implementation of SHA-256
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module sha_algo(
		// Inputs
		input clk_p,
		input reset_p,

		// Data inputs
		input [511:0] message_p,
		input ready_p,

		// Data outputs
		output [255:0] hash_p,
		output valid_p
);
   reg [255:0]	       hash_s;

   assign valid_p = 0;
   assign hash_p = hash_s;


   always @(posedge clk_p)begin
      hash_s  <= 256'b0;
   end

endmodule

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
// 1. Assumes the supplied 512 bit block is properly formatted
//////////////////////////////////////////////////////////////////////////////////


module sha_algo(
		// Inputs
		input	       clk_p,
		input	       reset_p,

		// Message inputs
		input [511:0]  message_p,
		input	       message_valid_p,
		output	       message_ready_p,

		// Hash outputs
		output [255:0] hash_p,
		output	       hash_valid_p,
		input	       hash_ready_p
);

   reg [255:0]	       hash_s;
   reg [31:0]	       weights [63:0];

   assign valid_p = 0;
   assign hash_p = hash_s;

   // always @* begin
   //    if ready

   // Assign hash value
   always @(posedge clk_p)begin
      hash_s  <= 256'b0;
   end

   // Fill in


endmodule

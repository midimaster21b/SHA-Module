`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date: 12/04/2019 08:54:36 PM
// Design Name:
// Module Name: sha_algo_tb
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


module sha_algo_tb();

   reg clk_s = 0;
   reg reset_s = 0;

   // Message port
   // reg [511:0] message_s = 512'h01234567_89ABCDEF;

   // "abcd" hash block
   reg [511:0] message_s = 512'h00000020_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_00000000_80000000_61626364;
   wire	       message_ready_s;
   reg	       message_valid_s = 0;

   // Hash port
   wire [255:0] hash_s;
   wire		hash_valid_s;
   reg		hash_ready_s = 0;

   // Generate clock signal
   always #10 clk_s <= ~clk_s;

   // Start hash at 100 ns;
   initial #100 message_valid_s <= 1;
   initial #110 message_valid_s <= 0;

   sha_algo sha(
		// Inputs
		.clk_p(clk_s),
		.reset_p(reset_s),

		// Data inputs
		.message_p(message_s),
		.message_valid_p(message_valid_s),
		.message_ready_p(message_ready_s),

		// Data outputs
		.hash_p(hash_s),
		.hash_valid_p(hash_valid_s),
		.hash_ready_p(hash_ready_s)
		);


endmodule

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

   reg [511:0] message_s = 512'b0;
   reg	       ready_s = 0;

   wire [255:0] hash_s;
   wire		valid_s;

   // Generate clock signal
   always #10 clk_s <= ~clk_s;

   sha_algo sha(
		// Inputs
		.clk_p(clk_s),
		.reset_p(reset_s),

		// Data inputs
		.message_p(message_s),
		.ready_p(ready_s),

		// Data outputs
		.hash_p(hash_s),
		.valid_p(valid_s)
		);


endmodule

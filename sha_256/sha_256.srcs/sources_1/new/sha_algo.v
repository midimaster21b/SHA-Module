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

// States:
// - Idle: Wait for message to be supplied
// - Make_Weights: Produce message schedule array
// - Compression: 64 iterations of the compression algorithm
// - Hash_Finished: Output finished hash
//////////////////////////////////////////////////////////////////////////////////


// Hash constants
`define NUM_ITERATIONS_C 64

// State definitions
`define IDLE_STATE           4'h0
`define MAKE_WEIGHTS_STATE   4'h2
`define COMPRESSION_STATE    4'h3
`define HASH_FINISHED_STATE  4'h4

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

   reg [511:0]		       message_s;
   reg [255:0]		       hash_s;
   reg			       busy_s = 0;

   // 64 independently calculated 32 bit values
   reg [31:0]		       weights [63:0];
   integer		       weight_i=0;
   integer		       message_i=0;

   reg [3:0]		       curr_state_s;
   reg [3:0]		       next_state_s;

   integer		       compression_iter_s = 0;

   assign hash_valid_p = 0;
   assign hash_p = hash_s;
   assign message_ready_p = ~busy_s;

   // Next state logic
   always @* begin
      case (curr_state_s)
	`IDLE_STATE:
	  if(message_valid_p == 1) begin
	     next_state_s <= `MAKE_WEIGHTS_STATE;

	  end
	  else begin
	    next_state_s <= `IDLE_STATE;

	  end

	`MAKE_WEIGHTS_STATE:
	  next_state_s <= `COMPRESSION_STATE;


	`COMPRESSION_STATE:
	  if(compression_iter_s >= `NUM_ITERATIONS_C-1) begin
	     next_state_s <= `HASH_FINISHED_STATE;

	  end
	  else begin
	    next_state_s <= `COMPRESSION_STATE;

	  end

	`HASH_FINISHED_STATE:
	  next_state_s <= `IDLE_STATE;

	default:
	  next_state_s <= `IDLE_STATE; // default to IDLE
      endcase // case curr_state_s
   end


   // Advance state
   always @(posedge clk_p) begin
      curr_state_s <= next_state_s;
   end


   // Latch input message
   always @(posedge clk_p) begin
      if(curr_state_s == `IDLE_STATE) begin
	 message_s <= message_p;
      end
   end


   // Fill in weights
   always @* begin
      if(curr_state_s == `IDLE_STATE) begin
	 // Copy 32 bit words into first 16 slots of the message schedule array
	 for(message_i=0; message_i<16; message_i = message_i+1) begin
	    // weights[message_i] <= message_p[(((message_i+1)*32)-1):(message_i*32)];
	    weights[message_i] <= message_p[(((message_i+1)*32)-1) +: 32];
	 end
      end
      // else if curr_state_s == `MAKE_WEIGHTS_STATE begin
      //	 // for(weight_i=0; weight_i<64; weight_i++) begin

      //	 // end
      // end
   end



   // Assign hash value
   always @(posedge clk_p) begin
      hash_s  <= 256'b0;
   end


endmodule

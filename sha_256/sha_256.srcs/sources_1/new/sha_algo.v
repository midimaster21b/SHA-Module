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

   reg [3:0]		       curr_state_s = `IDLE_STATE;
   reg [3:0]		       next_state_s = `IDLE_STATE;

   integer		       compression_iter_s = 0;

   reg [31:0]		       s0 [63:0];
   reg [31:0]		       s1 [63:0];
   reg [31:0]		       w0 [63:0];
   reg [31:0]		       w1 [63:0];


   function right_rotate;
      input [31:0]	       data;
      input [7:0]	       rotations;

      integer		       rot_i;
      reg [31:0]	       retval;

      begin
	 retval = data;
	 for(rot_i=0; rot_i<rotations; rot_i = rot_i+1) begin
	    retval = {retval[0], retval[31:1]};
	 end

	 right_rotate = retval;

	 // right_rotate = {data[0 +: rotations], data[31 -: (32-rotations)]};
	 // right_rotate = {data[rotations-1:0], data[31:rotations]};

      end
   endfunction


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
	 // for(message_i=0; message_i<16; message_i++) begin
	 for(message_i=0; message_i<16; message_i = message_i+1) begin
	    // https://forums.xilinx.com/t5/Design-Entry/Verilog-Loop-error-range-must-be-bounded-by-constant-expressions/td-p/721765
	    weights[message_i] <= message_p[(message_i*32) +: 32];
	 end
      end

      else if(curr_state_s == `MAKE_WEIGHTS_STATE) begin
	 for(weight_i=16; weight_i<64; weight_i = weight_i+1) begin

	    s0[weight_i] = right_rotate(weights[weight_i-15], 7) ^ right_rotate(weights[weight_i-15], 18) ^ right_rotate(weights[weight_i-15], 3);
	    // s1[weight_i] = right_rotate(weights[weight_i-15], 7);
	    // w0[weight_i] = right_rotate(weights[weight_i-15], 18);
	    // w1[weight_i] = right_rotate(weights[weight_i-15], 3);
	    s1[weight_i] = right_rotate(weights[weight_i-2], 17) ^ right_rotate(weights[weight_i-2], 19) ^ right_rotate(weights[weight_i-2], 10);

	    w0[weight_i] = weights[weight_i-16];
	    w1[weight_i] = weights[weight_i-7];

	    // weights[weight_i] = (
	    //			 right_rotate(weights[weight_i-15], 7)
	    //			 ^ right_rotate(weights[weight_i-15], 18)
	    //			 ^ right_rotate(weights[weight_i-15], 3)
	    //			 ) +
	    //			(
	    //			 right_rotate(weights[weight_i-2], 17)
	    //			 ^ right_rotate(weights[weight_i-2], 19)
	    //			 ^ right_rotate(weights[weight_i-2], 10)
	    //			 ) +
	    //			weights[weight_i-16] +
	    //			weights[weight_i-7];

	    weights[weight_i] = (
				 {weights[weight_i-15][6:0], weights[weight_i-15][31:7]} // 7
				 ^ {weights[weight_i-15][17:0], weights[weight_i-15][31:18]} // 18
				 ^ {weights[weight_i-15][2:0], weights[weight_i-15][31:3]} // 3
				 ) +
				(
				 {weights[weight_i-2][16:0], weights[weight_i-2][31:17]} // 17
				 ^ {weights[weight_i-2][18:0], weights[weight_i-2][31:19]} // 19
				 ^ {weights[weight_i-2][9:0], weights[weight_i-2][31:10]} // 10
				 ) +
				weights[weight_i-16] +
				weights[weight_i-7];

	 end
      end
   end


   // Assign hash value
   always @(posedge clk_p) begin
      hash_s  <= 256'b0;
   end


endmodule

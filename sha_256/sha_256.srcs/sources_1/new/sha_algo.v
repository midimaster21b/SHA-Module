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
   reg 			       hash_valid_s;
   reg			       busy_s = 0;

   // 64 independently calculated 32 bit values
   reg [31:0]		       weights [63:0];
   reg [31:0]		       calc_constants [63:0];
   integer		       weight_i=0;
   integer		       message_i=0;

   reg [3:0]		       curr_state_s = `IDLE_STATE;
   reg [3:0]		       next_state_s = `IDLE_STATE;

   integer		       compression_iter_s = 0;

   reg [31:0]		       s0 [63:0];
   reg [31:0]		       s1 [63:0];
   reg [31:0]		       w0 [63:0];
   reg [31:0]		       w1 [63:0];


   // Compression registers
   // h0 := 0x6a09e667
   // h1 := 0xbb67ae85
   // h2 := 0x3c6ef372
   // h3 := 0xa54ff53a
   // h4 := 0x510e527f
   // h5 := 0x9b05688c
   // h6 := 0x1f83d9ab
   // h7 := 0x5be0cd19
   reg [31:0]		       compression_regs_s [7:0];


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


   assign hash_valid_p = hash_valid_s;
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
	  // if(hash_ready_p == 1) begin
	  //    next_state_s <= `IDLE_STATE;

	  // end
	  // else begin
	  //    next_state_s <= `HASH_FINISHED_STATE;

	  // end

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

	    s0[weight_i] = {weights[weight_i-15][6:0], weights[weight_i-15][31:7]} ^ {weights[weight_i-15][17:0], weights[weight_i-15][31:18]} ^ (weights[weight_i-15] >> 3);
	    // s1[weight_i] = {weights[weight_i-15][6:0], weights[weight_i-15][31:7]};
	    // w0[weight_i] = {weights[weight_i-15][17:0], weights[weight_i-15][31:18]};
	    // w1[weight_i] = {weights[weight_i-15][2:0], weights[weight_i-15][31:3]};


	    // s1[weight_i] = right_rotate(weights[weight_i-2], 17) ^ right_rotate(weights[weight_i-2], 19) ^ right_rotate(weights[weight_i-2], 10);
	    // s1[weight_i] = right_rotate(weights[weight_i-2], 17) ^ right_rotate(weights[weight_i-2], 19) ^ right_rotate(weights[weight_i-2], 10);

	    w0[weight_i] = weights[weight_i-16];
	    w1[weight_i] = weights[weight_i-7];

	    weights[weight_i] = (
				 {weights[weight_i-15][6:0], weights[weight_i-15][31:7]} // 7
				 ^ {weights[weight_i-15][17:0], weights[weight_i-15][31:18]} // 18
				 ^ (weights[weight_i-15] >> 3) // 3
				 ) +
				(
				 {weights[weight_i-2][16:0], weights[weight_i-2][31:17]} // 17
				 ^ {weights[weight_i-2][18:0], weights[weight_i-2][31:19]} // 19
				 ^ (weights[weight_i-2] >> 10) // 10
				 ) +
				weights[weight_i-16] +
				weights[weight_i-7];

	 end
      end
   end


   // Assign hash value
   always @(posedge clk_p) begin
      if(curr_state_s == `HASH_FINISHED_STATE) begin
	 hash_s <= {(32'h6a09e667 + compression_regs_s[0]),
		    (32'hbb67ae85 + compression_regs_s[1]),
		    (32'h3c6ef372 + compression_regs_s[2]),
		    (32'ha54ff53a + compression_regs_s[3]),
		    (32'h510e527f + compression_regs_s[4]),
		    (32'h9b05688c + compression_regs_s[5]),
		    (32'h1f83d9ab + compression_regs_s[6]),
		    (32'h5be0cd19 + compression_regs_s[7])};

	 hash_valid_s <= 1;
      end
      else begin
	 hash_s <= 256'h0;
	 hash_valid_s <= 0;

      end
   end


   always @(posedge clk_p) begin
      // Compression registers
      // h0 := 0x6a09e667
      // h1 := 0xbb67ae85
      // h2 := 0x3c6ef372
      // h3 := 0xa54ff53a
      // h4 := 0x510e527f
      // h5 := 0x9b05688c
      // h6 := 0x1f83d9ab
      // h7 := 0x5be0cd19

      if(curr_state_s == `COMPRESSION_STATE) begin
	 // compression_regs_s[7] <= compression_regs_s[6];
	 // compression_regs_s[6] <= compression_regs_s[5];
	 // compression_regs_s[5] <= compression_regs_s[4];
	 // compression_regs_s[4] <= compression_regs_s[3] + temp1;
	 // compression_regs_s[3] <= compression_regs_s[2];
	 // compression_regs_s[2] <= compression_regs_s[1];
	 // compression_regs_s[1] <= compression_regs_s[0];
	 // compression_regs_s[0] <= temp1 + temp2;

	 compression_regs_s[7] <= compression_regs_s[6];
	 compression_regs_s[6] <= compression_regs_s[5];
	 compression_regs_s[5] <= compression_regs_s[4];
	 compression_regs_s[4] <= compression_regs_s[3]
				  + (
				     compression_regs_s[7]                                             // h
				     + ({compression_regs_s[4][5:0], compression_regs_s[4][31:6]}      // e rotate 6
					^ {compression_regs_s[4][10:0], compression_regs_s[4][31:11]}  // e rotate 11
					^ {compression_regs_s[4][24:0], compression_regs_s[4][31:25]}) // e rotate 25
				     + (((compression_regs_s[4] & compression_regs_s[5])               // e and f
					 ^ ((~compression_regs_s[4]) & compression_regs_s[6])))        // (not e) & g
				     + calc_constants[compression_iter_s]                              // k[i]
				     + weights[compression_iter_s]                                     // w[i]
				     );

	 compression_regs_s[3] <= compression_regs_s[2];
	 compression_regs_s[2] <= compression_regs_s[1];
	 compression_regs_s[1] <= compression_regs_s[0];
	 // compression_regs_s[0] <= temp1 + temp2;
	 compression_regs_s[0] <= ( //temp1
				   compression_regs_s[7]                                             // h
				   + ({compression_regs_s[4][5:0], compression_regs_s[4][31:6]}      // e rotate 6
				      ^ {compression_regs_s[4][10:0], compression_regs_s[4][31:11]}  // e rotate 11
				      ^ {compression_regs_s[4][24:0], compression_regs_s[4][31:25]}) // e rotate 25
				   + (((compression_regs_s[4] & compression_regs_s[5])               // e and f
				       ^ ((~compression_regs_s[4]) & compression_regs_s[6])))        // (not e) & g
				   + calc_constants[compression_iter_s]                              // k[i]
				   + weights[compression_iter_s]                                     // w[i]
				   )
	   + (// temp2
	      (// S0
	       {compression_regs_s[0][1:0], compression_regs_s[0][31:2]}      // a rotate 2
	       ^ {compression_regs_s[0][12:0], compression_regs_s[0][31:13]}  // a rotate 13
	       ^ {compression_regs_s[0][21:0], compression_regs_s[0][31:22]}  // a rotate 22
	       )
	      + (// Maj
		 (compression_regs_s[0] & compression_regs_s[1])              // a and b
		 ^ (compression_regs_s[0] & compression_regs_s[2])            // a and c
		 ^ (compression_regs_s[1] & compression_regs_s[2])            // b and c
		 )
	      );

      end
      else if(curr_state_s == `HASH_FINISHED_STATE) begin
	 compression_regs_s[0] <= 32'h6a09e667 + compression_regs_s[0];
	 compression_regs_s[1] <= 32'hbb67ae85 + compression_regs_s[1];
	 compression_regs_s[2] <= 32'h3c6ef372 + compression_regs_s[2];
	 compression_regs_s[3] <= 32'ha54ff53a + compression_regs_s[3];
	 compression_regs_s[4] <= 32'h510e527f + compression_regs_s[4];
	 compression_regs_s[5] <= 32'h9b05688c + compression_regs_s[5];
	 compression_regs_s[6] <= 32'h1f83d9ab + compression_regs_s[6];
	 compression_regs_s[7] <= 32'h5be0cd19 + compression_regs_s[7];

      end
      else begin
	 compression_regs_s[0] <= 32'h6a09e667;
	 compression_regs_s[1] <= 32'hbb67ae85;
	 compression_regs_s[2] <= 32'h3c6ef372;
	 compression_regs_s[3] <= 32'ha54ff53a;
	 compression_regs_s[4] <= 32'h510e527f;
	 compression_regs_s[5] <= 32'h9b05688c;
	 compression_regs_s[6] <= 32'h1f83d9ab;
	 compression_regs_s[7] <= 32'h5be0cd19;

      end

   end


   always @(posedge clk_p) begin
      calc_constants[0]  = 32'h428a2f98;
      calc_constants[1]  = 32'h71374491;
      calc_constants[2]  = 32'hb5c0fbcf;
      calc_constants[3]  = 32'he9b5dba5;
      calc_constants[4]  = 32'h3956c25b;
      calc_constants[5]  = 32'h59f111f1;
      calc_constants[6]  = 32'h923f82a4;
      calc_constants[7]  = 32'hab1c5ed5;
      calc_constants[8]  = 32'hd807aa98;
      calc_constants[9]  = 32'h12835b01;
      calc_constants[10] = 32'h243185be;
      calc_constants[11] = 32'h550c7dc3;
      calc_constants[12] = 32'h72be5d74;
      calc_constants[13] = 32'h80deb1fe;
      calc_constants[14] = 32'h9bdc06a7;
      calc_constants[15] = 32'hc19bf174;
      calc_constants[16] = 32'he49b69c1;
      calc_constants[17] = 32'hefbe4786;
      calc_constants[18] = 32'h0fc19dc6;
      calc_constants[19] = 32'h240ca1cc;
      calc_constants[20] = 32'h2de92c6f;
      calc_constants[21] = 32'h4a7484aa;
      calc_constants[22] = 32'h5cb0a9dc;
      calc_constants[23] = 32'h76f988da;
      calc_constants[24] = 32'h983e5152;
      calc_constants[25] = 32'ha831c66d;
      calc_constants[26] = 32'hb00327c8;
      calc_constants[27] = 32'hbf597fc7;
      calc_constants[28] = 32'hc6e00bf3;
      calc_constants[29] = 32'hd5a79147;
      calc_constants[30] = 32'h06ca6351;
      calc_constants[31] = 32'h14292967;
      calc_constants[32] = 32'h27b70a85;
      calc_constants[33] = 32'h2e1b2138;
      calc_constants[34] = 32'h4d2c6dfc;
      calc_constants[35] = 32'h53380d13;
      calc_constants[36] = 32'h650a7354;
      calc_constants[37] = 32'h766a0abb;
      calc_constants[38] = 32'h81c2c92e;
      calc_constants[39] = 32'h92722c85;
      calc_constants[40] = 32'ha2bfe8a1;
      calc_constants[41] = 32'ha81a664b;
      calc_constants[42] = 32'hc24b8b70;
      calc_constants[43] = 32'hc76c51a3;
      calc_constants[44] = 32'hd192e819;
      calc_constants[45] = 32'hd6990624;
      calc_constants[46] = 32'hf40e3585;
      calc_constants[47] = 32'h106aa070;
      calc_constants[48] = 32'h19a4c116;
      calc_constants[49] = 32'h1e376c08;
      calc_constants[50] = 32'h2748774c;
      calc_constants[51] = 32'h34b0bcb5;
      calc_constants[52] = 32'h391c0cb3;
      calc_constants[53] = 32'h4ed8aa4a;
      calc_constants[54] = 32'h5b9cca4f;
      calc_constants[55] = 32'h682e6ff3;
      calc_constants[56] = 32'h748f82ee;
      calc_constants[57] = 32'h78a5636f;
      calc_constants[58] = 32'h84c87814;
      calc_constants[59] = 32'h8cc70208;
      calc_constants[60] = 32'h90befffa;
      calc_constants[61] = 32'ha4506ceb;
      calc_constants[62] = 32'hbef9a3f7;
      calc_constants[63] = 32'hc67178f2;
   end


   always @(posedge clk_p) begin
      if(curr_state_s == `COMPRESSION_STATE) begin
	 compression_iter_s <= compression_iter_s + 1;

      end
      else begin
	 compression_iter_s <= 0;

      end
   end

endmodule

//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date: 10/19/2022 11:47:28 PM
// Design Name:
// Module Name: sha_algo_wrapper
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A SystemVerilog wrapper of the SHA-256 module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


// Message
interface msg_if ();
   logic [511:0]       message;
   logic	       message_valid;
   logic	       message_ready;

   modport TB  (output message, message_valid, input  message_ready);
   modport DUT (input  message, message_valid, output message_ready);
endinterface // msg_if


// Hash
interface hash_if ();
   logic [255:0]       hash;
   logic	       hash_valid;
   logic	       hash_ready;

   modport TB  (output hash_ready, input  hash, hash_valid);
   modport DUT (input  hash_ready, output hash, hash_valid);
endinterface // hash_if


module sha_algo_wrapper(
		// Inputs
		input clk_p,
		input rst_p,

		// Message interface
		msg_if msg,

		// Hash interface
		hash_if hash
		);


   sha_algo dut (
		 // Control
		 .clk_p(clk_p),
		 .reset_p(rst_p),

		 // Message
		 .message_p(msg.message),
		 .message_valid_p(msg.message_valid),
		 .message_ready_p(msg.message_ready),

		 // Hash
		 .hash_p(hash.hash),
		 .hash_valid_p(hash.hash_valid),
		 .hash_ready_p(hash.hash_ready)
		 );

endmodule

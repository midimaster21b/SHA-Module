`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date:    18:43:12 11/29/2009
// Design Name:
// Module Name:    top
// Project Name:
// Target Devices:
// Tool versions:
// Description:
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
module top(
	   input wire 	      clk,
	   input wire 	      reset,
	   input wire [1:0]   start,
	   input wire [31:0]  data,   // Bytes being read
	   input wire [8:0]   length, // How many bytes to read
	   input wire [9:0]   encrypt_data_addr, // Where to start reading

	   output wire [2:0]  stop, // Finish signal
	   output wire [8:0]  data_addr, // Write data address
	   output wire [31:0] hash_data, // Hash data output
	   output wire [3:0]  we
	   );

   // ADDED PORTS
   wire [31:0] 		      hash_data_s;

   /////////////////////////////////////////////////////////

   /* ************ KEY BRAM INSTANTIATION *************** */
   // key_mem key1 (
   //		 .clka(clk),       // input wire clka
   //		 .wea(1'b0),       // input wire [0 : 0] wea
   //		 .addra(key_addr), // input wire [7 : 0] addra
   //		 .dina(32'h0),     // input wire [31 : 0] dina
   //		 .douta(key_out)  // output wire [31 : 0] douta
   //		 );

   // /* ************ DATA BRAM INSTANTIATION ************** */
   // data_mem data1 (
   //		   .clka(clk),         // input wire clka
   //		   .wea(we),           // input wire [0 : 0] wea
   //		   .addra(data_addr),  // input wire [8 : 0] addra
   //		   .dina(data_in),     // input wire [31 : 0] dina
   //		   .douta(data_out)    // output wire [31 : 0] douta
   //		   );

   /////////////////////////////////////////////////////////

   assign we = 4'hf;
   assign hash_data = (we == 4'hf) ? hash_data_s : 32'h0;
   // assign hash_data = 32'h1234_ABCD;
   // assign data_addr = encrypt_data_addr + 16;
   assign data_addr = encrypt_data_addr + 8;

   /* *************** ENCRYPTION ************************ */

   encrypt E1(
	      // Inputs
	      .clk(clk),
	      .reset(reset),
	      .start(start),
	      .data(data), // Data to be hashed

	      // Outputs
	      .finished(en_stop), // Finish signal
	      .hash(hash_data_s)  // Output hash
	      );

endmodule

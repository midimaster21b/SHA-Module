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
module top(clk,
	   reset,
	   start,
	   stop,
	   key_addr,
	   data_addr,
	   data_in,
	   we,
	   data_out,
	   length,
	   key_out,
	   encrypt_data_addr
	   );

   input clk,reset;
   input [0:1] start;
   //input [0:8]length;

   // ADDED PORTS
   input [31:0] data_out;
   input [31:0] key_out;
   input [8:0]	length;
   input [9:0]	encrypt_data_addr;

   output [0:2] stop;
   output [0:31] data_in;
   output [0:7]  key_addr;
   output [0:8]  data_addr;
   output	 we;


   wire [0:7]	 key_addr,en_key_addr;
   // wire [0:31]	 key_out,data_in,en_data_in,data_out;
   wire [0:31]	 en_data_in,data_out;
   wire [0:8]	 en_data_addr,data_addr;
   wire [0:2]	 en_stop;
   wire		 we,en_we;

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

   assign stop = en_stop;

   assign key_addr = en_key_addr;

   assign we = en_we;

   assign data_addr = en_data_addr;

   assign data_in = (en_we) ? en_data_in : 32'h0;

   /* *************** ENCRYPTION ************************ */

   encrypt E1(
	      .clk(clk),
	      .reset(reset),
	      .start(start),
	      .stop(en_stop),
	      .key_addr(en_key_addr),
	      .key_in(key_out),
	      .data_addr(en_data_addr),
	      .data_in(data_out),
	      .encrypt_data(en_data_in),
	      .we(en_we)
	      );

endmodule

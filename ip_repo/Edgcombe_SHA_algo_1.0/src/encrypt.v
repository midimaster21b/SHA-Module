`timescale 1ns / 1ns
//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date:    18:43:34 11/29/2009
// Design Name:
// Module Name:    encrypt
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
module encrypt(
	       input wire 	  clk,
	       input wire 	  reset,
	       input wire [1:0]   start, // Start signal
	       input wire [31:0]  data, // Data to be hashed

	       // output reg [2:0]  finished, // Finished signal
	       // output reg [31:0] hash  // Output hashed
	       output wire [2:0]  finished, // Finished signal
	       output wire [31:0] hash  // Output hashed
	       );

   assign hash = 32'h0123_4567;
   assign finished = 3'b010;

   // always @(posedge clk) begin
   //    hash <= 32'h0123_4567;
   //    finished <= 3'b111;
   //    // finished <= 3'b010;
   // end
endmodule

//    parameter delay = 0;
//    parameter s0 = 2'b0;
//    parameter s1 = 2'b01;
//    parameter s2 = 2'b10;
//    parameter s3 = 2'b11;

//    parameter m0 = 1'b0;
//    parameter m1 = 1'b1;


//    reg [1:0] 			 curr_state, next_state;
//    reg				 curr_state1, next_state1;
//    reg [2:0] 			 stop;
//    reg [8:0] 			 read_data_addr,write_data_addr;
//    reg [1:0] 			 count,count1;

//    reg				 ack,done,inc_count,start_encrypt,write_done,we,reset_count;
//    reg				 start_encrypt1,start_encrypt2,start_encrypt3,start_encrypt4,start_write;
//    reg				 inc_key_addr,reset_key_addr;
//    reg				 inc_readdata_addr,reset_readdata_addr;
//    reg				 inc_writedata_addr,reset_writedata_addr;

//    reg [31:0] 			 encrypt_data,encrypt_data1,encrypt_data2,encrypt_data3,encrypt_data4;


//    ////////////////////////////////////////////////////////////

//    // stop and ack s/g for encrypt
//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	stop <= #delay 3'b0;

//       else
// 	if(ack)
// 	  stop <= #delay 3'b001;			// s/g for removing start
// 	else if(done)
// 	  stop <= #delay 3'b010;			// s/g indicating encyption done
//    end

//    /////////////////////////////////////////////////////////////

//    // increment counter
//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	count <= #delay 2'b0;

//       // COUNTER FOR READING DATA & KEY
//       else if(inc_count)
// 	count <= #delay (count + 1);

//       else if(reset_count)
// 	count <= #delay 2'b0;
//    end

//    ////////////////////////////////////////////////////////////

//    assign data_addr = (we) ? write_data_addr : read_data_addr;


//    ///////////////////////// STATE M/C FOR ENCRYPTION ///////////////////////

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	curr_state <= #delay s0;
//       else
// 	curr_state <= #delay next_state;
//    end


//    always @(curr_state or start or count or key_addr or read_data_addr or write_done) begin
//       ack = 1'b0;
//       done = 1'b0;
//       inc_count = 1'b0;
//       inc_key_addr = 1'b0;
//       inc_readdata_addr = 1'b0;
//       reset_readdata_addr = 1'b0;
//       reset_writedata_addr= 1'b0;
//       reset_key_addr = 1'b0;
//       start_encrypt = 1'b0;
//       reset_count = 1'b0;
//       next_state = s0;

//       case(curr_state)

// 	s0: begin
// 	   if(start == 2'b01) begin
// 	      ack = 1'b1;
// 	      inc_count = 1'b1;
// 	      inc_key_addr = 1'b1;
// 	      inc_readdata_addr = 1'b1;
// 	      next_state = s1;
// 	   end
// 	   else
// 	     next_state = s0;
// 	end


// 	s1: begin
// 	   if(count == 2'b11) begin
// 	      start_encrypt = 1'b1;
// 	      next_state = s2;
// 	   end
// 	   else begin
// 	      inc_count = 1'b1;
// 	      inc_key_addr = 1'b1;
// 	      inc_readdata_addr = 1'b1;
// 	      start_encrypt = 1'b1;
// 	      next_state = s1;
// 	   end
// 	end


// 	s2: begin
// 	   start_encrypt = 1'b1;
// 	   next_state = s3;
// 	end


// 	s3: begin
// 	   if(write_done) begin
// 	      reset_readdata_addr = 1'b1;
// 	      reset_writedata_addr = 1'b1;
// 	      reset_key_addr = 1'b1;
// 	      done = 1'b1;
// 	      reset_count = 1'b1;
// 	      next_state = s0;
// 	   end
// 	   else
// 	     next_state = s3;
// 	end



// 	default: begin
// 	   ack = 1'b0;
// 	   inc_count = 1'b0;
// 	   inc_key_addr = 1'b0;
// 	   inc_readdata_addr = 1'b0;
// 	   start_encrypt = 1'b0;
// 	   reset_readdata_addr = 1'b0;
// 	   reset_writedata_addr = 1'b0;
// 	   reset_key_addr = 1'b0;
// 	   reset_count = 1'b0;
// 	   done = 1'b0;
// 	   next_state = s0;
// 	end
//       endcase
//    end


//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	count1 <= #delay 2'b0;
//       else
// 	count1 <= #delay count;
//    end


//    //  XOR OF DATA AND KEY
//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	encrypt_data1 <= #delay 32'h0;
//       else if(start_encrypt) begin
// 	 case(count1)
// 	   2'b00: encrypt_data1 <= #delay (key_in + data_in);
// 	   2'b01: encrypt_data1 <= #delay (key_in & data_in);
// 	   2'b10: encrypt_data1 <= #delay (data_in - key_in);
// 	   2'b11: encrypt_data1 <= #delay (key_in ^ data_in);
// 	   default: encrypt_data1 <= #delay encrypt_data1;
// 	 endcase
//       end
//    end

//    /////////////////// STATE M/C FOR STORING RESULT IN MEMORY /////////////////

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	curr_state1 <= #delay m0;
//       else
// 	curr_state1 <= #delay next_state1;
//    end

//    always @(curr_state1 or start_write or start_encrypt4) begin
//       we = 1'b0;
//       inc_writedata_addr = 1'b0;
//       write_done = 1'b0;
//       next_state1 = m0;

//       case(curr_state1)

// 	m0: begin
// 	   if(start_write) begin
// 	      we = 1'b1;
// 	      inc_writedata_addr = 1'b1;
// 	      next_state1 = m1;
// 	   end
// 	   else
// 	     next_state1 = m0;
// 	end

// 	m1: begin
// 	   if(!start_encrypt4) begin
// 	      write_done = 1'b1;
// 	      we = 1'b1;
// 	      next_state1 = m0;
// 	   end
// 	   else begin
// 	      we = 1'b1;
// 	      inc_writedata_addr = 1'b1;
// 	      next_state1 = m1;
// 	   end
// 	end

// 	default: begin
// 	   we = 1'b0;
// 	   write_done = 1'b0;
// 	   inc_writedata_addr = 1'b0;
// 	   next_state1 = m0;
// 	end
//       endcase
//    end


//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	start_encrypt1 <= #delay 1'b0;
//       else
// 	start_encrypt1 <= #delay start_encrypt;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	start_encrypt2 <= #delay 1'b0;
//       else
// 	start_encrypt2 <= #delay start_encrypt1;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	start_encrypt3 <= #delay 1'b0;
//       else
// 	start_encrypt3 <= #delay start_encrypt2;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	start_encrypt4 <= #delay 1'b0;
//       else
// 	start_encrypt4 <= #delay start_encrypt3;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	start_write <= #delay 1'b0;
//       else
// 	start_write <= #delay start_encrypt4;
//    end

//    //////////////////////////////////////////////////

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	encrypt_data2 <= #delay 32'b0;
//       else
// 	encrypt_data2 <= #delay encrypt_data1;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	encrypt_data3 <= #delay 32'b0;
//       else
// 	encrypt_data3 <= #delay encrypt_data2;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	encrypt_data4 <= #delay 32'b0;
//       else
// 	encrypt_data4 <= #delay encrypt_data3;
//    end

//    always @(posedge clk or negedge reset) begin
//       if(!reset)
// 	encrypt_data <= #delay 32'b0;
//       else
// 	encrypt_data <= #delay encrypt_data4;
//    end
// endmodule

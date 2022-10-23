//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date: 10/20/2022 12:50:49 AM
// Design Name:
// Module Name: sha_uvm_tb_top
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A UVM module level testbench for the SHA-256 module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////


module sha_uvm_tb_top;
   import uvm_pkg::*;

   bit clk;
   bit rst = 1;

   always  #10  clk <= ~clk;
   initial #100 rst <= 0;


   // Instantiate DUT and interfaces
   msg_if           dut_msg_if  (clk);
   hash_if          dut_hash_if (clk);
   sha_algo_wrapper dut_wr0 (.clk_p(clk), .rst_p(rst), .msg(dut_msg_if), .hash(dut_hash_if));


   initial begin
      // Add interface handles to config database
      // uvm_config_db #(virtual msg_if)::set (null, "uvm_test_top", "dut_msg_vif", dut_msg_if);
      // uvm_config_db #(virtual hash_if)::set (null, "uvm_test_top", "dut_hash_vif", dut_hash_if);
      uvm_config_db #(virtual msg_if)::set (null, "uvm_test_top", "msg_if", dut_msg_if);
      uvm_config_db #(virtual hash_if)::set (null, "uvm_test_top", "hash_if", dut_hash_if);

      // Run the test
      run_test ("single_value_test");
   end

   // // Dump the waveforms
   // initial begin
   //    $dumpvars;
   //    $dumpfile("waveforms.vcd");
   // end

endmodule

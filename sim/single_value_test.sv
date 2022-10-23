//////////////////////////////////////////////////////////////////////////////////
// Company:
// Engineer: Joshua Edgcombe
//
// Create Date: 10/20/2022 01:07:50 AM
// Design Name:
// Module Name: single_value_test
// Project Name:
// Target Devices:
// Tool Versions:
// Description: A UVM testcase that passes only a single value to the module
//
// Dependencies:
//
// Revision:
// Revision 0.01 - File Created
// Additional Comments:
//
//////////////////////////////////////////////////////////////////////////////////
import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::sha_env;
import test_pkg::msg_seq;

class single_value_test extends uvm_test;
   // Register this test with the UVM factory
   `uvm_component_utils (single_value_test)

   // Create handle for test environment
   sha_env env_e0;

   function new (string name = "single_value_test", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void build_phase(uvm_phase phase);
      // super.run_phase(phase);

      // Create the test environment
      env_e0 = sha_env::type_id::create("env_e0", this);
   endfunction // build_phase



   virtual function void end_of_elaboration_phase(uvm_phase phase);
      // super.run_phase(phase);

      uvm_top.print_topology();
   endfunction // end_of_elaboration_phase

   virtual task run_phase (uvm_phase phase);
      super.run_phase(phase);

      // Create the test message sequence
      // msg_seq test_msgs = msg_seq::type_id::create("test_msgs");


      phase.raise_objection(this);

      /************************************************************************
       * Supply test messages to message sequencer
       ************************************************************************/
      // test_msgs.start(env_e0.msg_a0.s0);

      `uvm_info("TEST", "TEST IS RUNNING!!!", UVM_LOW)
      #100us phase.drop_objection(this);
   endtask

endclass

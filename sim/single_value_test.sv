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

class single_value_test extends uvm_test;

   `uvm_component_utils (single_value_test)

   function new (string name = "single_value_test", uvm_component parent = null);
      super.new (name, parent);
   endfunction

   virtual function void end_of_elaboration_phase(uvm_phase phase);
      uvm_top.print_topology();
   endfunction


   virtual task run_phase (uvm_phase phase);
      phase.raise_objection(this);
      `uvm_info("TEST", "TEST IS RUNNING!!!", UVM_LOW)
      #100ns phase.drop_objection(this);
   endtask

endclass

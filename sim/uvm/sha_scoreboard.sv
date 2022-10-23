// The scoreboard is responsible for verifying the DUT's functionality. This
// includes tracking transactions and even internal signals to verify the DUT is
// functioning as expected.


import uvm_pkg::*;
`include "uvm_macros.svh"

import test_pkg::msg_seq_item;

class sha_scoreboard extends uvm_scoreboard;
   // Register the sha_scorecard with the UVM factory
   `uvm_component_utils(sha_scoreboard)

   uvm_analysis_imp #(msg_seq_item, sha_scoreboard) m_analysis_imp;

   function new(string name="sha_scoreboard", uvm_component parent=null);
      super.new(name, parent);
   endfunction // new
   
   /*
    * 
    */
   virtual function void build_phase(uvm_phase phase);
      super.build_phase(phase);

      m_analysis_imp = new("m_analysis_imp", this);

      // TODO: Generate or retrieve reference pattern from uvm_config_db
   endfunction // build_phase
   

   // This function is called every time a message transaction is seen
   virtual function write(msg_seq_item msg);
      `uvm_info("SCBD", $sformatf("Message found: %s", msg.convert2str()), UVM_HIGH)
   endfunction // write
endclass // sha_scoreboard
